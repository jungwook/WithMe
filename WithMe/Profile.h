//
//  Profile.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kProfileSectionProfileMedia = 0,
    kProfileSectionLikes,
    kProfileSectionLiked,
    kProfileSectionPosts,
} ProfileSections;

@interface Profile : UITableViewController
@property (strong, nonatomic) User* user;
@end
