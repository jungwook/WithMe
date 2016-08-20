//
//  LocationManagerController.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 18..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationManagerController.h"
#import "LocationManager.h"
#import "IndentedLabel.h"
#import "ModalAnimator.h"

@interface LocationManagerController ()
@property (weak, nonatomic) IBOutlet    UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet    MKMapView *mapView;
@property (weak, nonatomic) IBOutlet    IndentedLabel *addressLabel;
@property (weak, nonatomic) IBOutlet    NSLayoutConstraint *topMargin;
@property (weak, nonatomic) IBOutlet    UIView *activityView;

@property (copy, nonatomic)             AdLocationBlock adLocHandler;

@property (strong, nonatomic)           UIColor *pinColor;
@property (strong, nonatomic)           NSArray *placemarks;
@property (nonatomic)                   AdLocation *adLoc;
@end

static NSString* const kLocationManagerController = @"LocationManagerController";

@implementation LocationManagerController

+ (void)controllerFromViewController:(UIViewController *)viewController
                         withHandler:(AdLocationBlock)handler
                            pinColor:(UIColor *)pinColor
                         newLocation:(PFGeoPoint*)fromLocation
{
    AdLocation *adLoc = [AdLocation object];
    adLoc.location = fromLocation;
    
    LocationManagerController *vc = [LocationManagerController newWithAdLocation:adLoc];
    vc.adLocHandler = handler;
    if (pinColor) {
        vc.pinColor = pinColor;
    }
    
    NSLog(@"VC1:%@",vc);
    
    [viewController presentViewController:vc animated:YES completion:nil];
}

+ (void)controllerFromViewController:(UIViewController *)viewController
                         withHandler:(AdLocationBlock)handler
                            pinColor:(UIColor *)pinColor
                      fromAdLocation:(AdLocation *)adLoc
{
    LocationManagerController *vc = [LocationManagerController newWithAdLocation:adLoc];
    vc.adLocHandler = handler;
    if (pinColor) {
        vc.pinColor = pinColor;
    }

    NSLog(@"VC2:%@",vc);
    
    [viewController presentViewController:vc animated:YES completion:nil];
}

+ (instancetype)newWithAdLocation:(AdLocation*)adLoc
{
    LocationManagerController *controller = [[[NSBundle mainBundle] loadNibNamed:kLocationManagerController owner:self options:nil] firstObject];
    __LF
    
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.adLoc = adLoc;
    return controller;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.pinColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    NSLog(@"ADLOC:%@ VC:%@", self.adLoc, self);
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    
    self.addressLabel.alpha = 0;
    self.addressLabel.radius = 4;
    self.addressLabel.textInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    self.mapView.tag = 0;
}

-(void)setAdLoc:(AdLocation *)adLoc
{
    _adLoc = adLoc;
    [self.mapView setRegion:MKCoordinateRegionMake(self.adLoc.coordinates, self.adLoc.span) animated:NO];
}

// THis is when the user taps on the SAVE button.
- (IBAction)locationSelected:(id)sender
{
    self.mapView.tag = YES;
    [self.adLoc updateWithNewLocation:self.adLoc.location pinColor:self.pinColor size:self.mapView.bounds.size completion:^(AdLocation *adLoc) {
        if (self.adLocHandler) {
            self.adLocHandler(self.adLoc);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.activityView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, 1, 1) animated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.mapView.tag == NO) {
        self.adLoc.coordinates = mapView.centerCoordinate;
        self.adLoc.span = mapView.region.span;
        
        NSLog(@"ADLO:%@", self.adLoc);
        getAddressForCoordinates(mapView.centerCoordinate, ^(NSString *address) {
            if (address) {
                self.adLoc.address = address;
                [UIView animateWithDuration:0.2 animations:^{
                    self.addressLabel.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    self.addressLabel.text = address;
                    [UIView animateWithDuration:1 animations:^{
                        self.addressLabel.alpha = 1.f;
                    } completion:nil];
                }];
            }
        });
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.adLocHandler)
            self.adLocHandler(nil);
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
