//
//  CollectionView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CollectionView.h"
#import "AppDelegate.h"
#import "UIImage+AverageColor.h"

@interface CollectionRowCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *trash;
@property (weak, nonatomic) IBOutlet UIButton *comment;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *commentBack;
@property (assign, nonatomic)        UIColor *buttonColor;
@property (nonatomic, strong)        id item;
@property (nonatomic, copy)          ItemBlock deletionBlock;
@property (nonatomic, weak)          UIViewController *viewController;
@property (weak, nonatomic) IBOutlet UIView *commentButtonBack;
@property (weak, nonatomic) IBOutlet UIView *trashButtonBack;
@property (nonatomic)                BOOL isMine;
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
    [self.comment setImage:[[self.comment imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.trash setTintColor:colorWhite];
    [self.comment setTintColor:colorWhite];
    
    self.imageView.clipsToBounds = YES;
    self.imageView.radius = 4.0f;
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    [self.trash setTintColor:buttonColor];
    [self.comment setTintColor:buttonColor];
    self.commentBack.backgroundColor = buttonColor;
}

- (IBAction)addComment:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter a comment!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.commentLabel.text;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *comment = [[alert.textFields firstObject].text uppercaseString];
        PFObject *object = self.item;
        [object setObject:comment forKey:@"comment"];
        self.commentLabel.text = comment;
        showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
    }]];
    
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)deleteItem:(id)sender
{
    if (self.deletionBlock) {
        self.deletionBlock(self.item);
    }
}

- (void)setIsMine:(BOOL)isMine
{
    self.commentButtonBack.hidden = !isMine;
    self.trashButtonBack.hidden = !isMine;
}

- (void)setItem:(id)item
{
    _item = item;
    [S3File getImageFromFile:item[@"thumbnailFile"] imageBlock:^(UIImage *image) {
        self.imageView.image = image;
        self.imageView.layer.borderColor = colorWhite.CGColor;
        self.commentLabel.text = [item objectForKey:@"comment"] ? [[item objectForKey:@"comment"] uppercaseString] : @"";
        showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
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
    
    self.cellSizeRatio = 0.8f;
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
    UIButton *button = [self buttonWithTitle:title];
//    [self setButtonShadow:button];
    [self addSubview:button];
}

- (UIButton*) buttonWithTitle:(NSString*)title
{
    UIFont *buttonFont = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    CGFloat w = CGRectGetWidth(rectForString(title, buttonFont, INFINITY)) + 20, h = 25;
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:colorWhite forState:UIControlStateNormal];
    [button.titleLabel setFont:buttonFont];
    [button addTarget:self action:@selector(addMoreItem:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundColor:self.buttonColor];
    [button setRadius:h / 2.0f];
    [button setFrame:CGRectMake(8, 4, w, h)];
    
    return button;
}

- (void) setButtonShadow:(UIButton*)button
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds cornerRadius:button.radius];
    button.layer.shadowPath = shadowPath.CGPath;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeZero;
    button.layer.shadowRadius = 1.0f;
    button.layer.shadowOpacity = 0.4f;
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
    
    CGFloat mh = 4;

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
    if (self.deletionBlock) {
        self.deletionBlock(item);
    }
}

- (void)addMoreItem:(id)sender
{
    if (self.additionBlock) {
        self.additionBlock();
    }
}

- (void)refresh
{
    [self.collectionView reloadData];
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
    [cell setButtonColor:self.buttonColor];
    [cell setViewController:self.viewController];
    [cell setIsMine:self.isMine];
    return cell;
}

- (void)setIsMine:(BOOL)isMine
{
    _isMine = isMine;
}

@end
