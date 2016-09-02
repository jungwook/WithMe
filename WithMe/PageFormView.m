//
//  PageFormView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PageFormView.h"

@interface PageFormView()

@end

@implementation PageFormView

+ (instancetype) pageFormView
{
    return [PageFormView new];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGRect frame = [UIScreen mainScreen].bounds;
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        UIVisualEffectView *vev = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        vev.frame = frame;
        [self addSubview:vev];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
