//
//  ScrollingLabel.m
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ScrollingLabel.h"

@interface ScrollingLabel()
@property (nonatomic, strong) UILabel *scrollLabel;
@end

@implementation ScrollingLabel

CGRect      rectForString(NSString *string, UIFont *font, CGFloat maxWidth);

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];

    [super setText:@"CATEGORY"];
    self.clipsToBounds = YES;
    
    self.scrollLabel = [UILabel new];
    self.scrollLabel.font = self.font;
    self.scrollLabel.backgroundColor = [UIColor clearColor];
    self.scrollLabel.textColor = self.textColor;
    
    [self addSubview:self.scrollLabel];
}


- (void)setText:(NSString *)text
{
    [super setText:@""];
    self.scrollLabel.frame = rectForString(text, self.font, INFINITY);
    self.scrollLabel.text = text;
    
    CGFloat textWidth = CGRectGetWidth(self.scrollLabel.frame);
    CGFloat scrollDistance = MAX(textWidth - CGRectGetWidth(self.bounds), 0);

    if (scrollDistance > 0) {
        [self doScrollAnimationForDistance:250];
    }
    else {
        self.scrollLabel.transform = CGAffineTransformIdentity;
    }
}

- (void) doScrollAnimationForDistance:(CGFloat)distance
{
    if (self.scrollLabel.layer.animationKeys.count > 0)
    {
        [self.scrollLabel.layer removeAllAnimations];
    }
        
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-distance, 0, 0)];
    anim.duration = 2.0f;
    anim.fillMode = kCAFillModeForwards;
    anim.autoreverses = NO;
    anim.removedOnCompletion = NO;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.beginTime = 2.F;

    
    CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim2.duration = 1.5f;
    anim2.fillMode = kCAFillModeForwards;
    anim2.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    anim2.autoreverses = NO;
    anim2.removedOnCompletion = NO;
    anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim2.beginTime = 7.F;

    CAAnimationGroup *group = [CAAnimationGroup new];
    group.animations = @[anim, anim2];
    group.duration = anim2.duration + anim2.beginTime;
    group.removedOnCompletion = YES;
    group.autoreverses = NO;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.scrollLabel.layer addAnimation:group forKey:@"Scroll"];
}

@end
