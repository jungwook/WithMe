//
//  ActivityPicker.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActivityBlock)(Activity* activity);

@interface ActivityField : UITextField <UITextFieldDelegate>
@property (nonatomic, strong) Activity *activity;
@property (nonatomic, weak) UITableView *parent;
@end

@interface ActivityPicker : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, copy) ActivityBlock activityHandler;

+ (void) showPicker;
- (void) selectActivity:(Activity*)activity;
- (void) show;
@end
