//
//  AdMediaCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdMediaCollection.h"
#import "MediaPicker.h"

@interface AdMediaCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *trash;
@property (weak, nonatomic) IBOutlet UIButton *comment;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *commentBack;
@property (weak, nonatomic) IBOutlet UIView *commentButtonBack;
@property (weak, nonatomic) IBOutlet UIView *trashButtonBack;
@property (nonatomic)                BOOL editable;

@property (nonatomic, strong)        UserMedia *media;
@property (nonatomic, copy)          UserMediaBlock deletionBlock;
@property (nonatomic, copy)          UserMediaBlock updateCommentBlock;
@property (assign, nonatomic)        UIColor *tintColor;
@property (nonatomic, weak)          UIViewController *parentController;
@end

@implementation AdMediaCollectionCell


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

- (void)setTintColor:(UIColor *)tintColor
{
    [self.trash setTintColor:tintColor];
    [self.comment setTintColor:tintColor];
    
    self.commentBack.backgroundColor = tintColor;
}

- (IBAction)addComment:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter a comment!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.commentLabel.text;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *comment = [[alert.textFields firstObject].text uppercaseString];
        self.media.comment = comment;
        self.commentLabel.text = comment;
        showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
    }]];
    
    [self.parentController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)deleteItem:(id)sender
{
    if (self.deletionBlock) {
        self.deletionBlock(self.media);
    }
}

- (void)setEditable:(BOOL)editable
{
    self.commentButtonBack.hidden = !editable;
    self.trashButtonBack.hidden = !editable;
}

- (void)setMedia:(UserMedia *)media
{
    _media = media;
    [S3File getImageFromFile:media.thumbnailFile imageBlock:^(UIImage *image) {
        self.imageView.image = image;
        self.imageView.layer.borderColor = colorWhite.CGColor;
        self.commentLabel.text = self.media.comment ? [self.media.comment uppercaseString] : @"";
        showView(self.commentBack, (self.media.comment.length > 0));
    }];
}

@end


@interface AdMediaCollection()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *addMoreButton;
@end

#define kAddMediaCollectionCell @"AdMediaCollectionCell"

@implementation AdMediaCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupCollectionView];
    self.editable = NO;
}

- (void)refresh
{
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
}

- (void) setupCollectionView
{
    self.media = [NSMutableArray array];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = nil;
    
    [self insertSubview:self.collectionView atIndex:0];
    registerCollectionViewCellNib(kAddMediaCollectionCell, self.collectionView);
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 10);
    
    [self.collectionView reloadData];
    
    self.tintColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    
    self.addMoreButton = [self buttonWithTitle:@"+ media"];
    self.addMoreButton.hidden = !self.editable;
    [self addSubview:self.addMoreButton];
}

-(void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.addMoreButton.hidden = !self.editable;
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;

    self.media = [NSMutableArray arrayWithArray:self.ad.media];
    if (self.media.count == 0) {
        [[User me] profileMediaLoaded:^(UserMedia *media) {
            media.comment = @"This is me!";
            [self.media addObject:media];
            [self refresh];
        }];
    }
    [self refresh];
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
    [button setBackgroundColor:self.tintColor];
    [button setRadius:h / 2.0f];
    [button setFrame:CGRectMake(8, 4, w, h)];
    
    return button;
}

- (void)addMoreItem:(id)sender
{
    [MediaPicker pickMediaOnViewController:self.parentController withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
        if (picked) {
            userMedia.isProfileMedia = NO;
            [self.collectionView performBatchUpdates:^{
                [self.media addObject:userMedia];
                NSInteger index = [self.media indexOfObject:userMedia];
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            } completion:nil];
        }
    }];
}

- (void) deleteItem:(id)media
{
    [self.collectionView performBatchUpdates:^{
        NSInteger index = [self.media indexOfObject:media];
        [self.media removeObject:media];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.media.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdMediaCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddMediaCollectionCell forIndexPath:indexPath];
    [cell setMedia:[self.media objectAtIndex:indexPath.row]];
    [cell setDeletionBlock:^(id item) {
        [self deleteItem:item];
    }];
    cell.tintColor = self.tintColor;
    cell.parentController = self.parentController;
    cell.editable = self.editable;
    
    return cell;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat mh = 8;
    
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat sh = MAX(mh, h-2*mh);

    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(1.2*sh, sh);
    
    self.collectionView.frame = self.bounds;
}

@end
