//
//  AdCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCell.h"
@interface AdCell()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *bottomBox;
@end

@implementation AdCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.layer.cornerRadius = 5.0f;
    self.backgroundView.clipsToBounds = YES;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = YES;
    self.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    self.layer.shadowOpacity = 0.2f;
    self.layer.shadowRadius = 1.0f;
    self.clipsToBounds = NO;
    
//    self.bottomBox.layer.borderWidth = 1.f;
//    self.bottomBox.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    self.bottomBox.layer.shadowRadius = 1.0f;
    self.bottomBox.layer.shadowOffset = CGSizeZero;
    self.bottomBox.layer.shadowOpacity = 0.2f;
    self.bottomBox.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundView.bounds cornerRadius:5.0f].CGPath;
    self.bottomBox.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bottomBox.bounds].CGPath;
}


- (void)setActivity:(id)activity
{
    _activity = activity;

    if ([activity isKindOfClass:[NSString class]])
    {
        self.title.text = activity;
        self.title.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.title.textColor = colorBlue;
        self.title.shadowColor = [colorWhite colorWithAlphaComponent:0.8];
        self.title.shadowOffset = CGSizeMake(0, -1);
//        self.backgroundView.backgroundColor = colorWhite;
    }
    else if ([activity isKindOfClass:[NSDictionary class]]){
        self.title.text = activity[@"title"];
        self.title.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.title.shadowColor = [colorWhite colorWithAlphaComponent:0.8];
        self.title.shadowOffset = CGSizeMake(0, 1);
//        self.backgroundView.backgroundColor = colorWhite;
    }
    else {
        self.backgroundView.backgroundColor = [UIColor redColor];
        self.title.text = @"UNKNOWN";
    }
}

@end
