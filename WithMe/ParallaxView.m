//
//  ParallaxView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ParallaxView.h"

@interface ParallaxView()
@property (nonatomic) CGFloat navigationBarHeight;
@property (nonatomic) CGFloat navigationBarOffset;
@property (weak, nonatomic) id <UIScrollViewDelegate> parentScrollViewDelegate;
@end

@implementation ParallaxView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.navigationBarHeight = 44;
    self.navigationBarOffset = 20;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    CGFloat h = CGRectGetHeight(self.bounds), w = CGRectGetWidth(self.bounds);
    
    maskLayer.frame = CGRectMake(0, -2*h, 2*w, 3*h);
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.layer.mask = maskLayer;
}

- (void)setNavigationBarProperties:(UINavigationBar *)bar
{
    self.navigationBarOffset = bar.frame.origin.y;
    self.navigationBarHeight = bar.frame.size.height;
    
}

- (void)setScrollOffset:(UIScrollView*)scrollView
{
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat offset = self.navigationBarOffset+self.navigationBarHeight;
    CGFloat biggerBy = (-offset-scrollOffset);
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat vH = CGRectGetHeight(view.bounds);
        CGFloat scale = MAX((vH+biggerBy)/vH,1);
        
        CATransform3D translate = CATransform3DMakeTranslation(0, -biggerBy, 0);
        CATransform3D transform = CATransform3DScale(CATransform3DMakeTranslation(0, -biggerBy/2, 0), scale, scale, 1);
        
        if (view.tag > 0) {
            if ( scrollOffset > -self.navigationBarHeight) {
                view.layer.transform = CATransform3DIdentity;
            }
            else {
                if (view.tag == 1) {
                    view.layer.transform = translate;
                }
                if (view.tag == 2) {
                    view.layer.transform = transform;
                }
            }
        }
    }];
}


@end
