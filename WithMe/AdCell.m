//
//  AdCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 16..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCell.h"
#import "LocationManager.h"
#import "NSDate+TimeAgo.h"

@interface AdCell()
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *agoLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;
@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewedByLabel;

@end

@implementation AdCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self clearCell];
}

- (void) clearCell
{
    self.categoryLabel.text = @"Loading";
    self.activityLabel.text = @"...";
    self.distanceLabel.text = @"?";
    self.agoLabel.text = @"";
    
    self.mediaView.image = nil;
    self.mediaView.alpha = 0;
    
    self.photoView.image = nil;
    self.photoView.alpha = 0;
    self.titleLabel.text = @"...";
    
    self.canvas.alpha = 1;
}

- (void)setAd:(Ad *)ad
{
    if ([super.ad.objectId isEqualToString:ad.objectId]) {
        return;
    }
        
    super.ad = ad;

    [self clearCell];
    
    [ad fetched:^{
        [ad.user fetched:^{
            self.titleLabel.text = ad.title;
            self.initialsLabel.text = [self initialsFrom:ad.user.nickname];
            self.categoryLabel.text = [ad.activity.category.name uppercaseString];
            self.activityLabel.text = [ad.activity.name capitalizedString];
            self.viewedByLabel.text = @(ad.viewedBy.count).stringValue;
            self.nicknameLabel.text = ad.user.nickname;
            self.agoLabel.text = ad.createdAt.timeAgo;
            [ad userProfileThumbnailLoaded:^(UIImage *image) {
                NSLog(@"USER IMAGE:%@", image);
                if ([ad.objectId isEqualToString:super.ad.objectId]) {
                    if (self.photoView.alpha == 0) {
                        self.photoView.image = image;
                        showView(self.photoView, YES);
                    }
                }
                else {
                    //                    NSLog(@"===CELL SWITCHED:%@", ad.title);
                }
            }];
            [ad firstThumbnailImageLoaded:^(UIImage *image) {
                if ([ad.objectId isEqualToString:super.ad.objectId]) {
                    if (self.mediaView.alpha == 0) {
                        self.mediaView.image = image;
                        showView(self.mediaView, YES);
                    }
                }
                else {
                    //                    NSLog(@"===CELL SWITCHED:%@", ad.title);
                }
            }];
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

- (IBAction)viewUser:(id)sender {
    __LF
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewUserProfile:)]) {
        [self.delegate viewUserProfile:self.ad.user];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

@end
