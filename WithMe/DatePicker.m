//
//  DatePicker.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "DatePicker.h"
#import "IndentedLabel.h"

@interface DateField ()
@property (nonatomic, strong) IndentedLabel *dateLabel;
@property (nonatomic, strong) IndentedLabel *timeLabel;

@end

@implementation DateField

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    _date = [NSDate date];
    
    self.dateLabel = [IndentedLabel new];
    self.timeLabel = [IndentedLabel new];
    
    [self addSubview:self.dateLabel];
    [self addSubview:self.timeLabel];
    
    self.dateLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    self.timeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];

    self.dateLabel.textColor = colorWhite;
    self.timeLabel.textColor = colorWhite;
    
    self.dateLabel.textInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    self.timeLabel.textInsets = UIEdgeInsetsMake(0, 12, 0, 12);
}

- (void)setDate:(NSDate *)date
{
    __LF
    _date = date;
    
    if (date) {
        self.dateLabel.backgroundColor = [UIColor colorWithRed:110/255.f green:200/255.f blue:41/255.f alpha:1.0f];
        self.timeLabel.backgroundColor = [UIColor colorWithRed:174/255.f green:205/255.f blue:241/255.f alpha:1.0f];
        
        if ([date timeIntervalSinceDate:[NSDate date]] < 60*60*24*7) {
            NSDateFormatter *format = [NSDateFormatter new];
            [format setDateFormat:@"EEEE"];
            self.dateLabel.text = [format stringFromDate:date];
        }
        else {
            self.dateLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        }
        self.timeLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        
        [self.dateLabel sizeToFit];
        [self.timeLabel sizeToFit];
        
        CGFloat h = CGRectGetHeight(self.bounds);
        
        CGRect catFrame = self.dateLabel.frame;
        catFrame = CGRectMake(0, 0, CGRectGetWidth(catFrame), h);
        self.dateLabel.frame = catFrame;
        
        CGRect frame = self.timeLabel.frame;
        frame.origin.x = CGRectGetWidth(catFrame)+4;
        frame.origin.y = 0;
        frame.size.height = h;
        self.timeLabel.frame = frame;
        self.text = @" ";
    }
    else {
        self.dateLabel.text = @"";
        self.timeLabel.text = @"";
        
        [self.dateLabel sizeToFit];
        [self.timeLabel sizeToFit];
        
        self.text = @"";
        
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.parent endEditing:YES];

    DatePicker *picker = [DatePicker new];
    picker.date = self.date;
    [picker setDateHandler:^(NSDate* date) {
        self.date = date;
    }];
    
    [picker show];
    return NO;
}

@end

@interface DatePicker()
@property (strong, nonatomic) UIView *screenshot;
@property (weak, nonatomic) IBOutlet UIView *screen;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@end

@implementation DatePicker

+ (instancetype) new
{
    return [[[NSBundle mainBundle] loadNibNamed:@"DatePicker" owner:self options:nil] firstObject];
}

- (void)show
{
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.backView.radius = 8.0f;
    self.backView.layer.borderColor = self.doneButton.backgroundColor.CGColor;
    self.backView.layer.borderWidth = 1.0f;
    
    [self.picker setValue:self.doneButton.backgroundColor forKeyPath:@"textColor"];
    self.picker.datePickerMode = UIDatePickerModeCountDownTimer;
    self.picker.datePickerMode = UIDatePickerModeDateAndTime;
    self.picker.minuteInterval = 30;

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

- (IBAction)changed:(UIDatePicker *)sender
{
    if (sender.date.timeIntervalSinceReferenceDate < [NSDate date].timeIntervalSinceReferenceDate) {
        [sender setDate:[NSDate date] animated:YES];
    }
}

- (IBAction)done:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.alpha = 0.0f;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.screen.alpha = 0.0f;
        self.screenshot.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        self.screenshot.hidden = YES;
        if (self.dateHandler) {
            self.dateHandler(self.picker.date);
        }
        [self removeFromSuperview];
    }];
}

- (void) setDate:(NSDate *)date
{
    if (date)
        self.picker.date = date;
    else
        self.picker.date = [NSDate date];
}

@end
