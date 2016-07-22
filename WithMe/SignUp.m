//
//  SignUp.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SignUp.h"
#import "ListField.h"

@interface SignUp ()
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *space;
@property (weak, nonatomic) IBOutlet UIView *pane;
@property (weak, nonatomic) IBOutlet UILabel *information;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet ListField *withMe;
@property (weak, nonatomic) IBOutlet ListField *ageGroup;
@property (weak, nonatomic) IBOutlet ListField *gender;
@end

@implementation SignUp

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.view setBackgroundColor:kAppColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.blurView setFrame:self.view.bounds];
    [self.blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.blurView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.view insertSubview:self.blurView atIndex:0];
    [self.withMe setPickerItems:[User withMes] withHandler:^(id item) {
        NSLog(@"DTAT:%@", item);
    }];
    [self.ageGroup setPickerItems:[User ageGroups] withHandler:nil];
    [self.gender setPickerItems:[User genders] withHandler:^(id item) {
        self.information.text = @"Please make sure... You cannot change gender ever!";
    }];
    
    [self addObservers];
    self.space.constant = (self.view.bounds.size.height - self.pane.bounds.size.height) / 3.0f;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nickname.delegate = self;
}

- (IBAction)proceed:(id)sender {
    BOOL notReady = NO;
    if ([self.nickname.text isEqualToString:@""]) {
        self.information.text = @"You must enter a unique nickname!";
        notReady = YES;
    }
    else if ([self.withMe.text isEqualToString:@""]) {
        self.information.text = @"Please select why you're here!";
        notReady = YES;
    }
    else if ([self.ageGroup.text isEqualToString:@""]) {
        self.information.text = @"Please select an age group";
        notReady = YES;
    }
    else if ([self.gender.text isEqualToString:@""]) {
        self.information.text = @"Please select your gender. You cannot change this ever!";
        notReady = YES;
    }
    
    if (!notReady && self.completionBlock) {
        self.completionBlock(self, self.nickname.text, self.withMe.text, self.ageGroup.text, self.gender.text);
        self.information.text = @"Processing...";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.nickname.text isEqualToString:@""]) {
            self.nickname.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        }
        else {
            self.nickname.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
        }
    });
    return YES;
}

- (void)setInfo:(NSString *)info
{
    self.information.text = info;
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doKeyBoardEvent:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (IBAction)tappedOutside:(id)sender {
    [self.view endEditing:YES];
}

- (void)doKeyBoardEvent:(NSNotification *)notification
{
    static CGRect keyboardEndFrameWindow;
    static double keyboardTransitionDuration;
    static UIViewAnimationCurve keyboardTransitionAnimationCurve;
    
    if (notification) {
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.space.constant = (keyboardEndFrameWindow.origin.y - self.pane.bounds.size.height) / 3.0f;
        [self.pane setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:keyboardTransitionDuration delay:0.0f options:(keyboardTransitionAnimationCurve << 16) animations:^{
            [self.pane layoutIfNeeded];
        } completion:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
