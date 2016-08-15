//
//  AdsCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdsCollection.h"
#import "QueryManager.h"

@interface AdsCollection()
@property (nonatomic, strong) QueryManager *queryManager;
@property (nonatomic, strong) NSString* name;
@end

#define kAdCollectionCell @"AdCollectionCell"

@implementation AdsCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    self.queryManager = [QueryManager new];

    [self registerNib:[UINib nibWithNibName:kAdCollectionCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kAdCollectionCell];
}

- (void)reset
{
    __LF
    self.name = nil;
}

- (void)setQuery:(PFQuery *)query
           named:(NSString *)name
           index:(NSInteger)index
 cellIndentifier:(NSString *)cellIdentifier
{
    [self reloadData];
    if ([self.name isEqualToString:name]) {
        // Nothing to do
    }
    else {
        // set name
        self.name = name;
        
        if ([self.queryManager initializeQuery:query named:name index:index cellIndentifier:cellIdentifier]) {
            // If first time initialized (query with queryName does not exists) then load from start.
            [self loadAds:YES named:name];
        } else {
            // If queryNamed name already exists then just scroll to last postion recorded
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollRectToVisible:[self.queryManager visibleRectNamed:name] animated:NO];
            });
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect rect = CGRectMake(scrollView.contentOffset.x,
                             scrollView.contentOffset.y,
                             scrollView.bounds.size.width-1,
                             scrollView.bounds.size.height-1);
    [self.queryManager setVisibleRect:rect named:self.name];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.queryManager itemsNamed:self.name].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self.queryManager cellIndentifierNamed:self.name] forIndexPath:indexPath];
    cell.ad = [[self.queryManager itemsNamed:self.name] objectAtIndex:indexPath.row];
    cell.delegate = self.adDelegate;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(viewAdDetail:)]) {
        [self.adDelegate viewAdDetail:[[self.queryManager itemsNamed:self.name] objectAtIndex:indexPath.row]];
    }
}

- (void)adsCollectionLoaded:(BOOL) additionalLoaded
{
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(adsCollectionLoaded:additional:)]) {
        [self.adDelegate adsCollectionLoaded:[self.queryManager indexNamed:self.name] additional:additionalLoaded];
    }
}

- (void) loadAds:(BOOL)isInitialLoad named:(NSString*)name
{
    NSLog(@"Loading Ads for:%@ [%@]", name, isInitialLoad ? @"INITIAL" : @"NO");
    
    __block NSInteger numLoaded = [self.queryManager itemsNamed:name].count;
    PFQuery *query = [self.queryManager queryNamed:name];
    
    [query setSkip:numLoaded];
    [query setLimit:5];
    
    [QueryManager query:query objects:^(NSArray * _Nullable objects) {
        numLoaded += objects.count;
        [self workItemsWithObjects:objects initialLoad:isInitialLoad named:name];
    }];
}

- (void) workItemsWithObjects:(NSArray*)objects
                  initialLoad:(BOOL)isInitialLoad
                        named:(NSString*)name
{
    __LF
    if (isInitialLoad) {
        __block NSInteger count = objects.count;
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad fetched:^{
                if (--count == 0) {
                    [self.queryManager setItems:objects named:name];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performBatchUpdates:^{
                            [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
                        } completion:nil];
                        [self adsCollectionLoaded:NO];
                    });
                }
            }];
        }];
    }
    else {
        __block NSInteger count = objects.count;
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad fetched:^{
                if (--count == 0) {
                    [self.queryManager addItems:objects named:self.name];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performBatchUpdates:^{
                            [self insertItemsAtIndexPaths:indexPathsFromIndex([self.queryManager itemsNamed:self.name].count-objects.count, objects.count, 0)];
                        } completion:nil];
                        [self adsCollectionLoaded:YES];
                    });
                }
            }];
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.queryManager itemsNamed:self.name].count-1) {
        [self loadAds:NO named:self.name];
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id row = [[self.queryManager itemsNamed:self.name] objectAtIndex:indexPath.row];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionViewLayout;
    UIEdgeInsets sectionInset = layout.sectionInset;
    UIEdgeInsets contentInset = self.contentInset;
    
    if ([row isKindOfClass:[Ad class]]) {
        CGFloat w = collectionView.bounds.size.width, h = collectionView.bounds.size.height - sectionInset.top - sectionInset.bottom - contentInset.top - contentInset.bottom - 4;
        return CGSizeMake(w*0.9f, h);
    }
    else {
        return CGSizeZero;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}


@end
