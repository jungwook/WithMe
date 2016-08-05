//
//  MapView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MapView.h"

@implementation MapView

+ (instancetype) new
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] init];
    });
    return sharedFile;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

@end
