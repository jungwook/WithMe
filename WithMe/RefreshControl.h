//
//  RefreshControl.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RefreshControl;

typedef void (^RefreshControlBlock)(RefreshControl* refreshControl);

@interface RefreshControl : UIRefreshControl

+ (instancetype)refreshControlWithCompletionBlock:(RefreshControlBlock)refreshBlock;

@end
