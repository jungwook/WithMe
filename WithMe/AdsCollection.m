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
@property (nonatomic) CGPoint offset;
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

- (void)setQuery:(PFQuery *)query named:(NSString *)name
{
    self.name = name;
    if ([self.queryManager query:query named:name]) {
        self.offset = CGPointZero;
        [self loadAds:YES];
    } else {
        [self reloadData];
    }
    
    NSLog(@"SCROLLING BACK TO:%@", NSStringFromCGPoint(self.offset));
    [self scrollRectToVisible:CGRectMake(self.offset.x, self.offset.y, 100, 100) animated:YES];
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
    AdCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdCollectionCell forIndexPath:indexPath];
    cell.ad = [[self.queryManager itemsNamed:self.name] objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(viewAdDetail:)]) {
        [self.adDelegate viewAdDetail:[[self.queryManager itemsNamed:self.name] objectAtIndex:indexPath.row]];
    }
}

- (void) loadAds:(BOOL)isInitialLoad
{
    __LF
    
    __block NSInteger numLoaded = [self.queryManager itemsNamed:self.name].count;
    
    PFQuery *query = [self.queryManager queryNamed:self.name];
    
    [query setSkip:numLoaded];
    [query setLimit:5];
    
    [QueryManager query:query objects:^(NSArray * _Nullable objects) {
        numLoaded += objects.count;
        [self workItemsWithObjects:objects initialLoad:isInitialLoad];
    }];
}

- (void) workItemsWithObjects:(NSArray*)objects
                  initialLoad:(BOOL)isInitialLoad
{
    if (isInitialLoad) {
        __block NSInteger count = objects.count;
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad mediaAndUserReady:^{
                if (--count == 0) {
                    [self.queryManager setItems:objects named:self.name];
                    [self performBatchUpdates:^{
                        [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    } completion:nil];
                }
            }];
        }];
    }
    else {
        __block NSInteger count = objects.count;
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad mediaAndUserReady:^{
                if (--count == 0) {
                    [self.queryManager addItems:objects named:self.name];
                    [self performBatchUpdates:^{
                        [self insertItemsAtIndexPaths:indexPathsFromIndex([self.queryManager itemsNamed:self.name].count-objects.count, objects.count, 0)];
                    } completion:nil];
                }
            }];
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.offset = scrollView.contentOffset;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.queryManager itemsNamed:self.name].count-1) {
        [self loadAds:NO];
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id row = [[self.queryManager itemsNamed:self.name] objectAtIndex:indexPath.row];
    
    if ([row isKindOfClass:[Ad class]]) {
        CGFloat w = collectionView.bounds.size.width, h = collectionView.bounds.size.height;
        return CGSizeMake(w*0.9f, h);
    }
    else {
        return CGSizeZero;
    }
}


@end
