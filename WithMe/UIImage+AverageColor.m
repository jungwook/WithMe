//
//  UIImage+AverageColor.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+AverageColor.h"

@implementation UIImage(AverageColor)

- (UIColor *)averageColor
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = self.size;
    
    CGFloat x = CGRectGetMidX(frame);
    CGFloat y = CGRectGetMidY(frame);
    
    return [self colorAtPosition:CGPointMake(x, y)];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIColor *)averageColorInRect:(CGRect)frame withPoints:(NSUInteger)points
{
    CGFloat r, g, b, a;
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    
    CGFloat mx = CGRectGetMidY(frame), my = CGRectGetMidY(frame);
    CGFloat len = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))/2.0f;
    
    for (int i=0; i<points; i++) {
        CGFloat lx = (arc4random()%((int) (2*len)))-len;
        CGFloat ly = (arc4random()%((int) (2*len)))-len;
        CGFloat x = mx + lx;
        CGFloat y = my + ly;
        UIColor *color = [self colorAtPosition:CGPointMake(x, y)];
        [color getRed:&r green:&g blue:&b alpha:&a];
        red += r;
        green += g;
        blue += b;
        alpha += a;
    }
    
    //    NSLog(@"R:%f G:%f B:%f A:%f", red, green, blue, alpha);
    
    return [UIColor colorWithRed:red/(CGFloat)points
                           green:green/(CGFloat)points
                            blue:blue/(CGFloat)points
                           alpha:alpha/(CGFloat)points];
}

- (UIColor *)averageColorWithPoints:(NSUInteger) points
{
    CGFloat r, g, b, a;
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = self.size;
    
    CGFloat mx = CGRectGetMidY(frame), my = CGRectGetMidY(frame);
    CGFloat len = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))/2.0f;
    
    for (int i=0; i<points; i++) {
        CGFloat lx = (arc4random()%((int) (2*len)))-len;
        CGFloat ly = (arc4random()%((int) (2*len)))-len;
        CGFloat x = mx + lx;
        CGFloat y = my + ly;
        UIColor *color = [self colorAtPosition:CGPointMake(x, y)];
        [color getRed:&r green:&g blue:&b alpha:&a];
        red += r;
        green += g;
        blue += b;
        alpha += a;
    }
    
//    NSLog(@"R:%f G:%f B:%f A:%f", red, green, blue, alpha);
    
    return [UIColor colorWithRed:red/(CGFloat)points
                           green:green/(CGFloat)points
                            blue:blue/(CGFloat)points
                           alpha:alpha/(CGFloat)points];
}

- (UIColor *)colorAtPosition:(CGPoint)position
{
    
    CGRect sourceRect = CGRectMake(position.x, position.y, 1.f, 1.f);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, sourceRect);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *buffer = malloc(4);
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(buffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), imageRef);
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    CGFloat r = buffer[0] / 255.f;
    CGFloat g = buffer[1] / 255.f;
    CGFloat b = buffer[2] / 255.f;
    CGFloat a = buffer[3] / 255.f;
    
    free(buffer);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
