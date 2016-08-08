//
//  LocationPicker.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kPickerPositionTop,
    kPickerPositionLeft,
    kPickerPositionBottom,
    kPickerPositionRight
} PickerPosition;

typedef void(^LocationPickerBlock)(CLLocationCoordinate2D coordinate, NSString* address, UIImage* mapImage);

@interface LocationPicker : UIView
+ (instancetype) pickerOnView:(UIView*)view picked:(LocationPickerBlock)pickerBlock;
+ (instancetype) pickerOnView:(UIView*)view titled:(NSString*)title picked:(LocationPickerBlock)pickerBlock;
+ (instancetype) pickerOnView:(UIView*)view titled:(NSString*)title fromView:(UIView*)parentView picked:(LocationPickerBlock)pickerBlock;
- (void) closeAndKill;
- (void) saveAndCloseWithLocation:(CLLocationCoordinate2D)coordinate
                          address:(NSString*)address
                            image:(UIImage*)mapImage;
@end
