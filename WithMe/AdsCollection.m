//
//  AdsCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdsCollection.h"

@interface AdsCollection()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <Ad *> *ads;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic) BOOL shouldRefresh;
@end

@implementation AdsCollection

void        registerCollectionViewCellNib(NSString* nibName, UICollectionView* collectionView);

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *flow = (id)self.collectionView.collectionViewLayout;
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.sectionInset = UIEdgeInsetsMake(0, 20, 0, 10);
    
    self.shouldRefresh = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat h = CGRectGetHeight(self.bounds);
    self.collectionView.frame = self.bounds;
    
    UICollectionViewFlowLayout *flow = (id)self.collectionView.collectionViewLayout;
    flow.itemSize = CGSizeMake(h*1.5f, h);
}

- (void)setQuery:(PFQuery *)query andCellIdentifier:(id)cellIdentifier
{
    _query = query;
    _cellIdentifier = cellIdentifier;
    
    registerCollectionViewCellNib(cellIdentifier, self.collectionView);
    [self loadAds];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat lastPosition = 0;
    
    CGFloat position = scrollView.contentOffset.x;
    
    if (lastPosition != position) {
        lastPosition = position;
        self.shouldRefresh = (fabs(position-lastPosition) < 20);
    }
}

- (void) loadAds
{
    [self.query cancel];
    [self.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.ads = [NSMutableArray arrayWithArray:objects];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
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
    AdsCellBase *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    cell.ad = [self.ads objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return cell;
}

@end
