//
//  WithMeEngine.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ActivitiesReadyBlock)(void);

@interface WithMeEngine : NSObject
@property (nonatomic, copy) ActivitiesReadyBlock activitiesBlock;
+ (instancetype) engine;
+ (NSString*) version;
@end
