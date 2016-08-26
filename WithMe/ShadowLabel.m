//
//  ShadowLabel.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ShadowLabel.h"

@implementation ShadowLabel

- (id)initWithFrame:(CGRect)frame {
    if (![super initWithFrame:frame]) return nil;
    self.clipsToBounds = NO;
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colorValues[] = {0, 0, 0, .6};
    CGColorRef shadowColor = CGColorCreate(colorSpace, colorValues);
    CGSize shadowOffset = CGSizeZero;
    
    CGContextSetShadowWithColor (context, shadowOffset, 5 /* blur */, shadowColor);
    [super drawTextInRect:rect];
    
    CGColorRelease(shadowColor);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(context);
}
@end
