//
//  LocationPickerController.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

typedef void(^LocationPickerBlock)(CLLocationCoordinate2D location);
@interface LocationPickerController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic, copy, nonnull) LocationPickerBlock handler;
@end
