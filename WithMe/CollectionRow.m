//
//  CollectionRow.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CollectionRow.h"


@interface CollectionRowCell : UICollectionViewCell
@property (nonatomic, strong) id item;
@end

@implementation CollectionRowCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self clearContents];
}

- (void) clearContents
{
    
}

- (void)setItem:(id)item
{
    _item = item;
    
    
    
}

@end

@interface CollectionRow()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) NSArray *items;
@end

@implementation CollectionRow

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.cellSizeRatio = 1.0f;
    self.sectionInsets = UIEdgeInsetsMake(0, 20, 0, 10);
    
    [self.collectionView registerClass:[CollectionRowCell class] forCellWithReuseIdentifier:@"CollectionRowCell"];
}

- (void)setSectionInsets:(UIEdgeInsets)sectionInsets
{
    _sectionInsets = sectionInsets;
    
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.sectionInset = self.sectionInsets;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    
    [self.collectionView reloadData];
}

- (void)setCellSizeRatio:(CGFloat)cellSizeRatio
{
    _cellSizeRatio = cellSizeRatio;

    CGFloat mh = 8;
    CGFloat h = CGRectGetHeight(self.collectionView.bounds);
    CGFloat sh = MAX(mh, h-2*mh);
    
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(sh/self.cellSizeRatio, h);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.items objectAtIndex:indexPath.row];
    
    if (self.selectionBlock) {
        self.selectionBlock(item);
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionRowCell" forIndexPath:indexPath];
    [cell setItem:[self.items objectAtIndex:indexPath.row]];
    return cell;
}

@end
