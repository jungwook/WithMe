//
//  LocationPickerController.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

typedef void(^LocationPickerBlock)(CLLocationCoordinate2D location, NSString* addressString);

@interface LocationPickerController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
+ (instancetype) pickerWithLocationPickedHandler:(LocationPickerBlock)locationPickedHandler
                             withInitialLocation:(PFGeoPoint*)initialLocation
                       presentFromViewController:(UIViewController*)viewController
                                           title:(NSString*)title;
@end
