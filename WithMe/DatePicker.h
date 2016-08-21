//
//  DatePicker.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DateBlock)(NSDate *date);

@interface DateField : UITextField <UITextFieldDelegate>
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, weak) UITableView *parent;
@end

@interface DatePicker : UIView
@property (copy, nonatomic) DateBlock dateHandler;
@property (assign, nonatomic) NSDate *date;
- (void)show;
@end
