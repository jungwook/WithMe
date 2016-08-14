//
//  UsersCollection.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UsersCollection.h"

@interface UserImageCell : UICollectionViewCell
@property (nonatomic, strong) User *user;
@end

@implementation UserImageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)setUser:(User *)user
{
    _user = user;
    
    [user.profileMedia thumbnailLoaded:^(UIImage *image) {
        drawImage(image, self);
    }];
}


@end

@implementation UsersCollection

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    
    [self registerClass:[UserImageCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)setUsers:(NSArray<User *> *)users
{
    _users = users;
    
    [self reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.user = [self.users objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showUserDelegate && [self.showUserDelegate respondsToSelector:@selector(viewUserProfile:)]) {
        [self.showUserDelegate viewUserProfile:[self.users objectAtIndex:indexPath.row]];
    }
}

@end
