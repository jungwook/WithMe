//
//  AdCategoryCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCategoryCell.h"

@interface AdCategoryCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation AdCategoryCell

-(void)setCategory:(Category *)category
{
    self.titleLabel.text = [category.name uppercaseString];
    [S3File getDataFromFile:category.imageFile dataBlock:^(NSData *data) {
        self.imageView.image = [UIImage imageWithData:data];
    }];
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
}

@end
