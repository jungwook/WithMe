//
//  ActivityPicker.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ActivityPicker.h"
#import "IndentedLabel.h"

@interface ActivityField ()
@property (strong, nonatomic) ActivityPicker *picker;
@property (strong, nonatomic) IndentedLabel *categoryLabel;
@property (strong, nonatomic) IndentedLabel *activityLabel;
@end

@implementation ActivityField

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    
    self.categoryLabel = [IndentedLabel new];
    self.activityLabel = [IndentedLabel new];
    
    [self addSubview:self.categoryLabel];
    [self addSubview:self.activityLabel];
    
    self.categoryLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    self.activityLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.categoryLabel.textColor = colorWhite;
    self.activityLabel.textColor = colorWhite;
    self.categoryLabel.textInsets = UIEdgeInsetsMake(0, 12, 0, 14);
    self.activityLabel.textInsets = UIEdgeInsetsMake(0, 12, 0, 12);
}

- (void)setActivity:(Activity *)activity
{
    _activity = activity;
    
    if (activity) {
        self.categoryLabel.backgroundColor = kAppColor;
        self.activityLabel.backgroundColor = kAppColor.lighterColor;
        self.categoryLabel.text = [activity.category.name uppercaseString];
        self.activityLabel.text = [activity.name uppercaseString];
        
        
        [self.categoryLabel sizeToFit];
        [self.activityLabel sizeToFit];

        CGFloat h = CGRectGetHeight(self.bounds);

        CGRect catFrame = self.categoryLabel.frame;
        catFrame = CGRectMake(0, 0, CGRectGetWidth(catFrame), h);
        self.categoryLabel.frame = catFrame;
        
        CGRect frame = self.activityLabel.frame;
        frame.origin.x = CGRectGetWidth(catFrame)+4;
        frame.size.height = h;
        self.activityLabel.frame = frame;
        self.text = @" ";
    }
    else {
        self.categoryLabel.text = @"";
        self.activityLabel.text = @"";

        [self.categoryLabel sizeToFit];
        [self.activityLabel sizeToFit];
        
        self.text = @"";
        
        self.categoryLabel.backgroundColor = [UIColor clearColor];
        self.activityLabel.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.parent endEditing:YES];
    
    ActivityPicker *picker = [ActivityPicker new];
    if (self.activity)
        [picker selectActivity:self.activity];
    [picker setActivityHandler:^(Activity* activity) {
        self.activity = activity;
    }];
    
    [picker show];
    
    return NO;
}

@end


@interface ActivityPicker()
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIView *screen;
@property (strong, nonatomic) UIView* screenshot;
@property (strong, nonatomic) NSArray* activities;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@end

@implementation ActivityPicker

+ (void) showPicker
{
    ActivityPicker *picker = [ActivityPicker new];
    picker.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:picker];
}

- (void) show
{
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

+ (instancetype) new
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ActivityPicker" owner:self options:nil] firstObject];
}

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.backView.radius = 8.0f;
    self.backView.layer.borderColor = self.doneButton.backgroundColor.CGColor;
    self.backView.layer.borderWidth = 1.0f;
    
//    self.activities = ((Category *)[[WithMe new].categories firstObject]).activities;
    
    self.screenshot = [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:NO];
    self.screenshot.radius = 8.0f;
    self.screenshot.clipsToBounds = YES;
    [self insertSubview:self.screenshot atIndex:0];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.screen.alpha = 1.0f;
        self.picker.alpha = 1.0f;
        self.screenshot.layer.transform = CATransform3DMakeScale(0.94, 0.94, 0.94);
    }];
}

- (IBAction)done:(id)sender
{
    NSInteger row = [self.picker selectedRowInComponent:1];
    if (self.activityHandler) {
        self.activityHandler([self.activities objectAtIndex:row]);
    }

    [UIView animateWithDuration:0.25 animations:^{
        self.backView.alpha = 0.0f;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.screen.alpha = 0.0f;
        self.screenshot.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        self.screenshot.hidden = YES;
        if (self.activityHandler) {
            NSInteger idx = [self.picker selectedRowInComponent:1];
            self.activityHandler([self.activities objectAtIndex:idx]);
        }
        [self removeFromSuperview];
    }];
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
        Activity *act = [self.activities objectAtIndex:row];
        self.activityLabel.text = [act.name uppercaseString];
    }
}

- (void)selectActivity:(Activity*)activity
{
    NSArray *activities = activity.category.activities;
    Category* category = activity.category;
    NSInteger categoryIndex = [[WithMe new].categories indexOfObject:category];
    [self.picker selectRow:categoryIndex inComponent:0 animated:YES];
    [self.picker reloadComponent:1];
    activities = category.activities;
    NSInteger activityIndex = [activities indexOfObject:activity];
    [self.picker selectRow:activityIndex inComponent:1 animated:YES];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    
    if (!pickerLabel)
    {
        pickerLabel = [UILabel new];
        pickerLabel.textColor = self.doneButton.backgroundColor;
        pickerLabel.textAlignment=NSTextAlignmentCenter;
    }
    if (component==0) {
        Category *cat = [[WithMe new].categories objectAtIndex:row];
        pickerLabel.textColor = self.doneButton.backgroundColor.lighterColor;
        pickerLabel.font = [UIFont boldSystemFontOfSize:17];
        [pickerLabel setText:[cat.name uppercaseString]];
    }
    else {
        Activity *act = [self.activities objectAtIndex:row];
        pickerLabel.textColor = self.doneButton.backgroundColor;
        pickerLabel.font = [UIFont boldSystemFontOfSize:18];
        [pickerLabel setText:[act.name uppercaseString]];
    }
    return pickerLabel;
}

/*- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
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
*/

@end
