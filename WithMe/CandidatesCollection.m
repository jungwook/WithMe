//
//  CandidatesCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CandidatesCollection.h"
#import "CandidatesCell.h"

@interface CandidatesEmptyCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (nonatomic, copy) VoidBlock requestJoinBlock;
@end

@implementation CandidatesEmptyCell

- (IBAction)joinAd:(id)sender
{
    if (self.requestJoinBlock) {
        self.requestJoinBlock();
    }
}

@end

@interface CandidatesCollection ()
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) Notifications *notif;
@property (nonatomic) BOOL isMine;
@end

@implementation CandidatesCollection

- (void)refresh
{
    [self.collectionView reloadData];
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    
    [self.ad fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.isMine = self.ad.isMine;
        [self.collectionView reloadData];
    }];
}

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.isMine = YES;
    self.notif = [Notifications new];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = colorWhite;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    
    registerCollectionViewCellNib(@"CandidatesEmptyCell", self.collectionView);
    registerCollectionViewCellNib(@"CandidatesCell", self.collectionView);
    
    ActionBlock joinHandler = ^(AdJoin* adjoin) {
        [self.ad fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [self.collectionView performBatchUpdates:^{
                [self.ad join:adjoin];
                [self.ad saved:^{
                    NSLog(@"SAVED");
                }];
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:^(BOOL finished) {
            }];
        }];
    };
    
    ActionBlock unjoinHandler = ^(AdJoin* adjoin) {
        [self.ad fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [self.collectionView performBatchUpdates:^{
                [self.ad unjoin:adjoin];
                [self.ad saved:^{
                    NSLog(@"SAVED");
                }];
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:^(BOOL finished) {
            }];
        }];
    };
    
    [self.notif setNotification:kNotifyJoinedAd forAction:joinHandler];
    [self.notif setNotification:kNotifyUnjoinedAd forAction:unjoinHandler];

    [self addSubview:self.collectionView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    CGFloat h = CGRectGetHeight(self.bounds);
    
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 10);
    layout.itemSize = CGSizeMake(h, h);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 4;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static BOOL passed = NO;
    
    CGFloat x = scrollView.contentOffset.x;
    
    if (x < -60 && passed == NO) {
        passed = YES;
        self.ad = self.ad;
    }
    if (passed && x > -60) {
        passed = NO;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isMine) {
        return self.ad.joins.count;
    }
    else {
        return self.ad.joins.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMine) {
        CandidatesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesCell" forIndexPath:indexPath];
        cell.adjoin = [self.ad.joins objectAtIndex:indexPath.row];
        return cell;
    }
    else {
        if (indexPath.row == 0) {
            CandidatesEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesEmptyCell" forIndexPath:indexPath];
            cell.requestJoinBlock = ^{
                if (self.requestJoinBlock) {
                    self.requestJoinBlock();
                }
            };
            return cell;
        }
        else {
            CandidatesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesCell" forIndexPath:indexPath];
            cell.adjoin = [self.ad.joins objectAtIndex:indexPath.row-1];
            return cell;
        }
    }
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    if (self.ad.joins.count > 0) {
        AdJoin *join = [self.ad.joins objectAtIndex:indexPath.row];
        if (self.userSelectedBlock) {
            self.userSelectedBlock(join.user);
        }
    }
}

@end
