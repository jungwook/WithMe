//
//  AdCollectionCellV2.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollectionCellV2.h"
#import "NSDate+TimeAgo.h"

@interface AdCollectionCellV2()
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *agoLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *likedByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;

@end

@implementation AdCollectionCellV2

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self clearContents];
}

- (void)clearContents
{
    
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    self.imageView.image = nil;
    self.photoView.image = nil;
    
    [self.ad fetched:^{
        self.categoryLabel.text = ad.activity.category.name;
        self.activityLabel.text = ad.activity.name;
        self.distanceLabel.text = ad.location ? distanceString([ad.location distanceInKilometersTo:[User me].location]) : @"-- km";
        self.titleLabel.text = ad.title;
        self.agoLabel.text = ad.createdAt.timeAgoSimple;
        self.viewedByLabel.text = @(ad.viewedByCount).stringValue;
        self.likedByLabel.text = @(ad.likesCount).stringValue;
        
        [self.ad firstThumbnailImageLoaded:^(UIImage *image) {
            if (ad == self.ad) {
                self.imageView.image = image;
            }
        }];
        
        [self.ad userProfileThumbnailLoaded:^(UIImage *image) {
            if (ad == self.ad) {
                self.photoView.image = image;
                self.nicknameLabel.text = ad.user.nickname;
                self.initialsLabel.text = ad.user.initials;
            }
        }];
    }];
}

- (NSString*) initialsFrom:(NSString*)nickname
{
    //    return nickname.length > 0 ? [nickname substringToIndex:1] : @"?";
    NSMutableString *result = [NSMutableString string];
    [[nickname componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(obj){
            [result appendString:[((NSString *)obj) substringToIndex:1]];
        }
    }];
    return [[result substringToIndex:MIN(result.length, 2)] uppercaseString];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

@end
