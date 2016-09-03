//
//  MediaCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaCollection.h"


@interface MediaCollectionCell : UICollectionViewCell
@property (nonatomic, weak) UserMedia *media;
@end

@implementation MediaCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)deleteMedia:(id)sender {
    __LF
    [self.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

- (void)setMedia:(UserMedia *)media
{
    __LF
    _media = media;
    self.clipsToBounds = YES;
    self.radius = 4.f;
    self.backgroundColor = [UIColor clearColor];
    
    [self.media thumbnailLoaded:^(UIImage *image) {
        if (media == self.media) {
            drawImage(image, self);
        }
    }];
}

@end

@interface MediaCollection()

@property (nonatomic, strong) UICollectionView *collectionView;
@end


@implementation MediaCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    registerCollectionViewCellNib(@"MediaCollectionCell", self.collectionView);
    
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = nil;
    
    [self addSubview:self.collectionView];
}

- (void)setUser:(User *)user
{
    _user = user;
    
    [self.user fetched:^{
        [self.collectionView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.user.media.count;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
    CGFloat h = CGRectGetHeight(self.bounds);
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(h*1.5, h);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCollectionCell" forIndexPath:indexPath];
    cell.media = [self.user.media objectAtIndex:indexPath.row];
    return cell;
}
@end
