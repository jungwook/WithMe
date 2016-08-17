//
//  PostAd.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PostAd.h"
#import "IndentedLabel.h"
#import "ParallaxView.h"
#import "LocationManager.h"
#import "LocationPicker.h"

@interface PostAd ()
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@property (weak, nonatomic) IBOutlet UIButton *paymentMeButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentYouButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentDutchButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentNoneButton;
@property (weak, nonatomic) IBOutlet UIImageView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *ourParticipantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yourParticipantsLabel;
@property (weak, nonatomic) IBOutlet UIView *paymentBack;

@property (strong, nonatomic) Ad *ad;
@property (nonatomic) NSUInteger ourParticipants;
@property (nonatomic) NSUInteger yourParticipants;
@end

@implementation PostAd

//typedef NS_OPTIONS(NSUInteger, PaymentType)
//{
//    kPaymentTypeNone = 0,
//    kPaymentTypeIBuy,
//    kPaymentTypeYouBuy,
//    kPaymentTypeDutch
//};

enum {
    kTagPaymentNone = 1000,
    kTagPaymentMe,
    kTagPaymentYou,
    kTagPaymentDutch,
};

enum {
    kTagButtonOurParticipants = 0,
    kTagButtonYourParticipants,
};

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.ad = [Ad object];
    self.ourParticipants = 1;
    self.yourParticipants = 1;
}

- (void)setOurParticipants:(NSUInteger)ourParticipants
{
    _ourParticipants = ourParticipants;
    self.ourParticipantsLabel.text = [NSString stringWithFormat:@"We're %ld", ourParticipants];
    self.ad.ourParticipants = ourParticipants;
}

- (void)setYourParticipants:(NSUInteger)yourParticipants
{
    _yourParticipants = yourParticipants;
    self.yourParticipantsLabel.text = [NSString stringWithFormat:@"We're looking for %ld more", yourParticipants];
    self.ad.yourParticipants = yourParticipants;
}

- (IBAction)tappedOutside:(id)sender
{
    [self.tableView endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.parallax.scrollOffset = scrollView.contentOffset.y;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Me
    self.nicknameLabel.text = [User me].nickname;
    self.genderLabel.text = [User me].genderTypeString;
    self.ageLabel.text = [User me].age;
    
    [[User me] profileMediaThumbnailLoaded:^(UIImage *image) {
        self.photoView.image = image;
        showView(self.photoView, YES);
    }];
    
    //Payment
    [self selectedPaymentType:[self.paymentBack viewWithTag:kTagPaymentNone]];
    
    //Ad
    self.ad.user = [User me];
    self.ad.ourParticipants = 1;
    self.ad.yourParticipants = 1;
    
    //Initial Location
    [self drawMapWithSpanInMeters:2500 location:[LocationManager new].location];
    getAddressForCLLocation([LocationManager new].currentLocation, ^(NSString *address) {
        self.addressLabel.text = address;
    });
}

- (void) drawMapWithSpanInMeters:(double)span location:(PFGeoPoint*)location
{
    __LF
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.latitude, location.longitude), span, span);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.mapView.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapView.image = snapshot.image;
        });
    }];
}


- (IBAction)increaseParticipants:(UIButton *)sender {
    if (sender.tag == kTagButtonOurParticipants) {
        self.ourParticipants++;
    }
    if (sender.tag == kTagButtonYourParticipants) {
        self.yourParticipants++;
    }
    [sender.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

- (IBAction)decreaseParticipants:(UIButton *)sender
{
    if (sender.tag == kTagButtonOurParticipants) {
        self.ourParticipants = MAX(self.ourParticipants-1, 1);
    }
    if (sender.tag == kTagButtonYourParticipants) {
        self.yourParticipants = MAX(self.yourParticipants-1, 1);
    }
    [sender.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

- (IBAction)pickLocation:(id)sender {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LocationPicker pickerOnView:sender picked:^(CLLocationCoordinate2D coordinate, NSString *address, UIImage *mapImage) {
            NSLog(@"Picked Address:%@", address);
            self.mapView.image = mapImage;
        }];
    });
}

- (IBAction)selectedPaymentType:(UIButton*)sender
{
    const NSInteger tagbase = 1000;
    
    UIView *su = sender.superview;
    
    for (int i=kTagPaymentNone; i<=kTagPaymentDutch; i++)
    {
        UIButton *v = [su viewWithTag:i];
        if (v.tag == sender.tag) {
            v.alpha = 1.0f;
            v.layer.transform = CATransform3DMakeScale(1.06, 1.06, 1);
            self.ad.payment = sender.tag - tagbase;
            v.backgroundColor = self.ad.paymentTypeColor;
            NSLog(@"AD:%@", self.ad);
        }
        else {
            v.alpha = 0.8f;
            v.layer.transform = CATransform3DIdentity;
            v.backgroundColor = [UIColor lightGrayColor];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

@end
