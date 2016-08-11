//
//  LocationManager.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, readonly) PFGeoPoint *location;
@end
