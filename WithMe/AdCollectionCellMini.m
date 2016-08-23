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
//                id title = [[ad.activity.category.name stringByAppendingString:@" - "] stringByAppendingString:ad.activity.name];
//                UIColor *textColor = [self readableForegroundColorForBackgroundColor:[image averageColorWithPoints:20] title:title];
                
                UIColor *textColor = [self lightOrDardColor:[image averageColorInRect:self.distanceInKiloLabel.frame withPoints:20]];
                
                self.kmLabel.textColor = textColor;
                self.distanceInKiloLabel.textColor = textColor;
            }
        }];
    }];
}

- (CGRect) croppedFrame:(CGRect)frame size:(CGFloat)size
{
    CGFloat w = CGRectGetWidth(frame), h = CGRectGetHeight(frame), x = CGRectGetMinX(frame), y = CGRectGetMinY(frame);
    return CGRectMake(x+(w-size)/2.0f, y+(h-size)/2.0f, size, size);
}

- (UIColor *)lightOrDardColor:(UIColor*)color
{
    return [self readableForegroundColorForBackgroundColor:color title:nil];
}

- (UIColor *)readableForegroundColorForBackgroundColor:(UIColor*)backgroundColor title:(id)title
{
    CGFloat r, g, b, a;
    
    [backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    
    CGFloat darknessScore = 255.f*(r*587+g*114+b*299)/1000.0f;
    
    if (title) {
        NSLog(@"COLOR:%@ [%@] SCORE:%f", backgroundColor, title, darknessScore);
    }
    
    if (darknessScore >= 200) {
        return [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    else {
        return [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.layer addAnimation:buttonPressedAnimation() forKey:nil];
}



@end
