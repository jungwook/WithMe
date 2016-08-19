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
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet IndentedLabel *addressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (copy, nonatomic) AdLocationBlock adLocHandler;
@property (strong, nonatomic) UIColor *pinColor;
@property (strong, nonatomic) NSArray *placemarks;
@property (nonatomic) MKCoordinateSpan span;
@property (nonatomic) PFGeoPoint *fromLocation;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@end

static NSString* const kLocationManagerController = @"LocationManagerController";

@implementation LocationManagerController

+ (void)controllerFromViewController:(UIViewController *)viewController
                         withHandler:(AdLocationBlock)handler
                            pinColor:(UIColor *)pinColor
                     initialLocation:(PFGeoPoint*)fromLocation
{
    LocationManagerController *vc = [LocationManagerController new];
    vc.adLocHandler = handler;
    if (pinColor) {
        vc.pinColor = pinColor;
    }
    vc.fromLocation = fromLocation;
    [viewController presentViewController:vc animated:YES completion:nil];
}

+ (instancetype)new
{
    LocationManagerController *controller = [[[NSBundle mainBundle] loadNibNamed:kLocationManagerController owner:self options:nil] firstObject];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
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
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    
    CLLocationCoordinate2D coords;
    
    if (self.fromLocation) {
        coords = CLLocationCoordinate2DMake(self.fromLocation.latitude, self.fromLocation.longitude);
    }
    else {
        coords = [User me].locationCLLocation.coordinate;
    }
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coords, 2500, 2500) animated:NO];
    
    self.addressLabel.alpha = 0;
    self.addressLabel.radius = 4;
    self.addressLabel.textInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    
    self.mapView.tag = 0;
}

- (IBAction)locationSelected:(id)sender
{
    self.mapView.tag = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.activityView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, 5, 5) animated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.mapView.tag == NO) {
        self.span = mapView.region.span;
        getAddressForCoordinates(mapView.centerCoordinate, ^(NSString *address) {
            
            if (address) {
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
    else {
        if (self.adLocHandler) {
            AdLocation *adLoc = [AdLocation object];
            adLoc.location = [User me].location;
            adLoc.address = self.addressLabel.text;
            
            [adLoc adLocationMapImageUsingSpan:self.span
                                      pinColor:[UIColor blackColor]
                                          size:self.mapView.bounds.size
                                       handler:^(UIImage *image)
             {
                 if (self.adLocHandler)
                     self.adLocHandler(adLoc, image);
                 [self dismissViewControllerAnimated:YES completion:nil];
             }];
        }
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.adLocHandler)
            self.adLocHandler(nil, nil);
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
