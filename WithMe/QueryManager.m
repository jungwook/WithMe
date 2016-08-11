//
//  QueryManager.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "QueryManager.h"
@interface QueryManager()
@end

@implementation QueryManager

+ (void) query:(PFQuery*)query objects:(nonnull QueryBlock)block
{
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
            block(nil);
        }
        else {
            block(objects);
        }
    }];
}

@end
