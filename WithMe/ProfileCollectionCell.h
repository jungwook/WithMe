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
    kAddMoreNone = 0,
    kAddMoreUserMedia,
    kAddMoreUserPost,
} AddMoreType;

@protocol ProfileCollectionDelegate <NSObject>
- (void)profileCollectionCell:(ProfileCollectionCell*)cell
               collectionView:(UICollectionView*)collectionView
      addUserMediaAtIndexPath:(NSIndexPath*) indexPath;

- (void)profileCollectionCell:(ProfileCollectionCell*)cell
               collectionView:(UICollectionView*)collectionView
              deleteUserMedia:(UserMedia*)media
                  atIndexPath:(NSIndexPath*)indexPath;
@end

@interface ProfileCollectionCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray *items;
@property (weak, nonatomic) User *user;
@property (nonatomic) AddMoreType addMoreType;
@property (nonatomic) BOOL editable;
@property (nonatomic, weak) id <ProfileCollectionDelegate> profileDelegate;

- (void) deleteUserMedia:(UserMedia*)media;
@end
