//
//  AdCollectionCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCollectionCell.h"
#import "ShadowView.h"
#import "LocationManager.h"

@interface AdCollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIImageView *userMedia;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *initials;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *activity;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet ShadowView *shadowBack;
@property (strong, nonatomic) LocationManager *locationManager;

@end

@implementation AdCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.photo.radius = self.photo.bounds.size.height / 2.f;
    self.photo.clipsToBounds = YES;
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.backgroundColor = [UIColor clearColor];
    self.userMedia.clipsToBounds = YES;
    self.userMedia.contentMode = UIViewContentModeScaleAspectFill;
    
    self.initials.backgroundColor = colorWhite;
    self.initials.radius = self.photo.radius;
    self.initials.clipsToBounds = YES;
    self.initials.textAlignment = NSTextAlignmentCenter;
    self.shadowBack.on = YES;
    
//    self.userMedia.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.2].CGColor;
//    self.userMedia.layer.borderWidth = 1.0f;
//    self.userMedia.layer.cornerRadius = 2.0f;
    self.userMedia.layer.masksToBounds = YES;
    
    self.locationManager = [LocationManager new];
}

- (IBAction)viewProfile:(id)sender
{
    __LF
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewUserProfile:)]) {
        [self.delegate viewUserProfile:self.ad.user];
    }
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    
    self.userMedia.image = nil;
    self.photo.image = nil;
    
    self.userMedia.alpha = 0;
    self.photo.alpha = 1;
    
    [ad mediaAndUserReady:^{
        [ad.user mediaReady:^{
            self.title.text = ad.title;
            self.initials.text = [self initialsFrom:ad.user.nickname];
            self.category.text = ad.activity.category.name;
            self.activity.text = ad.activity.name;
            
            PFGeoPoint *userLocation = self.locationManager.location;
            self.distance.text = distanceString([userLocation distanceInKilometersTo:ad.location]);
            [S3File getDataFromFile:self.ad.user.profileMedia.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                self.photo.image = [UIImage imageWithData:data];
                [UIView animateWithDuration:0.1 animations:^{
                    self.photo.alpha = 1.0f;
                }];
            }];
            UserMedia *media = ad.media.firstObject;
            if (media) {
                [media fetched:^{
                    [S3File getDataFromFile:media.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                        self.userMedia.image = [UIImage imageWithData:data];
                        [UIView animateWithDuration:0.1 animations:^{
                            self.userMedia.alpha = 1.0f;
                        }];
                    }];
                }];
            }
        }];
    }];
}

- (NSString*) initialsFrom:(NSString*)nickname
{
    NSMutableString *result = [NSMutableString string];
    [[nickname componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(obj){
            [result appendString:[((NSString *)obj) substringToIndex:1]];
        }
    }];
    return [[result substringToIndex:MIN(result.length, 2)] uppercaseString];
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
