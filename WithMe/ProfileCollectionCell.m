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
@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) Notifications *notif;
@end

@implementation ProfileCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.notif = [Notifications new];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.backgroundView  = nil;
    self.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:kProfileMediaCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kProfileMediaCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kAddMoreCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kAddMoreCell];
    
    __weak __typeof(self) welf = self;
    [self.notif setNotification:@"NotifyProfileMediaChanged" forAction:^(id actionParams) {
        [welf setItemsFromCollectionType];
        if (self.collectionType == kCollectionTypeUserMedia) {
            
            UserMedia *media = actionParams;
            NSUInteger index = [welf.items indexOfObject:media];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [welf.collectionView performBatchUpdates:^{
                    [welf.collectionView reloadItemsAtIndexPaths:@[path]];
                } completion:nil];
            });
        }
    }];
}

- (void)setItemsFromCollectionType
{
    switch (self.collectionType) {
        case kCollectionTypeUserMedia:
            NSLog(@"USERMEDIA");
            self.items = self.user.sortedMedia;
            break;
        case kCollectionTypeUserPost:
            NSLog(@"POSTS");
            self.items = self.user.posts;
            break;
        case kCollectionTypeLiked:
            NSLog(@"LIKED");
            self.items = self.user.likes;
            break;
        case kCollectionTypeLikes:
            NSLog(@"LIKES");
            self.items = self.user.likes;
            break;
        default:
            self.items = nil;
            break;
    }
}

- (void)setCollectionType:(CollectionType)collectionType
{
    __LF
    _collectionType = collectionType;
    [self setItemsFromCollectionType];
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
    __LF
    
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
            if (cell.media.isProfileMedia) {
                NSLog(@"SETTING NEW PROF:%@", cell.media);
            }
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
    if (indexPath.row == self.items.count && self.collectionType == kCollectionTypeUserMedia)
    {
        [MediaPicker pickMediaOnViewController:nil withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
            userMedia.isProfileMedia = NO;
            [self.user addUniqueObject:userMedia forKey:@"media"];
            [self.user saved:^{
                [self setItemsFromCollectionType];
                NSUInteger index = [self.items indexOfObject:userMedia];
                if (index != NSNotFound) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                    [self.collectionView performBatchUpdates:^{
                        [self.collectionView insertItemsAtIndexPaths:@[path]];
                    } completion:nil];
                }
            }];
        }];
    }
}

- (void)deleteUserMedia:(UserMedia *)media
{
    __LF
    NSUInteger index = [self.items indexOfObject:media];
    if (index != NSNotFound) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.user removeObject:media forKey:@"media"];
        [self.user saved:^{
            [self setItemsFromCollectionType];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[path]];
            } completion:nil];
        }];
    }
}

@end
