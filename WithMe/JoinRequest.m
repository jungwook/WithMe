//
//  JoinRequest.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "JoinRequest.h"
#import "CollectionView.h"
#import "MediaPicker.h"
#import "IndentedLabel.h"

@interface JoinRequest ()
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet CollectionView *mediaCollection;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *categoryLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageToLabel;

@property (strong, nonatomic) NSMutableArray <UserMedia *> *media;
@end

@implementation JoinRequest

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.messageField becomeFirstResponder];
    self.media = [NSMutableArray array];
    
    [self.mediaCollection setIsMine:YES];
    [self.mediaCollection setButtonColor:kAppColor];
    [self.mediaCollection addAddMoreButtonTitled:@"+ media"];
    [self.mediaCollection setViewController:self];
    [[User me] profileMediaLoaded:^(UserMedia *media) {
        media.comment = @"This is me!";
        [self.media addObject:media];
        [self.mediaCollection setItems:self.media];
    }];
    [self.mediaCollection setDeletionBlock:^(UserMedia* media) {
        [self.media removeObject:media];
        [self.mediaCollection refresh];
    }];
    [self.mediaCollection setAdditionBlock:^() {
        [MediaPicker pickMediaOnViewController:self withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
            if (picked) {
                [self.media addObject:userMedia];
                [self.mediaCollection refresh];
            }
        }];
    }];
    
    self.sendButton.enabled = NO;
    [self.messageField addTarget:self action:@selector(messageChanged:) forControlEvents:UIControlEventEditingChanged];
    
    self.categoryLabel.text = self.ad.activity.category.name;
    self.activityLabel.text = self.ad.activity.name;
    self.titleLabel.text = self.ad.title;
    [self.ad.user fetched:^{
        self.messageToLabel.text = [@"include a message to " stringByAppendingString:self.ad.user.nickname];
    }];
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    
    [self.ad fetched:^{
        [self.ad.user fetched:nil];
    }];
}

- (void) messageChanged:(UITextField*)textField
{
    self.sendButton.enabled = (textField.text.length > 0);
}

- (IBAction)cancel:(id)sender
{
    [self.messageField resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)send:(id)sender
{
    AdJoin *join = [AdJoin object];
    
    join.user = [User me];
    join.comment = self.messageField.text;
    join.ad = self.ad;
    [join addObjectsFromArray:self.media forKey:kAdJoinMedia];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NOTIFY(kNotifyJoinedAd, join);
    }];
}

@end
