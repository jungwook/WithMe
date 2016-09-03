//
//  UserDetail.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserDetail.h"
#import "AdsCollection.h"
#import "PlaceholderTextView.h"
#import "AppDelegate.h"
#import "ListField.h"
#import "MediaCollection.h"

@interface UserDetail ()
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet ListField *ageField;
@property (weak, nonatomic) IBOutlet ListField *genderField;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *introTextView;
@property (weak, nonatomic) IBOutlet UIButton *introCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *editIntroButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introHeight;
@property (weak, nonatomic) IBOutlet UserMediaView *photoView;
@property (weak, nonatomic) IBOutlet MediaCollection *mediaCollection;
@end

@implementation UserDetail

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    self.user = [User me];
}

- (void)setUser:(User *)user
{
    _user = user;
}

- (void) setEditable
{
    BOOL isMe = self.user.isMe;
    
    self.nicknameField.enabled = isMe;
    self.ageField.enabled = isMe;
    self.introTextView.userInteractionEnabled = NO;
    self.editIntroButton.hidden = !isMe;
}

- (IBAction)toggleMenu:(id)sender
{
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]).menuController toggleMenu];
}

- (IBAction)editIntro:(id)sender
{
    self.introTextView.userInteractionEnabled = YES;
    [self.introTextView becomeFirstResponder];
    showView(self.editIntroButton, NO);
    showView(self.introCloseButton, YES);
}

- (IBAction)closeIntroTextView:(id)sender
{
    showView(self.introCloseButton, NO);
    showView(self.editIntroButton, YES);

    self.user.introduction = self.introTextView.text;
    [self.user saveInBackground];
    
    [self.introTextView resignFirstResponder];
    self.introTextView.userInteractionEnabled = NO;
}

- (IBAction)tappedOutside:(id)sender
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.introCloseButton.alpha = 0.F;
    
    [self setEditable];
    
    [self.ageField setPickerForAgeGroupsWithHandler:^(id item) {
        self.user.age = item;
        [self.user saveInBackground];
    }];
    
    [self.genderField setPickerForGenderCodesWithHandler:^(id item) {
        [self.user setGenderTypeFromCode:item];
        [self.user saveInBackground];
    }];
    
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self populateContents];
        self.photoView.user = self.user;
    }];
    
    self.mediaCollection.user = self.user;
}

- (void) populateContents
{
    __LF
    
    self.introTextView.text = self.user.introduction;
    self.nicknameField.text = self.user.nickname.uppercaseString;
    self.ageField.text = self.user.age;
    
    CGRect rect = rectForString(self.introTextView.text, self.introTextView.font, CGRectGetWidth(self.introTextView.frame));
    CGFloat introHeight = MIN(MAX(CGRectGetHeight(rect)+10, 100), 250);
    self.introHeight.constant = introHeight;
    [self.introTextView layoutIfNeeded];
}

#pragma mark UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

@end
