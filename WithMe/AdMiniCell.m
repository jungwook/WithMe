//
//  AdMiniCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 16..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdMiniCell.h"

@interface AdMiniCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@end

@implementation AdMiniCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self clearCell];
}

- (void)clearCell
{
    self.photoView.image = nil;
    self.photoView.alpha = 0;
    self.categoryLabel.text = @"Loading";
    self.activityLabel.text = @"...";
    self.titleLabel.text = @"...";
}

- (void)setAd:(Ad *)ad
{
    if ([super.ad.objectId isEqualToString:ad.objectId]) {
        return;
    }

    super.ad = ad;
    [self clearCell];

    NSLog(@"FETCHING :%@ %s", ad.title, ad.dataAvailable ? "[Y]" : "[N]");
    [self.ad fetched:^{
        NSLog(@"AD %@ FETCHED1", ad.title);
        self.titleLabel.text = ad.title;
        self.categoryLabel.text = ad.activity.category.name;
        self.activityLabel.text = ad.activity.name;
        NSLog(@"AD %@ FETCHED2", ad.title);
        
        [ad firstThumbnailImageLoaded:^(UIImage *image) {
            NSLog(@"AD %@ FETCHED3", ad.title);
            if ([ad.objectId isEqualToString:super.ad.objectId]) {
                NSLog(@"AD %@ FETCHED4", ad.title);
                if (self.photoView.alpha == 0) {
                    NSLog(@"AD %@ FETCHED5", ad.title);
                    self.photoView.image = image;
                    showView(self.photoView, YES);
                }
                NSLog(@"AD %@ FETCHED6", ad.title);
            }
            else {
                NSLog(@"CELL SWITCHED:%@", ad.title);
            }
        }];
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
