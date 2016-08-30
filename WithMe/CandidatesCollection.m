//
//  CandidatesCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CandidatesCollection.h"

@interface CandidatesCell : UICollectionViewCell
@property (nonatomic, strong) AdJoin* adjoin;
@property (nonatomic, copy) AdJoinBlock requestUnjoinBlock;
@end

@interface CandidatesCell()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *leaveButton;
@end

@implementation CandidatesCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.leaveButton.hidden = YES;
}

- (IBAction)unjoin:(id)sender
{
    if (self.requestUnjoinBlock) {
        self.requestUnjoinBlock(self.adjoin);
    }
}

- (void)setAdjoin:(AdJoin *)adjoin
{
    _adjoin = adjoin;
    NSLog(@"THIS JOIN REQUEST %@[%@/%@]", self.adjoin.isMine ? @"IS MINE" : @"IS NOT MINE", [User me].objectId, self.adjoin.userId);
    self.leaveButton.hidden = !(self.adjoin.isMine);
    [self.adjoin loadFirstMediaThumbnailImage:^(UIImage *image) {
        self.photoView.image = image;
    }];
}
@end


@interface CandidatesEmptyCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (nonatomic, copy) VoidBlock requestJoinBlock;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@end

@implementation CandidatesEmptyCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.joinButton.backgroundColor = kAppColor;
}

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
@property (nonatomic) BOOL joined;
@property (nonatomic, strong) NSMutableArray <AdJoin *> *joins;
@end

@implementation CandidatesCollection

- (void)refresh
{
    [self.collectionView reloadData];
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    [self reloadAdJoins];
}

- (void) reloadAdJoins
{
    PFQuery *query = [AdJoin query];
    [query whereKey:@"adId" equalTo:self.ad.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray <AdJoin *> * _Nullable joins, NSError * _Nullable error) {
        self.joins = [NSMutableArray arrayWithArray:joins];
        self.joined = NO;
        [self.joins enumerateObjectsUsingBlock:^(AdJoin * _Nonnull adJoin, NSUInteger idx, BOOL * _Nonnull stop) {
            if (adJoin.isMine) {
                self.joined = YES;
                [self.joins removeObject:adJoin];
                [self.joins insertObject:adJoin atIndex:0]; //Always put my AdJoin as first in line.
            }
        }];
        
        self.isMine = self.ad.isMine;
        [self.collectionView reloadData];
    }];
}

- (void) awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.isMine = YES;
    self.joined = NO;
    self.notif = [Notifications new];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = colorWhite;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    
    registerCollectionViewCellNib(@"CandidatesEmptyCell", self.collectionView);
    registerCollectionViewCellNib(@"CandidatesCell", self.collectionView);
    
    AdJoinBlock unjoinHandler = ^(AdJoin* adjoin) {
        [adjoin unjoin];
        [self.joins removeObject:adjoin];
        self.joined = NO;
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
    };
    self.requestUnjoinBlock = unjoinHandler;
    [self addSubview:self.collectionView];
}

- (void)addJoin:(AdJoin *)adjoin
{
    [adjoin join:self.ad joinedHandler:nil];
    [self.joins addObject:adjoin];
    self.joined = YES;
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
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
        if (self.joins.count > 0) {
            return self.joins.count;
        }
        else {
            return 1;
        }
    }
    else {
        if (self.joined) {
            return self.joins.count;
        }
        else {
            return self.joins.count+1;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMine) {
        if (self.joins.count > 0) {
            CandidatesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesCell" forIndexPath:indexPath];
            cell.adjoin = [self.joins objectAtIndex:indexPath.row];
            cell.requestUnjoinBlock = self.requestUnjoinBlock;
            return cell;
        }
        else {
            CandidatesEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesEmptyCell" forIndexPath:indexPath];
            [cell.joinButton setTitle:@"NOBODY" forState:UIControlStateNormal];
            cell.requestJoinBlock = nil;
            return cell;
        }
    }
    else {
        if (self.joined) {
            CandidatesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesCell" forIndexPath:indexPath];
            cell.adjoin = [self.joins objectAtIndex:indexPath.row];
            cell.requestUnjoinBlock = self.requestUnjoinBlock;
            return cell;
        }
        else {
            if (indexPath.row == 0) {
                CandidatesEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesEmptyCell" forIndexPath:indexPath];
                [cell.joinButton setTitle:@"JOIN NOW!" forState:UIControlStateNormal];
                cell.requestJoinBlock = self.requestJoinBlock;
                return cell;
            }
            else {
                CandidatesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CandidatesCell" forIndexPath:indexPath];
                NSInteger index = indexPath.row-1;
                NSLog(@"JOINS:%@", self.joins);
                cell.adjoin = [self.joins objectAtIndex:index];
                cell.requestUnjoinBlock = self.requestUnjoinBlock;
                return cell;
            }
        }
    }
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    if (indexPath.row == 0) {
        NSLog(@"CANNOT SELECT OLIVER");
    }
    else {
        AdJoin *join = [self.joins objectAtIndex:indexPath.row-1];
        if (self.userIdSelectedBlock) {
            self.userIdSelectedBlock(join.userId);
        }
    }
}

@end
