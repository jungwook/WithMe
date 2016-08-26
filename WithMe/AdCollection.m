//
//  AdCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollection.h"
#import "IndentedLabel.h"

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

@interface AdCollectionCell : UICollectionViewCell
@property (nonatomic, weak) Ad *ad;
@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIView *imageBack;
@property (weak, nonatomic) IBOutlet UIView *photoBack;
@property (weak, nonatomic) IBOutlet IndentedLabel *categoryLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomPane;
@property (weak, nonatomic) IBOutlet UIView *topPane;
@property (strong, nonatomic) UIColor *tintColor;
@end

@implementation AdCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeCell];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    [self.heartButton setTintColor:tintColor forState:UIControlStateNormal];
    self.categoryLabel.textColor = tintColor;
    self.activityLabel.textColor = tintColor;
    self.bottomPane.backgroundColor = tintColor;
    self.topPane.backgroundColor = tintColor;
    self.imageBack.layer.borderWidth = 4.0f;
    self.imageBack.layer.borderColor = tintColor.CGColor;
    self.imageBack.layer.masksToBounds = YES;
    self.imageBack.backgroundColor = tintColor;
    self.imageView.backgroundColor = tintColor;
    self.photoView.backgroundColor = tintColor;
    self.photoBack.backgroundColor = tintColor;
}

- (void)initializeCell
{
    [self.heartButton setImage:[[self.heartButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    self.tintColor = kAppColor;
    
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;

    self.imageView.image = nil;
    self.photoView.image = nil;
    self.titleLabel.text = [ad.title uppercaseString];
    self.activityLabel.text = [ad.activity.name uppercaseString];
    self.categoryLabel.text = [ad.activity.category.name uppercaseString];
    
    [ad fetched:^{
        [ad firstThumbnailImageLoaded:^(UIImage *image) {
            if (ad == self.ad) {
                self.imageView.image = image;
                self.imageView.layer.cornerRadius = 4.f;
                self.imageView.layer.masksToBounds = YES;
            }
        }];
        
        [ad userProfileThumbnailLoaded:^(UIImage *image) {
            if (ad == self.ad) {
                self.photoView.image = image;
            }
        }];
    }];
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
@end

@implementation AdCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self addSubview:self.collectionView];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.ads = [NSMutableArray array];
    self.widthRatioToHeight = 1.2f;
    self.cellWidth = 0.0f;
    
//    [self.collectionView registerClass:[AdCollectionEmptyCell class] forCellWithReuseIdentifier:kAdCollectionEmptyCell];
    registerCollectionViewCellNib(kAdCollectionEmptyCell, self.collectionView);
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
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

- (void)setQuery:(PFQuery *)query
{
    _query = query;
}

- (void)setCellIdentifier:(NSString *)cellIdentifier
{
    _cellIdentifier = cellIdentifier;
    
    registerCollectionViewCellNib(cellIdentifier, self.collectionView);
    if (self.loadAllBlock) {
        self.loadAllBlock(self.query, nil);
    }
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


- (void)reloadAll
{
    __LF
}

- (NSDate *)firstCreatedAt
{
    return [self.ads firstObject] ? [self.ads firstObject].updatedAt : [NSDate date];
}

- (void)refreshNewAds
{
    if (self.loadRecentBlock) {
        self.loadRecentBlock(self.query, self.ads);
    }
}

- (void)loadMoreAds
{
    if (self.loadMoreBlock) {
        self.loadMoreBlock(self.query, self.ads);
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSUInteger lastIndex = 0;
    
    if (indexPath.row == self.ads.count - 1) {
        if (indexPath.row != lastIndex) {
            NSLog(@"Ready to load more");
            lastIndex = indexPath.row;
            [self loadMoreAds];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.ads.count > 0) {
        Ad *ad = [self.ads objectAtIndex:indexPath.row];
        [Notifications notify:kNotifyAdSelected object:ad];
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
        AdCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
        cell.ad = [self.ads objectAtIndex:indexPath.row];
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
