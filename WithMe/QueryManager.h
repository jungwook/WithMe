//
//  QueryManager.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QueryBlock)(NSArray* _Nullable objects);

@interface QueryManager : NSObject
+ (void) query:(PFQuery* _Nonnull)query objects:(_Nonnull QueryBlock)block;
@end
