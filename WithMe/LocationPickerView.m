//
//  LocationPickerView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationPickerView.h"

@interface LocationPickerView()
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation LocationPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

@end
