//
//  CategoryCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CategoryCollection.h"
#import "AdCategoryCell.h"
#import "Notifications.h"

@interface CategoryCollection()
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) Notifications *notif;
@end

@implementation CategoryCollection

#define kCategoryCollectionCell @"AdCategoryCell"

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.notif = [Notifications new];
    ActionBlock block = ^(id actionParams) {
        self.categories = [WithMe new].categories;
        [self.collectionView reloadData];
    };
    [self.notif setNotification:kNotifyCategoriesInitialized forAction:block];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    
    [self addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:kCategoryCollectionCell bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:kCategoryCollectionCell];

    
    
    self.categories = [WithMe new].categories;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = colorWhite;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    CGFloat h = CGRectGetHeight(self.bounds) - 4;
    
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 10);
    layout.itemSize = CGSizeMake(h, h);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCategoryCollectionCell forIndexPath:indexPath];
    cell.category = [self.categories objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Category *category = [self.categories objectAtIndex:indexPath.row];
    [Notifications notify:kNotifyCategorySelected object:category];
}


@end
