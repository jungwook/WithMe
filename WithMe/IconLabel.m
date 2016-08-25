//
//  IconLabel.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "IconLabel.h"

@interface IconLabel()
@property (nonatomic, strong) UIView* iconView;
@property (nonatomic) BOOL initialized;
@property (nonatomic) UIEdgeInsets textInsets;
@end

#define kSpaceBetweenIconAndLabel 4
#define kIconInsetSideWidth 0

@implementation IconLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeIconView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeIconView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeIconView];
    }
    return self;
}

- (void) initializeIconView
{
    if (self.initialized)
        return;
    
    __LF
    self.initialized = YES;
    
//    self.backgroundColor = colorWhite;
    self.textInsets = UIEdgeInsetsZero;
    self.iconView = [UIView new];
//    self.iconView.backgroundColor = colorBlue;
    [self addSubview:self.iconView];
    [self setImage:[UIImage imageNamed:@"photos"]];
}

- (void)setImage:(UIImage *)image
{
    __LF
    _image = image;
    
    self.iconView.layer.contents = (id) image.CGImage;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.contentsGravity = kCAGravityResizeAspect;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    __LF
    [self invalidateIntrinsicContentSize];
    
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsZero)
                    limitedToNumberOfLines:numberOfLines];
    
    CGFloat h = MAX(rect.size.height,0);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, (self.image != nil) ? h+kSpaceBetweenIconAndLabel: 0, 0, 0);
//    self.iconView.frame = CGRectMake(0, 0, h, h);
    self.textInsets = insets;
    
    rect.origin.x    -= insets.left;
    rect.origin.y    -= insets.top;
    rect.size.width  += (insets.left + insets.right);
    rect.size.height += (insets.top + insets.bottom);
    
    return rect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat h = MAX(self.bounds.size.height,2*kIconInsetSideWidth);
    self.iconView.frame = CGRectMake(kIconInsetSideWidth, kIconInsetSideWidth, h-2*kIconInsetSideWidth, h-2*kIconInsetSideWidth);
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

@end
