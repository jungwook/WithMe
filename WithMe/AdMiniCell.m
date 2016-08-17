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

    [self.ad fetched:^{
        self.titleLabel.text = ad.title;
        self.categoryLabel.text = ad.activity.category.name;
        self.activityLabel.text = ad.activity.name;
        
        [ad firstThumbnailImageLoaded:^(UIImage *image) {
            if ([ad.objectId isEqualToString:super.ad.objectId]) {
                if (self.photoView.alpha == 0) {
                    self.photoView.image = image;
                    showView(self.photoView, YES);
                }
            }
            else {
//                NSLog(@"CELL SWITCHED:%@", ad.title);
            }
        }];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.layer addAnimation:buttonPressedAnimation() forKey:nil];
}


@end
