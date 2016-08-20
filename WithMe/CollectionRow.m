//
//  CollectionRow.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CollectionRow.h"

@interface CollectionRowCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *trash;
@property (nonatomic, strong) id item;
@property (nonatomic, copy) DeleteItemBlock deletionBlock;
@end

@implementation CollectionRowCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeContents];
}

- (void) initializeContents
{
    [self.trash setImage:[[self.trash imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    self.trash.radius = CGRectGetWidth(self.trash.bounds)/2.0f;
//    setShadowOnView(self.trash, 2.0f, 0.4);
}

- (IBAction)deleteItem:(id)sender
{
    if (self.deletionBlock) {
        self.deletionBlock(self.item);
    }
}

- (void)setItem:(id)item
{
    _item = item;
    [S3File getImageFromFile:item[@"thumbnailFile"] imageBlock:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

@end

@interface CollectionRow()
@property (weak, nonatomic)             NSArray *items;
@property (weak, nonatomic) IBOutlet    UIButton *add;
@end

@implementation CollectionRow

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeCollection];
}

- (void) initializeCollection
{
    self.buttonColor = kCollectionRowColor;
    self.buttonTitleColor = [UIColor whiteColor];
    
    self.delegate = self;
    self.dataSource = self;
    self.cellSizeRatio = 1.0f;
    self.sectionInsets = UIEdgeInsetsMake(0, 20, 0, 10);
    
    [self registerNib:[UINib nibWithNibName:@"CollectionRowCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CollectionRowCell"];
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    _buttonColor = buttonColor;
    self.add.backgroundColor = self.buttonColor;
}

- (void)setButtonTitleColor:(UIColor *)buttonTitleColor
{
    _buttonTitleColor = buttonTitleColor;
    [self.add setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
}

- (void)setSectionInsets:(UIEdgeInsets)sectionInsets
{
    _sectionInsets = sectionInsets;
    
    UICollectionViewFlowLayout *layout = (id) self.collectionViewLayout;
    layout.sectionInset = self.sectionInsets;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    
    [PFObject fetchAllIfNeededInBackground:items block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self reloadData];
    }];
}

- (void)setCellSizeRatio:(CGFloat)cellSizeRatio
{
    _cellSizeRatio = cellSizeRatio;

    CGFloat mh = 8;
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat sh = MAX(mh, h-2*mh);
    
    UICollectionViewFlowLayout *layout = (id) self.collectionViewLayout;
    layout.itemSize = CGSizeMake(sh/self.cellSizeRatio, sh);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.items objectAtIndex:indexPath.row];
    
    if (self.selectionBlock) {
        self.selectionBlock(item);
    }
}

- (IBAction)addMoreItem:(id)sender {
    __LF
    if (self.addItemBlock) {
        self.addItemBlock();
    }
}

- (void) deleteItem:(id)item
{
    __LF
    if (self.deletionBlock) {
        self.deletionBlock(item);
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
    CollectionRowCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionRowCell" forIndexPath:indexPath];
    [cell setItem:[self.items objectAtIndex:indexPath.row]];
    [cell setDeletionBlock:^(id item) {
        [self deleteItem:item];
    }];
    [cell.trash setTintColor:self.buttonColor];
    return cell;
}

@end
