//
//  CategoriesCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CategoriesCollection.h"
#define kAdCategoryCell @"AdCategoryCell"

@implementation CategoriesCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    
    [self registerNib:[UINib nibWithNibName:kAdCategoryCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kAdCategoryCell];
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
    AdCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdCategoryCell forIndexPath:indexPath];
    cell.category = [self.categories objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.categoryDelegate && [self.categoryDelegate respondsToSelector:@selector(viewCategory:)]) {
        [self.categoryDelegate viewCategory:[self.categories objectAtIndex:indexPath.row]];
    }
}

- (void)setCategories:(NSArray *)categories
{
    _categories = categories;
    
    [self reloadData];
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionViewLayout;
    UIEdgeInsets sectionInset = layout.sectionInset;
    UIEdgeInsets contentInset = self.contentInset;

    id row = [self.categories objectAtIndex:indexPath.row];
    
    if ([row isKindOfClass:[Category class]]) {
        CGFloat h = collectionView.bounds.size.height-sectionInset.top-sectionInset.bottom-contentInset.top-contentInset.bottom - 20;
        return CGSizeMake(h, h);
    }
    else {
        return CGSizeZero;
    }
}


@end
