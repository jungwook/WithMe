//
//  Notifications.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ActionBlock)(id actionParams);


@interface Notifications : NSObject
+ (void)notify:(id)notification object:(id)object;
- (void)setNotification:(id)notification forAction:(ActionBlock)notificationActionBlock;
- (void)removeNotification:(id)notification;
@end
