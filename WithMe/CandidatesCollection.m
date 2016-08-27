//
//  CandidatesCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CandidatesCollection.h"
@interface CandidatesEmptyCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@end

@implementation CandidatesEmptyCell

- (void)layoutSubviews
{
    [super layoutSubviews];
//    self.poster.radius = CGRectGetHeight(self.poster.bounds) / 2.0f;
}

@end

@interface CandidatesCollection ()
@property (nonatomic, strong) UICollectionView* collectionView;
@end

@implementation CandidatesCollection

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = colorWhite;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    
    registerCollectionViewCellNib(@"CandidatesEmptyCell", self.collectionView);
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    CGFloat h = CGRectGetHeight(self.bounds);
    
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 10);
    layout.itemSize = CGSizeMake(h-20, h);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}


- (void)setCandidates:(NSArray<User *> *)candidates
{
    __LF
    _candidates = candidates;
    
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.candidates.count > 0 ? self.candidates.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    if (self.candidates.count == 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesEmptyCell" forIndexPath:indexPath];
        return cell;
    }
    else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    }
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    if (self.candidates.count) {
        User *user = [self.candidates objectAtIndex:indexPath.row];
        NOTIFY(kNotifyUserSelected, user);
    }
}

@end
