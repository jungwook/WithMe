//
//  LocationPickerController.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationPickerController.h"

@interface LocationPickerController ()
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@end

@implementation LocationPickerController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    const CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(37.520884, 127.028360);
    
    [self initLocationServices];
    [self initializeMap];
    [self gotoLocation:coord];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
}

- (void) initializeMap
{
    self.map.showsCompass = YES;
    self.map.showsScale = YES;
    self.map.zoomEnabled = YES;
    self.map.delegate = self;
}

- (void) initLocationServices
{
    __LF
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
#if TARGET_IPHONE_SIMULATOR
#else
    [self gotoLocation:[locations lastObject].coordinate];
#endif
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    __LF
    
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            self.map.showsUserLocation = NO;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            self.map.showsUserLocation = YES;
            
            break;
        default:
            break;
    }
}

- (void) gotoLocation:(CLLocationCoordinate2D) coords
{
    const CGFloat span = 2500.0f;
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(coords, span, span)];
}

- (IBAction)save:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.handler) {
            self.handler(self.map.centerCoordinate);
        }
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    __LF
    CLLocationCoordinate2D center = mapView.centerCoordinate;
    getAddressForCLLocation([[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude], ^(NSString *address) {
        self.navigationItem.prompt = address;
    });
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
