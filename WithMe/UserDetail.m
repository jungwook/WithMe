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

@interface UserDetail ()
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UITextField *ageField;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *introTextView;
@property (weak, nonatomic) IBOutlet UIButton *introCloseButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introHeight;
@property (weak, nonatomic) IBOutlet UserMediaView *photoView;

@property (strong, nonatomic) NSArray <UIImage *> *mediaImages;
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
    self.introTextView.editable = isMe;
}

- (IBAction)toggleMenu:(id)sender
{
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]).menuController toggleMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.introTextView.delegate = self;
    self.introCloseButton.alpha = 0.F;
    
    [self setEditable];
    
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self populateContents];
        [self.user mediaImagesLoaded:^(NSArray *array) {
            self.mediaImages = array;
            self.photoView.delegate = self;
        }];
        [self.user profileMediaImageLoaded:^(UIImage *image) {
            self.photoView.mainImage = image;
        }];
    }];
}

- (NSUInteger)numberOfImagesInImageView:(UserMediaView *)imageView
{
    return self.mediaImages.count;
}

- (UIImage *)imageView:(UserMediaView *)imageView imageForIndex:(NSUInteger)index
{
    return [self.mediaImages objectAtIndex:index];
}

- (IBAction)closeIntroTextView:(id)sender
{
    [self.user saveInBackground];
    [self.introTextView resignFirstResponder];
}

- (void) populateContents
{
    __LF
    
    self.introTextView.text = self.user.introduction;
    self.nicknameField.text = self.user.nickname;
    self.ageField.text = self.user.age;
    
    CGRect rect = rectForString(self.introTextView.text, self.introTextView.font, CGRectGetWidth(self.introTextView.frame));
    CGFloat introHeight = MIN(MAX(CGRectGetHeight(rect)+10, 100), 250);
    self.introHeight.constant = introHeight;
    [self.introTextView layoutIfNeeded];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    showView(self.introCloseButton, YES);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    showView(self.introCloseButton, NO);
}

@end
