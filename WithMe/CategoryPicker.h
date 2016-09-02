//
//  CategoryPicker.h
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CategoryBlock)(Category* category);
@interface CategoryPicker : UITableView <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) CategoryBlock categoryHandler;
@property (nonatomic, copy) CategoryBlock allCategoryHandler;
@property (nonatomic, copy) VoidBlock selectedHandler;
@end

@interface CategoryPickerView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic) CGRect parentFrame;
@property (nonatomic) CategoryPicker *picker;
@property (nonatomic, copy) CategoryBlock categoryHandler;
@property (nonatomic, copy) CategoryBlock allCategoryHandler;

+ (instancetype) categoryPickerWithFrame:(CGRect)frame;
@end

