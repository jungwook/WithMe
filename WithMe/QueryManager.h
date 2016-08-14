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
- (BOOL) query:(PFQuery* _Nonnull)query named:(NSString* _Nonnull)name;
- (PFQuery* _Nonnull) queryNamed:(NSString* _Nonnull)name;
- (NSArray* _Nonnull) itemsNamed:(NSString* _Nonnull)name;
- (void) setItems:(NSArray* _Nonnull)items named:(NSString* _Nonnull)name;
- (void) addItems:(NSArray* _Nonnull)items named:(NSString* _Nonnull)name;
@end
