//
//  CollectionView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CollectionView.h"

#import "UIImage+AverageColor.h"

@interface CollectionRowCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *trash;
@property (assign, nonatomic) UIColor *buttonColor;
@property (nonatomic, strong) id item;
@property (nonatomic, copy) ItemBlock deletionBlock;
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
    [self.trash setTintColor:colorWhite];
    
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.clipsToBounds = YES;
    self.imageView.radius = 4.0f;
    
    self.trash.radius = self.trash.bounds.size.height/ 2.0f;
    setShadowOnView(self.trash, 1, 0.2);
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    [self.trash setTintColor:buttonColor];
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
        self.imageView.layer.borderColor = colorWhite.CGColor;
//        [self.trash setTintColor:image.averageColor];
    }];
}

@end


@interface CollectionView()
@property (weak, nonatomic)     NSArray *items;
@property (strong, nonatomic)   UICollectionView *collectionView;
@end

@implementation CollectionView

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    [self initializeCollection];
}

- (void) initializeCollection
{
    __LF
    self.buttonColor = self.backgroundColor;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = YES;
    self.collectionView.backgroundColor = colorWhite;
    [self insertSubview:self.collectionView atIndex:0];
    
    self.cellSizeRatio = 0.9f;
    self.sectionInsets = UIEdgeInsetsMake(0, 20, 0, 10);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionRowCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CollectionRowCell"];
    
    self.backgroundColor = [UIColor whiteColor];
    [self.collectionView setBounces:YES];
    [self.collectionView setAlwaysBounceHorizontal:YES];
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    [layout setMinimumLineSpacing:0];
    [layout setMinimumInteritemSpacing:8];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self.collectionView reloadData];
}

- (void)addAddMoreButtonTitled:(NSString *)title
{
    UIFont *buttonFont = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:colorWhite forState:UIControlStateNormal];
    [[button titleLabel] setFont:buttonFont];
    [button addTarget:self action:@selector(addMoreItem:) forControlEvents:UIControlEventTouchDown];
    
    CGFloat w = CGRectGetWidth(rectForString(title, buttonFont, INFINITY)) + 30, h = 30;
    button.radius = h / 2.0f;
    [button setBackgroundColor:self.buttonColor];
    [button setFrame:CGRectMake(CGRectGetWidth(self.bounds)-w-8, 4, w, h)];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds cornerRadius:button.radius];
    button.layer.shadowPath = shadowPath.CGPath;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeZero;
    button.layer.shadowRadius = 1.0f;
    button.layer.shadowOpacity = 0.4f;

    [self addSubview:button];
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
    
    [PFObject fetchAllIfNeededInBackground:items block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.collectionView reloadData];
    }];
}

- (void)setCellSizeRatio:(CGFloat)cellSizeRatio
{
    _cellSizeRatio = cellSizeRatio;
    
    CGFloat mh = 8;
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat sh = MAX(mh, h-2*mh);
    
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(sh/self.cellSizeRatio, sh);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.items objectAtIndex:indexPath.row];
    
    if (self.selectionBlock) {
        self.selectionBlock(item);
    }
}

- (void) deleteItem:(id)item
{
    __LF
    if (self.deletionBlock) {
        self.deletionBlock(item);
    }
}

- (void)addMoreItem:(id)sender
{
    __LF
    if (self.aditionBlock) {
        self.aditionBlock();
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    __LF
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    __LF
    
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    
    CollectionRowCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionRowCell" forIndexPath:indexPath];
    [cell setItem:[self.items objectAtIndex:indexPath.row]];
    [cell setDeletionBlock:^(id item) {
        [self deleteItem:item];
    }];
    [cell setButtonColor:self.buttonColor];
    return cell;
}

@end
