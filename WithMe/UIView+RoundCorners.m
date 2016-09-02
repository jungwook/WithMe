//
//  UIView_RoundCorners.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+RoundCorners.h"


NSString const *UIViewRoundCorners_radiusKey = @"UIViewRoundCorners_radiusKey";
NSString const *UIViewRoundCorners_circleKey = @"UIViewRoundCorners_circleKey";

@implementation UIView(RoundCorners)
@dynamic radius, circle;

- (void) makeCircle:(BOOL)makeCircle
{
    self.radius = makeCircle ? MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f : 0;
    [self layoutIfNeeded];
}

-(void) setRadius:(CGFloat)radius
{
    NSNumber *number = [NSNumber numberWithDouble:radius];
    objc_setAssociatedObject(self, &UIViewRoundCorners_radiusKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.layer.cornerRadius = radius;
}

-(CGFloat) radius
{
    NSNumber *number = objc_getAssociatedObject(self, &UIViewRoundCorners_radiusKey);
    return number.floatValue;
}

- (void)setCircle:(BOOL)circle
{
    NSNumber *number = [NSNumber numberWithDouble:circle];
    objc_setAssociatedObject(self, &UIViewRoundCorners_circleKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.layer.cornerRadius = circle ? MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f : 0;
}

- (BOOL)circle
{
    NSNumber *number = objc_getAssociatedObject(self, &UIViewRoundCorners_circleKey);
    return number.boolValue;
}

@end
