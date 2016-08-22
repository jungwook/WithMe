//
//  IndentedLabel.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "IndentedLabel.h"
#define kIndentWidth 8

@interface IndentedLabel()
@end

@implementation IndentedLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.textInsets = UIEdgeInsetsMake(0, kIndentWidth, 0, kIndentWidth);
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textInsets = UIEdgeInsetsMake(0, kIndentWidth, 0, kIndentWidth);
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    UIEdgeInsets insets = self.textInsets;
    [self invalidateIntrinsicContentSize];
    
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)
                    limitedToNumberOfLines:numberOfLines];
    
    rect.origin.x    -= insets.left;
    rect.origin.y    -= insets.top;
    rect.size.width  += (insets.left + insets.right);
    rect.size.height += (insets.top + insets.bottom);
    
    return rect;
}

- (void)setTextInsets:(UIEdgeInsets)textInsets
{
    _textInsets = textInsets;
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2.0f;
    self.layer.masksToBounds = YES;
}
@end
