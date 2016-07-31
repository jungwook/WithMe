//
//  UserCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 30..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserCell.h"

@interface UserCell()
@property (weak, nonatomic) IBOutlet UIView *photo;

@end

@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.photo.radius = self.photo.bounds.size.width / 2.0f;
}

@end
