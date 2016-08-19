//
//  LocationManagerController.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 18..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModalViewController.h"

typedef void(^AdLocationBlock)(AdLocation* adLoc, UIImage* image);

@interface LocationManagerController : ModalViewController <MKMapViewDelegate>

+ (void)controllerFromViewController:(UIViewController *)viewController
                         withHandler:(AdLocationBlock)handler
                            pinColor:(UIColor *)pinColor
                     initialLocation:(PFGeoPoint*)fromLocation;

@end
