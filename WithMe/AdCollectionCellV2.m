//
//  AdCollectionCellV2.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollectionCellV2.h"

@interface AdCollectionCellV2()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likedByIcon;
@property (weak, nonatomic) IBOutlet UIImageView *viewedByIcon;

@end

@implementation AdCollectionCellV2

- (void)setAd:(Ad *)ad
{
    super.ad = ad;
    self.imageView.image = nil;
    
    self.viewedByIcon.tintColor = kAppColor;
    self.likedByIcon.tintColor = kAppColor;
    
    self.categoryLabel.backgroundColor = kAppColor;
    self.activityLabel.backgroundColor = kAppColor;
    self.titleLabel.textColor = kAppColor.darkerColor;
    
    [self.ad fetched:^{
        self.categoryLabel.text = ad.activity.category.name;
        self.activityLabel.text = ad.activity.name;
        self.titleLabel.text = ad.title;
        
        [self.ad firstThumbnailImageLoaded:^(UIImage *image) {
            if (ad == self.ad) {
                self.imageView.image = image;
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
