//
//  RefreshControl.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "RefreshControl.h"

#define kRefreshTimeout 3.5f

@interface RefreshControl()
@property (nonatomic, strong) RefreshControlBlock completionBlock;
@end

@implementation RefreshControl

/**
 Allocate and intialize a new refreshControl and sets its refreshBlock
 
 @param refreshBlock handler to a refreshBlock of void^(RefreshControl* refreshControl) for when the collectionView / tableView is pulled is pulled.
 
 @return instanceType of a new refreshControl
 */


+ (instancetype)refreshControlWithCompletionBlock:(RefreshControlBlock)refreshBlock
{
    return [[RefreshControl alloc] initWithCompletionBlock:refreshBlock];
}

- (instancetype)initWithCompletionBlock:(RefreshControlBlock)completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
        [self addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)refreshPage
{
    if (self.completionBlock) {
        self.completionBlock(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self isRefreshing]) {
                [self endRefreshing];
            }
        });
    }
}
@end
