//
//  AdCollectionCellMini.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollectionCellMini.h"

@interface AdCollectionCellMini()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceInKiloLabel;
@property (weak, nonatomic) IBOutlet UILabel *kmLabel;

@end

@implementation AdCollectionCellMini
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self clearContents];
}

- (void)clearContents
{
}

UIImage* crop(UIImage *image, CGRect rect)
{
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [image scale]);
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    UIImage *cropped_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropped_image;
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    self.imageView.image = nil;
    
    [self.ad fetched:^{
        self.categoryLabel.text = ad.activity.category.name;
        self.activityLabel.text = ad.activity.name;
        self.titleLabel.text = ad.title;
        
        self.distanceInKiloLabel.text = ad.location ?
        [NSString stringWithFormat:@"%ld", (NSInteger)[ad.location distanceInKilometersTo:[User me].location]] : @"--";
        
        [self.ad firstThumbnailImageLoaded:^(UIImage *image) {
            if (ad == self.ad) {
                self.imageView.image = image;
                self.kmLabel.textColor = [colorWhite colorWithAlphaComponent:0.9];
                self.distanceInKiloLabel.textColor = [colorWhite colorWithAlphaComponent:0.9];
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
