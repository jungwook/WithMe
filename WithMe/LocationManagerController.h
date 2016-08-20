//
//  LocationManagerController.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 18..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"

@interface LocationManagerController : ModalViewController <MKMapViewDelegate>

+ (void)controllerFromViewController:(UIViewController *)viewController
                         withHandler:(AdLocationBlock)handler
                            pinColor:(UIColor *)pinColor
                         newLocation:(PFGeoPoint*)fromLocation;

+ (void)controllerFromViewController:(UIViewController *)viewController
                         withHandler:(AdLocationBlock)handler
                            pinColor:(UIColor *)pinColor
                      fromAdLocation:(AdLocation*)adLoc;

@end
