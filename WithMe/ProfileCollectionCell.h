//
//  ProfileCollectionCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileCollectionCell;

typedef enum : NSUInteger {
    kCollectionTypeNone = 0,
    kCollectionTypeUserMedia,
    kCollectionTypeLikes,
    kCollectionTypeLiked,
    kCollectionTypeUserPost,
} CollectionType;

@interface ProfileCollectionCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (weak, nonatomic) User *user;
@property (nonatomic) CollectionType collectionType;
@property (nonatomic) BOOL editable;

- (void) deleteUserMedia:(UserMedia*)media;

@end
