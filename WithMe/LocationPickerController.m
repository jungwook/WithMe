//
//  LocationPickerController.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationPickerController.h"

@interface LocationPickerController ()
@property (weak, nonatomic)     IBOutlet UIView *backView;
@property (weak, nonatomic)     IBOutlet UIView *mainView;
@property (weak, nonatomic)     IBOutlet MKMapView *map;
@property (weak, nonatomic)     IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic)   CLLocationManager *locationManager;
@property (nonatomic, copy)     LocationPickerBlock locationPickedHandler;
@property (nonatomic)           BOOL ready;
@property (weak, nonatomic)     UIViewController *viewController;
@end

@implementation LocationPickerController

+ (instancetype) new
{
    return [[[NSBundle mainBundle] loadNibNamed:@"LocationPicker" owner:self options:nil] firstObject];
}

+ (instancetype) pickerWithLocationPickedHandler:(LocationPickerBlock)locationPickedHandler
                             withInitialLocation:(PFGeoPoint*)initialLocation
                       presentFromViewController:(UIViewController*)viewController
                                           title:(NSString*)title
{
    LocationPickerController* picker = [LocationPickerController new];
    [picker setLocationPickedHandler:locationPickedHandler
                     initialLocation:initialLocation
            presentingViewController:viewController
                               title:title];
    return picker;
}

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.view.alpha = 0;
    setShadowOnView(self.backView, 5, 0.3);
    self.backView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(self.view.bounds), 0);
    
    [self initLocationServices];
    [self initializeMap];
}

- (void)viewDidLoad
{
    __LF
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.backView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.backView.bounds cornerRadius:self.backView.radius].CGPath;
}

- (void) setLocationPickedHandler:(LocationPickerBlock)handler
                  initialLocation:(PFGeoPoint*)location
         presentingViewController:(UIViewController *)viewController
                            title:(NSString*)title
{
    CLLocationCoordinate2D coord = (location != nil) ? CLLocationCoordinate2DMake(location.latitude, location.longitude) : CLLocationCoordinate2DMake(37.520884, 127.028360);
    
    self.locationPickedHandler = handler;
    self.viewController = viewController;
    self.navigationItem.title = title;
    
    [self gotoLocation:coord];
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
    static BOOL firstTimeMoved = NO;
    if (firstTimeMoved == NO) {
        firstTimeMoved = YES;
        [self gotoLocation:[locations lastObject].coordinate];
    }
#endif
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    __LF
    CLLocationCoordinate2D center = mapView.centerCoordinate;
    getAddressForCLLocation([[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude], ^(NSString *address) {
        self.navigationItem.prompt = address;
    });
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
    __LF
    const CGFloat span = 2500.0f;
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(coords, span, span) animated:YES];
}

- (IBAction)save:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.locationPickedHandler) {
            self.locationPickedHandler(self.map.centerCoordinate, self.navigationItem.prompt);
        }
    }];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    __LF
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    __LF
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    __LF
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
    __LF
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    __LF
    if (fullyRendered && !self.ready) {
        self.ready = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.backView.layer.transform = CATransform3DIdentity;
            self.view.alpha = 1;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
