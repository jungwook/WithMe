//
//  ShadowView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ShadowView.h"
@interface ShadowView()
@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic) CGSize shadowOffset;
@end

@implementation ShadowView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.shadowRadius = 2.0f;
    self.shadowOpacity = 0.4f;
}

- (void)setOn:(BOOL)on
{
    _on = on;
    if (on) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = self.shadowRadius;
        self.layer.shadowOpacity = self.shadowOpacity;
        self.layer.shadowOffset = self.shadowOffset;
        
        [self layoutIfNeeded];
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    self.layer.shadowRadius = shadowRadius;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    _shadowOpacity = shadowOpacity;
    self.layer.shadowOpacity = shadowOpacity;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    _shadowOffset = shadowOffset;
    self.layer.shadowOffset = shadowOffset;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.on) {
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:[self.subviews firstObject].bounds cornerRadius:[self.subviews firstObject].radius].CGPath;
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
