//
//  AdButton.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdButton.h"
#import "ShadowView.h"


@interface AdButton()
@end

@implementation AdButton

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (CAAnimation*) shrinkAnimation
{
    
    CABasicAnimation *ta1 =[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    ta1.duration = 0.1;
    ta1.repeatCount = 1;
    ta1.autoreverses = YES;
    ta1.fromValue = @(1);
    ta1.toValue = @(0.99);
    ta1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    ta1.removedOnCompletion = YES;
    
    return ta1;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.layer addAnimation:[self shrinkAnimation] forKey:nil];
    
    if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(buttonSelected:)]) {
        [self.buttonDelegate buttonSelected:self.index];
    }
}

@end
