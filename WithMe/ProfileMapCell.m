//
//  ProfileMapCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ProfileMapCell.h"

@implementation ProfileMapCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.backgroundView.backgroundColor = [UIColor redColor];
    self.backgroundColor = [UIColor blueColor];
}

@end
