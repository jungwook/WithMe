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
@property (nonatomic, strong) NSMutableArray <Ad*> *ads;
@end

#define kAdCollectionCell @"AdCollectionCell"

@implementation AdsCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;

    [self registerNib:[UINib nibWithNibName:kAdCollectionCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kAdCollectionCell];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.ads.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdCollectionCell forIndexPath:indexPath];
    cell.ad = [self.ads objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(viewAdDetail:)]) {
        [self.adDelegate viewAdDetail:[self.ads objectAtIndex:indexPath.row]];
    }
}

- (void)setQuery:(PFQuery *)query
{
    _query = query;
    
    [self loadAds:YES];
}

- (void) loadAds:(BOOL)isInitialLoad
{
    __block NSInteger numLoaded = self.ads.count;
    
    [self.query setSkip:numLoaded];
    [self.query setLimit:5];
    
    [QueryManager query:self.query objects:^(NSArray * _Nullable objects) {
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
                    self.ads = [NSMutableArray arrayWithArray:objects];
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
                    [self.ads addObjectsFromArray:objects];
                    [self performBatchUpdates:^{
                        [self insertItemsAtIndexPaths:indexPathsFromIndex(self.ads.count-objects.count, objects.count, 0)];
                    } completion:nil];
                }
            }];
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.ads.count-1) {
        [self loadAds:NO];
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id row = [self.ads objectAtIndex:indexPath.row];
    
    if ([row isKindOfClass:[Ad class]]) {
        CGFloat w = collectionView.bounds.size.width, h = collectionView.bounds.size.height;
        return CGSizeMake(w*0.9f, h);
    }
    else {
        return CGSizeZero;
    }
}


@end
