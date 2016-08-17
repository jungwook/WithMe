//
//  LocationPickerView.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationPicker.h"

@import MapKit;

@interface LocationPickerView : UIView <MKMapViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic)     LocationPicker  *parent;
@property (assign, nonatomic)   UIColor         *tintColor;
@property (assign, nonatomic)   UIColor         *textColor;
@property (weak, nonatomic)     NSString        *title;
@property (strong, nonatomic)   CLLocation      *initialLocation;

- (void)setPosition:(PickerPosition)position
     fromSenderRect:(CGRect)rect
         windowRect:(CGRect)windowRect;
@end
