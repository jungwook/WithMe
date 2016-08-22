//
//  UIView(Parallax).m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+Parallax.h"

NSString const *UIButton_parallaxKey = @"UIButton_parallaxKey";

@implementation UIView(Parallax)
@dynamic displayLink;

-(CADisplayLink *) displayLink
{
    CADisplayLink* dpl = objc_getAssociatedObject(self, &UIButton_parallaxKey);
    if (!dpl) {
        dpl = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplayLink)];
    }
    return dpl;
}

- (void)setDisplayLink:(CADisplayLink *)displayLink
{
    objc_setAssociatedObject(self, &UIButton_parallaxKey, displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)enableParallax
{
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)disableParallax
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void) updateDisplayLink
{
    static CGFloat oldY = 0, anchor = 0;
    CGRect rect = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
    if (anchor == 0) {
        anchor = CGRectGetMinY(rect);
    }
    CGFloat y = CGRectGetMinY(rect), h = CGRectGetHeight(self.bounds);
    CGFloat d = y - anchor, f = MAX(d/h+1.0f, 1.0f);
    
    if (y!= oldY ) {
        oldY = y;
        
        CATransform3D transform = CATransform3DMakeScale(f, f, 1);
        
        self.layer.transform = transform;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
