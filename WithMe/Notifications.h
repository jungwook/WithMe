//
//  Notifications.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ActionBlock)(id actionParams);

#define kNotifyAdSelected @"NotifyAdSelected"
#define kNotifyCategorySelected @"NotifyCategorySelected"
#define kNotifyCategoriesInitialized @"NotifyCategoriesInitialized"
#define kNotifyUserSaved @"NotifyUserSaved"
#define kNotifyProfileMediaChanged @"NotifyProfileMediaChanged"
#define kNotifyUserViewedAd @"NotifyUserViewedAd"
#define kNotifyUserLikesAd @"NotifyUserLikesAd"
#define kNotifyUserUnlikesAd @"NotifyUserUnlikesAd"
#define kNotifyUserMediaSaved @"NotifyUserMediaSaved"

@interface Notifications : NSObject
+ (void)notify:(id)notification object:(id)object;
- (void)setNotification:(id)notification forAction:(ActionBlock)notificationActionBlock;
- (void)removeNotification:(id)notification;
@end
