//
//  AdDetailCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersCollection.h"

@import MapKit;

@interface AdDetailCell : UITableViewCell <UsersCollectionDelegate, MKMapViewDelegate>
@property (nonatomic, strong) Ad* ad;
@property (nonatomic, weak) id <UsersCollectionDelegate> showUserDelegate;
@end
