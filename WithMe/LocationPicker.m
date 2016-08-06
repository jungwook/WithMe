//
//  LocationPicker.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationPicker.h"
#import "LocationPickerView.h"

@implementation LocationPicker

+ (instancetype)pickerOnView:(UIView*)view
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] initOnView:view onWindow:window];
    });
    
    [window addSubview:sharedFile];
    
    return sharedFile;
}

- (instancetype) initOnView:(UIView*)view onWindow:(UIWindow*)window
{
    self = [super initWithFrame:window.bounds];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOutside:)]];

        LocationPickerView *p = [[[NSBundle mainBundle] loadNibNamed:@"LocationPickerView" owner:self options:nil] firstObject];
        [self maskAndShadowPathOnPicker:p onView:view onWindow:window];
        [self addSubview:p];
    }
    return self;
}

- (void) maskAndShadowPathOnPicker:(LocationPickerView*)picker
                            onView:(UIView*)view
                          onWindow:(UIWindow*)window
{
    CGRect rect = [view convertRect:view.bounds toView:window];
    CGRect windowRect = window.bounds;
    
    CGFloat cx = CGRectGetMidX(rect), cy = CGRectGetMidY(rect);
    
    CGFloat sx = rect.origin.x, sy = rect.origin.y;
    CGFloat l = 0, t = 0, b = 0, r = 0, radius = 8, f = 0.3, i=7, indent = 10;
    CGFloat w = 300, h = 250;
    CGFloat x = 0, y = 0;
    
    CGFloat ls = sx, rs = CGRectGetWidth(windowRect)-(sx+rect.size.width), ts = sy, bs = CGRectGetHeight(windowRect)-(sy+rect.size.height);
    if (ls>rs && ls>ts && ls>bs) {
        f = 0.4;
        r = 8;
        x = sx-w-2;
        y = MAX(cy-f*h, 20);
        f = (cy-y)/h;
    }
    else if (rs > ls && rs > ts && rs > bs) {
        l = 8;
        f = 0.4;
        x = sx+rect.size.width+2;
        w = CGRectGetWidth(windowRect)-10-x;
        y = MAX(cy-f*h, 20);
        f = (cy-y)/h;
    }
    else if (ts > bs && ts > ls && ts > rs) {
        b = 8;
        x = (cx > CGRectGetMidX(windowRect)) ? CGRectGetWidth(windowRect) - (w+indent) : indent;
        y = MAX(sy - h, 20);
        h = sy - y -2;
        f = (cx-x)/w;
    }
    else {
        t = 8;
        x = (cx > CGRectGetMidX(windowRect)) ? CGRectGetWidth(windowRect) - (w+indent) : indent;
        y = 2 + sy + CGRectGetHeight(rect);
        f = (cx-x)/w;
    }

    CAShapeLayer *maskLayer = [CAShapeLayer new];
    CAShapeLayer *borderLayer = [CAShapeLayer new];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(l, t+radius)];
    [maskPath addQuadCurveToPoint:CGPointMake(l+radius, t) controlPoint:CGPointMake(l, t)];
    
    [maskPath addLineToPoint:CGPointMake(w*f-i, t)];
    [maskPath addLineToPoint:CGPointMake(w*f, MAX(t-i,0))];
    [maskPath addLineToPoint:CGPointMake(w*f+i, t)];
    
    [maskPath addLineToPoint:CGPointMake(w-r-radius, t)];
    [maskPath addQuadCurveToPoint:CGPointMake(w-r, t+radius) controlPoint:CGPointMake(w-r, t)];
    
    [maskPath addLineToPoint:CGPointMake(w-r, h*f-i)];
    [maskPath addLineToPoint:CGPointMake(MIN(w-r+i,w), h*f)];
    [maskPath addLineToPoint:CGPointMake(w-r, h*f+i)];
    
    [maskPath addLineToPoint:CGPointMake(w-r, h-b-radius)];
    [maskPath addQuadCurveToPoint:CGPointMake(w-radius-r, h-b) controlPoint:CGPointMake(w-r, h-b)];
    
    [maskPath addLineToPoint:CGPointMake(w*f-i, h-b)];
    [maskPath addLineToPoint:CGPointMake(w*f, MIN(h-(b-i), h))];
    [maskPath addLineToPoint:CGPointMake(w*f+i, h-b)];
    
    [maskPath addLineToPoint:CGPointMake(l+radius, h-b)];
    [maskPath addQuadCurveToPoint:CGPointMake(l, h-b-radius) controlPoint:CGPointMake(l, h-b)];
    
    [maskPath addLineToPoint:CGPointMake(l, h*f-i)];
    [maskPath addLineToPoint:CGPointMake(MAX(l-i,0), h*f)];
    [maskPath addLineToPoint:CGPointMake(l, h*f+i)];
    
    [maskPath addLineToPoint:CGPointMake(l, t+radius)];
    
    maskLayer.path = maskPath.CGPath;
    borderLayer.path = maskPath.CGPath;
    
    borderLayer.strokeColor = [view isKindOfClass:[UIButton class]] ? view.tintColor.CGColor : [UIColor blackColor].CGColor;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    [picker.layer addSublayer:borderLayer];
    
    picker.pickerView.layer.mask = maskLayer;
    picker.layer.shadowPath = maskPath.CGPath;
    picker.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    picker.layer.shadowOffset = CGSizeZero;
    picker.layer.shadowRadius = 4.0f;
    picker.layer.shadowOpacity = 0.4;

    picker.frame = CGRectMake(x, y, w, h);
    [self addSubview:picker];
}

- (void) tappedOutside:(id)sender
{
    __LF
    
    [self removeFromSuperview];
}
@end
