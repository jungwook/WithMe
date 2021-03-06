//
//  AdDetailCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdDetailCell.h"
#import "IconLabel.h"
#import "UIImage+AverageColor.h"

@interface AdDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IconLabel *likedBy;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UsersCollection *viewByUsers;
@end

@implementation AdDetailCell

static NSString* const kAddressNotFoundString = @"Address not found";
static NSString* const kLocationNotFoundString = @"Location not found";


- (void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)setAd:(Ad *)ad
{
    _ad = ad;
    
    self.titleLabel.text = self.ad.title;
    self.introLabel.text = self.ad.intro;
    [self.introLabel layoutIfNeeded];
    
    self.viewByUsers.showUserDelegate = self;
}

- (void) drawMapWithSpanInMeters:(double)span location:(PFGeoPoint*)location
{
    __LF
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.latitude, location.longitude), span, span);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.mapImageView.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapImageView.image = [self overlayOnMapImage:snapshot.image];
        });
    }];
}

- (UIImage*) overlayOnMapImage:(UIImage*)mapImage
{
    UIImage *redPoint = [[UIImage imageNamed:@"location"] imageWithColor:[UIColor redColor]];
    CGFloat sx = MIN(mapImage.size.width, mapImage.size.height) * 0.1f;
    CGFloat sy = sx * redPoint.size.height / redPoint.size.width;
    CGFloat w = mapImage.size.width, h = mapImage.size.height;
    CGRect pointRect = CGRectMake((w-sx)/2, (h-sy)/2, sx, sy);
    
    UIGraphicsBeginImageContextWithOptions(mapImage.size, NO, [UIScreen mainScreen].scale);
    [mapImage drawAtPoint:CGPointZero];
    [redPoint drawInRect:pointRect];
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return overlayImage;
}

- (void)viewUserProfile:(User *)user
{
    if (self.showUserDelegate && [self.showUserDelegate respondsToSelector:@selector(viewUserProfile:)]) {
            [self.showUserDelegate viewUserProfile:user];
    }
}

@end
