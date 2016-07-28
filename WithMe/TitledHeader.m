//
//  TitledHeader.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "TitledHeader.h"
@interface TitledHeader()
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@end

@implementation TitledHeader

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setControlFontAndColor:self.headerTitle ratio:1.2f];
    self.backgroundColor = colorBlue;
}

- (void)setTitle:(NSString*)title
{
    self.headerTitle.text = title;
}

- (void) setControlFontAndColor:(id)control ratio:(CGFloat)ratio
{
    UIFont *font = appFont(20);
    if ([control respondsToSelector:@selector(font)]) {
        font = [control performSelector:@selector(font)];
    }
    if ([control isKindOfClass:[UIView class]]) {
        [control setRadius:10];
    }
    if ([control respondsToSelector:@selector(setTextColor:)]) {
        [control performSelector:@selector(setTextColor:) withObject:[UIColor whiteColor]];
    }
    if ([control respondsToSelector:@selector(setFont:)]) {
        [control performSelector:@selector(setFont:) withObject:appFont(ratio*[font pointSize])];
    }
    
}

@end
