//
//  AdPostCellV2.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdPostCellV2.h"
#import "NSDate+TimeAgo.h"
#import "LocationManager.h"
#import "MediaView.h"
#import "ImagePanel.h"

@interface AdPostCellV2()
@property (weak, nonatomic) IBOutlet UIView *backPane;
@property (weak, nonatomic) IBOutlet UIView *likeIcon;
@property (weak, nonatomic) IBOutlet UIView *photo;
@property (weak, nonatomic) IBOutlet UIView *map;
@property (weak, nonatomic) IBOutlet ImagePanel *imagePane;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *agoLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *loadedImages;
@end

@implementation AdPostCellV2

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backPane.backgroundColor = [UIColor clearColor];
    self.imagePane.clipsToBounds = YES;
    self.photo.clipsToBounds = YES;
    self.map.clipsToBounds = YES;
    
    self.likeIcon.backgroundColor = [UIColor clearColor];
    setImageOnView([UIImage imageNamed:@"like grey"], self.likeIcon);
    self.locationManager = [LocationManager new];
    
    self.photo.radius = 15;
    self.imagePane.backgroundColor = [UIColor clearColor];
    self.imagePane.layer.cornerRadius = 5.0f;
    self.imagePane.layer.masksToBounds = YES;

}

- (void) initializeDefaultValues
{
    self.titleLabel.text = @"Loading...";
    self.categoryLabel.text = @"Loading...";
    self.addressLabel.text = @"Not set";
    self.distanceLabel.text = @"...";
    self.likeLabel.text = @"0";
    
    [self.imagePane.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.loadedImages = [NSMutableArray array];
}

- (void) setAd:(Ad *)ad
{
    [self initializeDefaultValues];
    
    _ad = ad;
    User *user = self.ad.user;
    
    [user fetched:^{
        self.nicknameLabel.text = user.nickname;
        self.genderLabel.text = user.genderCode;
        
        [user profileMediaThumbnailLoaded:^(UIImage *image) {
            drawImage(image, self.photo);
        }];
    }];
    self.titleLabel.text = ad.title;
    self.categoryLabel.text = [[[[User categoryForEndCategory:ad.activity.category.name] stringByAppendingString:@" #"] stringByAppendingString:ad.activity.category.name] uppercaseString];
    self.agoLabel.text = ad.updatedAt.timeAgoSimple;
//    self.distanceLabel.text = ad.location ? distanceString([self.locationManager.location distanceInKilometersTo:ad.location]) : @"";

    [self loadAdMedia:ad];
}

- (void) loadAdMedia:(Ad*)ad
{
    [self.imagePane clearAllContents];
    
    __block NSUInteger count = ad.media.count;
    NSMutableArray *loadedImages = [NSMutableArray arrayWithCapacity:count];
    [ad.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
        [S3File getDataFromFile:media.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            [loadedImages addObject:[UIImage imageWithData:data]];
            if (--count == 0) {
                [self.imagePane setImages:loadedImages];
            }
        }];
    }];
}


@end
