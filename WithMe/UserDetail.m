//
//  UserDetail.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserDetail.h"

@interface UserDetail ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;

@end

@implementation UserDetail

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.user = [User me];
}

- (void)setUser:(User *)user
{
    _user = user;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.title = self.user.nickname;
        [self populateContents];
    }];
}

- (void) populateContents
{
    __LF
    self.nicknameLabel.text = self.user.nickname;
    self.genderLabel.text = self.user.genderTypeString;
    self.ageLabel.text = self.user.age;
    self.introductionLabel.text = self.user.introduction;
    
//    [self.introductionLabel setNeedsLayout];
//    [self.tableView setNeedsLayout];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    if (indexPath.row == 0) {
        CGFloat h = CGRectGetHeight(self.introductionLabel.bounds);
        CGFloat o = CGRectGetMinY(self.introductionLabel.frame);
        
        return h+o+60;
    }
    else {
        return 300;
    }
}

@end
