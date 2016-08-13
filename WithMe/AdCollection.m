//
//  AdCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollection.h"
#import "RefreshControl.h"
#import "AdCollectionCell.h"
#import "AdCategoryCell.h"
#import "LocationManager.h"

@interface AdCollection()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@end

#define kQueryLimit 100
#define kUpdatedAt @"updatedAt"

@implementation AdCollection

- (void)awakeFromNib {
    [super awakeFromNib];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    registerCollectionViewCellNib(@"AdCollectionCell", self.collectionView);
    registerCollectionViewCellNib(@"AdCategoryCell", self.collectionView);
}

- (void) setSection:(SectionObject *)section
{
    _section = section;
    self.delegate = nil;
    self.title.text = section.title;
    [self.collectionView reloadData];
}

- (void)moreItemsAdded:(NSArray *)arrayOfIndexPathOfAddedItems
{
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:arrayOfIndexPathOfAddedItems];
    } completion:nil];
}

- (void)layoutSubviews
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.section.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id row = [self.section.items objectAtIndex:indexPath.row];
    
    if ([row isKindOfClass:[Ad class]]) {
        AdCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AdCollectionCell" forIndexPath:indexPath];
        cell.ad = row;
        return cell;
    }
    else if ([row isKindOfClass:[Category class]]) {
        AdCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AdCategoryCell" forIndexPath:indexPath];
        cell.category = row;
        
        return cell;
    }
    else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor redColor];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.section.items.count-1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(loadMoreForSection:)]) {
            [self.delegate loadMoreForSection:self.section];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    id item = [self.section.items objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[Ad class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adSelected:)]) {
            [self.delegate adSelected:item];
        }
    }
    else if ([item isKindOfClass:[Category class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(categorySelected:)]) {
            [self.delegate categorySelected:item];
        }
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id row = [self.section.items objectAtIndex:indexPath.row];
    
    if ([row isKindOfClass:[Ad class]]) {
        CGFloat w = collectionView.bounds.size.width, h = collectionView.bounds.size.height;
        return CGSizeMake(w*0.9f, h);
    }
    else if ([row isKindOfClass:[Category class]]) {
        CGFloat h = collectionView.bounds.size.height-8;
        return CGSizeMake(h, h);
    }
    else {
        return CGSizeZero;
    }
}

@end
