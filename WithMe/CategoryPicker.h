//
//  CategoryPicker.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActivityBlock)(Activity* activity);
@interface CategoryPicker : UITextField <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, copy) ActivityBlock activityHandler;
- (void)selectActivity:(Activity*)activity;
@end
