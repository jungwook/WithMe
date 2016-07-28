//
//  UserProfileHeader.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileHeader : UICollectionReusableView
@property (nonatomic, weak) User* user;
- (void)setTitle:(NSString*)title;
@end
