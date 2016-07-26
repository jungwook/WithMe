//
//  Profile.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileCollectionCell.h"

typedef enum : NSUInteger {
    kProfileSectionMap = 0,
    kProfileSectionProfileMedia,
    kProfileSectionLikes,
    kProfileSectionLiked,
    kProfileSectionPosts,
} ProfileSections;

@interface Profile2 : UITableViewController
@property (strong, nonatomic) User* user;
@end
