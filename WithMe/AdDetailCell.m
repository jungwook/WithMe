//
//  AdDetailCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdDetailCell.h"
#import "IconLabel.h"

@import MapKit;

@interface AdDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IconLabel *likedBy;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UsersCollection *viewByUsers;
@end

@implementation AdDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setAd:(Ad *)ad
{
    _ad = ad;
    
    self.titleLabel.text = self.ad.title;
    self.likedBy.text = @(self.ad.likesCount).stringValue;
    self.introLabel.text = self.ad.intro;
    [self.introLabel layoutIfNeeded];
    
    if (self.ad.address && ![self.ad.address isEqualToString:@""]) {
        NSLog(@"ADDRESS is:%@", self.ad.address);
        self.addressLabel.text = self.ad.address;
    }
    else {
        getAddressForPFGeoPoint(self.ad.location, ^(NSString *address) {
            self.ad.address = address;
            self.addressLabel.text = address;
            [self.ad saveInBackground];
        });
    }

    self.viewByUsers.users = self.ad.viewedBy;
    self.viewByUsers.showUserDelegate = self;
    
    NSLog(@"INTROBOUNDS:%@", NSStringFromCGRect(self.introLabel.bounds));
}

- (void)viewUserProfile:(User *)user
{
    if (self.showUserDelegate && [self.showUserDelegate respondsToSelector:@selector(viewUserProfile:)]) {
        [self.showUserDelegate viewUserProfile:user];
    }
    NSLog(@"INTROBOUNDS:%@", NSStringFromCGRect(self.introLabel.bounds));
}

@end
