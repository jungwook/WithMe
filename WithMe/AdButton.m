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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buttonImageView;
@property (weak, nonatomic) id<AdButtonDelegate> buttonDelegate;
@property (nonatomic) NSInteger index;
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

- (void)setButtonIndex:(NSInteger)index title:(NSString*)title subTitle:(NSString*)subTitle coverImage:(UIImage*)image buttonDelegate:(id)delegate
{
    self.titleLabel.text = title;
    self.subTitleLabel.text = subTitle;
    self.buttonImageView.image = image;
    self.index = index;
    self.buttonDelegate = delegate;
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
