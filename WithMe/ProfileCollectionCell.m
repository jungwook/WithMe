//
//  ProfileCollectionCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ProfileCollectionCell.h"
#import "ProfileMediaCell.h"
#import "AddMoreCell.h"
#import "MediaPicker.h"

#define kProfileMediaCell @"ProfileMediaCell"
#define kAddMoreCell @"AddMoreCell"

@interface ProfileCollectionCell()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation ProfileCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.backgroundView  = nil;
    self.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:kProfileMediaCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kProfileMediaCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kAddMoreCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kAddMoreCell];
    
    [self.collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count + self.editable;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.items.count) {
        AddMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddMoreCell forIndexPath:indexPath];
        return cell;
    }
    else {
        id item = [self.items objectAtIndex:indexPath.row];
        
        if ([item isKindOfClass:[UserMedia class]])
        {
            ProfileMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProfileMediaCell forIndexPath:indexPath];
            cell.media = [self.items objectAtIndex:indexPath.row];
            cell.parent = self;
            return cell;
        }
        else if ([item isKindOfClass:[User class]])
        {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            return cell;
        }
        else {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // if ADD MORE
    if (indexPath.row == self.items.count && self.addMoreType == kAddMoreUserMedia)
    {
        if ([self.profileDelegate respondsToSelector:@selector(profileCollectionCell:collectionView:addUserMediaAtIndexPath:)]) {
            [self.profileDelegate profileCollectionCell:self collectionView:self.collectionView addUserMediaAtIndexPath:indexPath];
        }
    }
    // IF NOT ADD MORE
    else {
        // DO NOTHING
    }
}

- (void)deleteUserMedia:(UserMedia *)media
{
    __LF
    NSUInteger index = [self.items indexOfObject:media];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if ([self.profileDelegate respondsToSelector:@selector(profileCollectionCell:collectionView:deleteUserMedia:atIndexPath:)]) {
        [self.profileDelegate profileCollectionCell:self collectionView:self.collectionView deleteUserMedia:media atIndexPath:indexPath];
    }
}

@end
