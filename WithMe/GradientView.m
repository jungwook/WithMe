//
//  GradientView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView
+(Class) layerClass {
    __LF
    return [CAGradientLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    __LF
    self = [super initWithCoder:aDecoder];
    if (self) {
        ((CAGradientLayer*)self.layer).colors = @[
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor,
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor,
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2].CGColor,
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.45].CGColor,
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65].CGColor,
                                                  ];
        ((CAGradientLayer*)self.layer).locations = @[
                                                     [NSNumber numberWithFloat:0.5f],
                                                     [NSNumber numberWithFloat:0.8f],
                                                     [NSNumber numberWithFloat:0.9f],
                                                     [NSNumber numberWithFloat:0.95f],
                                                     [NSNumber numberWithFloat:1.0f],
                                                     ];
        ((CAGradientLayer*)self.layer).masksToBounds = YES;
    }
    return self;
}
@end
