//
//  AdCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollection.h"
#import "IndentedLabel.h"
#import "AdCollectionCellBase.h"

#define kAdCollectionEmptyCell @"AdCollectionEmptyCell"
#define kQueryLimit 5

@interface AdCollectionEmptyCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSString *title;
@end

@implementation AdCollectionEmptyCell

-(void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = self.title;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

@end


@interface AdCollection()
@property (nonatomic, strong) NSMutableArray <Ad*> *ads;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) Notifications *notif;
@end

@implementation AdCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.notif = [Notifications new];
    
    ActionBlock refreshAdBlock = ^(Ad* ad) {
        NSInteger index = [self.ads indexOfObject:ad];
        if (index != NSNotFound) {
            NSArray <AdCollectionCellBase* > *cells = [self.collectionView visibleCells];
            [cells enumerateObjectsUsingBlock:^(AdCollectionCellBase * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([cell.ad isEqual:ad]) {
                    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
            }];
        }
    };
    [self.notif setNotification:kNotifyAdSaved forAction:refreshAdBlock];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.ads = [NSMutableArray array];
    self.widthRatioToHeight = 1.2f;
    self.cellWidth = 0.0f;
    
    registerCollectionViewCellNib(kAdCollectionEmptyCell, self.collectionView);
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.collectionView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static BOOL passed = NO;
    
    CGFloat x = scrollView.contentOffset.x;

    if (x < -100 && passed == NO) {
        passed = YES;
        NSLog(@"TRIGGERED-");
        [self refreshNewAds];
    }
    if (passed && x > -100) {
        passed = NO;
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier
{
    __LF
    _cellIdentifier = cellIdentifier;
    
    registerCollectionViewCellNib(cellIdentifier, self.collectionView);
    
    [self.query cancel];
    [self.query setSkip:0];
    [self.query setLimit:kQueryLimit];
    [self.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self initializeAdsWithAds:objects];
    }];
}

- (void)initializeAdsWithAds:(NSArray<Ad *> *)ads
{
    self.ads = [NSMutableArray arrayWithArray:ads];
    [self.collectionView reloadData];
}

- (void)loadMoreAdsWithAds:(NSArray<Ad *> *)ads
{
    [self.ads addObjectsFromArray:[self newItems:ads notIn:self.ads]];
    [self.collectionView reloadData];
}

- (void)loadRecentAdsWithAds:(NSArray<Ad *> *)ads
{
    NSArray *newItems = [self newItems:ads notIn:self.ads];
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newItems.count)];
    [self.ads insertObjects:newItems atIndexes:indexes];
    
    [self.collectionView reloadData];
}

- (NSArray *) objectIdsFromAds:(NSArray <Ad*>*)ads
{
    NSMutableArray *ids = [NSMutableArray array];
    [ads enumerateObjectsUsingBlock:^(Ad * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:obj.objectId];
    }];
    return ids;
}

- (NSArray *) newItems:(NSArray <Ad*> *)newItems notIn:(NSArray <Ad*> *)ads
{
    NSMutableArray *newSet = [NSMutableArray array];
    
    [newItems enumerateObjectsUsingBlock:^(Ad * _Nonnull newAd, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self ad:newAd notInsideAds:ads]) {
            [newSet addObject:newAd];
        }
    }];
    return newSet;
}


- (BOOL) ad:(Ad*)ad notInsideAds:(NSArray <Ad*>*)ads
{
    NSArray *set = [ads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId = %@", ad.objectId]];
    return (set.count == 0);
}

- (NSDate *)firstCreatedAt
{
    return [self.ads firstObject] ? [self.ads firstObject].updatedAt : [NSDate date];
}

- (void)refreshNewAds
{
    __LF
    NSDate *firstCreatedAt = self.ads.firstObject.createdAt;
    [self.query cancel];
    [self.query setSkip:0];
    if (firstCreatedAt) {
        [self.query whereKey:@"createdAt" greaterThan:firstCreatedAt];
    }
    [self.query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (number) {
            NSLog(@"FOUND:%d MORE ADS", number);
            [self.query setLimit:number];
            [self.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                [self loadRecentAdsWithAds:objects];
            }];
        }
    }];
}

- (void)loadMoreAds
{
    __LF
    if (!self.isGeoSpatial || YES) {
            [self.query cancel];
        [self.query setSkip:self.ads.count];
        [self.query setLimit:kQueryLimit];
        [self.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count >0) {
                [self loadMoreAdsWithAds:objects];
            }
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSUInteger lastIndex = 0;
    
    NSLog(@"INDEXPATH RTOW:%ld LAST INDEX:%ld ADS:%ld", indexPath.row, lastIndex, self.ads.count);
    
    if (indexPath.row == self.ads.count - 1) {
        if (indexPath.row != lastIndex) {
            NSLog(@"Ready to load more");
            lastIndex = indexPath.row;
            [self loadMoreAds];
        }
    }
}

- (void)setAdSelectedBlock:(AdBlock)adSelectedBlock
{
    __LF
    _adSelectedBlock = adSelectedBlock;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.ads.count > 0)
    {
        Ad *ad = [self.ads objectAtIndex:indexPath.row];
        if (self.adSelectedBlock) {
            self.adSelectedBlock(ad);
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MAX(self.ads.count, 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.ads.count > 0) {
        AdCollectionCellBase *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
        cell.ad = [self.ads objectAtIndex:indexPath.row];
        cell.userSelectedBlock = ^(User* user) {
            if (self.userSelectedBlock) {
                self.userSelectedBlock(user);
            }
        };
        return cell;
    }
    else {
        __LF
        AdCollectionEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdCollectionEmptyCell forIndexPath:indexPath];
        cell.title = self.emptyTitle;
        return cell;
    }
    
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) collectionViewLayout;
    
    CGFloat top = layout.sectionInset.top, bottom = layout.sectionInset.bottom;
    CGFloat h = MAX( CGRectGetHeight(collectionView.bounds) - top - bottom, 0);

    if (self.ads.count > 0) {
        return CGSizeMake(self.cellWidth > 0 ? self.cellWidth : h*self.widthRatioToHeight, h);
    }
    else {
        return CGSizeMake(h, h);
    }
}

@end
