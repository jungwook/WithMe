//
//  AdsCellBasic.m
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdsCellBasic.h"
#import "UserMediaView.h"
#import "ShadowLabel.h"

@interface AdsCellBasic()
@property (weak, nonatomic) IBOutlet UserMediaView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation AdsCellBasic

-(void)setAd:(Ad *)ad
{
    super.ad = ad;
    
    [ad fetched:^{
        self.categoryLabel.text = [ad.activity.category.name uppercaseString];
        [ad firstThumbnailImageLoaded:^(UIImage *image) {
            if (self.ad == ad) {
                self.imageView.mainImage = image;
            }
        }];
    }];
}
@end
