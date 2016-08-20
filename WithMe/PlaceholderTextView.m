//
//  PlaceholderTextView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PlaceholderTextView.h"

@interface PlaceholderTextView()
@property (nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation PlaceholderTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _placeholder = @"Please enter a brief introduction";
    }
    return self;
}
- (void)awakeFromNib
{
    self.placeholderLabel = [UILabel new];
    [super awakeFromNib];
    self.delegate = self;
    
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    self.placeholderLabel.text = self.placeholder;
    
    [self addSubview:self.placeholderLabel];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeholderLabel.text = self.placeholder;
    
    [self setNeedsLayout];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.placeholderLabel.alpha = [textView.text isEqualToString:@""];
    }];
}

- (void)layoutSubviews
{
    __LF
    [super layoutSubviews];
    
    CGSize size = [self.placeholderLabel intrinsicContentSize];
    self.placeholderLabel.frame = CGRectMake(5, 8, size.width, size.height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
