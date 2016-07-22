//
//  ProfileCollectionCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kAddMoreNone = 0,
    kAddMoreUserMedia,
    kAddMoreUserPost,
} AddMoreType;

@interface ProfileCollectionCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray *items;
@property (weak, nonatomic) User *user;
@property (nonatomic) AddMoreType addMoreType;
@property (nonatomic) BOOL editable;

- (void) deleteUserMedia:(UserMedia*)media;
@end
