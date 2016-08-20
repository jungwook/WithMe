//
//  LocationManager.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationManager.h"
#import "LocationManagerController.h"

@interface LocationManager()
@property (strong, nonatomic)   CLLocationManager *locationManager;

@end

@implementation LocationManager

+ (instancetype) new
{
    static LocationManager* sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[LocationManager alloc] init];
    });
    return sharedFile;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        [self initLocationServices];
    }
    return self;
}

- (void) initLocationServices
{
    __LF
    
    self.currentLocation = [[CLLocation alloc] initWithLatitude:37.520884 longitude:127.028360];
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

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    _currentLocation = currentLocation;
    [User me].location = self.location;
    [[User me] saveInBackground];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
#if TARGET_IPHONE_SIMULATOR
    self.currentLocation = [[CLLocation alloc] initWithLatitude:37.520884 longitude:127.028360];
#else
    self.currentLocation = [locations lastObject];
#endif
}

- (PFGeoPoint *)location
{
    return [PFGeoPoint geoPointWithLocation:self.currentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    __LF
    
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            [self setUserLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            [self.locationManager startMonitoringSignificantLocationChanges];
            break;
        default:
            break;
    }
}

//+ (void)loadFromRootViewControllerWithHandler:(LocationManagerBlock)handler
//{
//    LocationManagerController *vc = [LocationManagerController new];
//    vc.handler = handler;
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
//}


- (void) setUserLocation
{
    if (![User me].location) {
        [LocationManagerController controllerFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController
                                                    withHandler:^(AdLocation *adLoc) {
            self.currentLocation = [[CLLocation alloc] initWithLatitude:adLoc.location.latitude longitude:adLoc.location.longitude];
        } pinColor:nil initialLocation:[User me].location];
    }
}

@end
