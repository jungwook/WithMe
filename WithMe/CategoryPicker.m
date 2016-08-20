//
//  CategoryPicker.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CategoryPicker.h"
@interface CategoryPicker()
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) UIPickerView *picker;
@end

@implementation CategoryPicker

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.picker = [UIPickerView new];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    self.inputView = self.picker;
    self.activities = ((Category *)[[WithMe new].categories firstObject]).activities;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(done)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    self.inputAccessoryView = toolBar;
}

- (void)done
{
    __LF
    NSInteger row = [self.picker selectedRowInComponent:1];
    [self resignFirstResponder];
    if (self.activityHandler) {
        self.activityHandler([self.activities objectAtIndex:row]);
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0){
        return [WithMe new].categories.count;
    }
    else {
        return self.activities.count;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component==0) {
        Category *cat = [[WithMe new].categories objectAtIndex:row];
        self.activities = cat.activities;
        [pickerView reloadComponent:1];
    }
    else {
        [self done];
    }
}

- (void)selectActivity:(Activity*)activity
{
    NSArray *activities = activity.category.activities;
    Category* category = activity.category;
    NSInteger categoryIndex = [[WithMe new].categories indexOfObject:category];
    [self.picker selectRow:categoryIndex inComponent:0 animated:YES];
    activities = category.activities;
    NSInteger activityIndex = [activities indexOfObject:activity];
    [self.picker selectRow:activityIndex inComponent:1 animated:YES];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0) {
        Category *cat = [[WithMe new].categories objectAtIndex:row];
        return cat.name;
    }
    else {
        Activity *act = [self.activities objectAtIndex:row];
        return act.name;
    }
}


@end
