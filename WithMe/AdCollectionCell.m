//
//  AdCollectionCellV2.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollectionCell.h"
#import "NSDate+TimeAgo.h"
#import "Notifications.h"

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
@property (weak, nonatomic) IBOutlet UIImageView *viewByIcon;
@property (weak, nonatomic) IBOutlet UIImageView *likedByIcon;
@property (nonatomic) NSUInteger likes;
@property (nonatomic) NSUInteger views;
@end

@implementation AdCollectionCellV2

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self clearContents];
}

- (void)clearContents
{
    self.likes = -1;
    self.views = -1;
    
    self.viewByIcon.image = [self.viewByIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.viewByIcon setTintColor:colorWhite];
    
    self.likedByIcon.image = [self.likedByIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.likedByIcon setTintColor:colorWhite];
}

- (void)setAd:(Ad *)ad
{
    super.ad = ad;
    self.imageView.image = nil;
    self.photoView.image = nil;
    
    [self.ad fetched:^{
        self.categoryLabel.text = ad.activity.category.name;
        self.activityLabel.text = ad.activity.name;
        self.distanceLabel.text = ad.location ? distanceString([ad.location distanceInKilometersTo:[User me].location]) : @"-- km";
        self.titleLabel.text = ad.title;
        self.agoLabel.text = ad.createdAt.timeAgoSimple;
        
        if (ad == self.ad && self.likes != -1) {
            self.likedByLabel.text = @(self.likes).stringValue;
        } else {
            [self.ad countLikes:^(NSUInteger count) {
                self.likedByLabel.text = @(count).stringValue;
                self.likes = count;
            }];
        }
        if (ad == self.ad && self.views != -1) {
            self.viewedByLabel.text = @(self.views).stringValue;
        }
        else {
            [self.ad countViewed:^(NSUInteger count) {
                self.viewedByLabel.text = @(count).stringValue;
                self.views = count;
            }];
        }
        
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

- (IBAction)viewUser:(id)sender
{
    __LF
    if (self.userSelectedBlock) {
        self.userSelectedBlock(self.ad.user);
    }
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
