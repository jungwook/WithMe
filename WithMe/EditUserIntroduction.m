//
//  EditUserIntroduction.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "EditUserIntroduction.h"

@interface EditUserIntroduction ()
@property (strong, nonatomic) User *me;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;

@end

@implementation EditUserIntroduction

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.me = [User me];
    
}

- (void)viewDidLoad
{
    self.introTextView.delegate = self;
    [super viewDidLoad];
    
    BOOL isEmpty = (self.me.introduction == nil || [self.me.introduction isEqualToString:@""]);
    self.introTextView.text = self.me.introduction;

    [self showPlaceHolder:isEmpty];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self showPlaceHolder:([self.introTextView.text isEqualToString:@""])];
}

- (IBAction)backToEditProfile:(id)sender
{
    self.me.introduction = [self.introTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [self.me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)showPlaceHolder:(BOOL)show
{
    [UIView animateWithDuration:0.25 animations:^{
        self.placeholder.alpha = show;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
