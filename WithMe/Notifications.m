//
//  Notifications.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Notifications.h"
@interface Notifications()
@property (nonatomic, strong) NSMutableDictionary *actions;
@end

@implementation Notifications

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actions = [NSMutableDictionary dictionary];
        self.on = YES;
    }
    return self;
}

+ (void)notify:(id)notification object:(id)object
{
    [[Notifications new] notify:notification object:object];
}

- (void)notify:(id)notification object:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object];
}

- (void)setNotification:(id)notification forAction:(ActionBlock)notificationActionBlock
{
    if (notification && notificationActionBlock) {
        [self.actions setObject:notificationActionBlock forKey:notification];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notify:)
                                                     name:notification
                                                   object:nil];
    }
}

- (void)removeNotification:(id)notification
{
    if (notification) {
        [self.actions removeObjectForKey:notification];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:notification
                                                      object:nil];
    }
}

- (void) notify:(NSNotification*)notification
{
    NSLog(@"NOTIF:%@", self.actions);
    ActionBlock action = [self.actions objectForKey:notification.name];
    if (action && self.on) {
        action(notification.object);
    }
}

@end
