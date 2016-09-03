//
//  UserMediaView.h
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserMediaView;

@interface UserMediaView : UIImageView
@property (nonatomic, readonly) NSInteger index;
@property (nonatomic) IBInspectable CGFloat timePerImage;
@property (nonatomic) IBInspectable CGFloat changeImageTime;
@property (nonatomic) IBInspectable CGFloat animationTime;
@property (nonatomic, assign) User* user;
@property (nonatomic, assign) Ad* ad;

@end