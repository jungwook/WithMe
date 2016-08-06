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

@interface LocationPicker : UIView
+ (instancetype)pickerOnView:(UIView*)view;
@end
