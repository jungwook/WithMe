//
//  PreviewAd.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PreviewAd.h"
#import "PreviewMap.h"
#import "IndentedLabel.h"
#import "CollectionView.h"
#import "ParallaxView.h"
#import "IconLabel.h"
#import "PreviewUser.h"
#import "CandidatesCollection.h"
#import "JoinRequest.h"

@interface PreviewAd ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mapView;
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *categoryLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *activityLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *paymentLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *participantsLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet CollectionView *mediaCollection;
@property (weak, nonatomic) IBOutlet IconLabel *viewedByLabel;
@property (weak, nonatomic) IBOutlet IconLabel *likedByLabel;
@property (weak, nonatomic) IBOutlet UIButton *previewMapButton;
@property (weak, nonatomic) IBOutlet CandidatesCollection *candidatesCollection;
@end

@implementation PreviewAd

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.parallax setScrollOffset:scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    __LF
    
    VoidBlock requestJoinHandler = ^{
        [self performSegueWithIdentifier:@"JoinRequest" sender:nil];
    };
    
    UserBlock userSelectedBlock = ^(User* user) {
        [self performSegueWithIdentifier:@"PreviewUser" sender:user];
    };
    
    [self.candidatesCollection setRequestJoinBlock:requestJoinHandler];
    [self.candidatesCollection setUserSelectedBlock:userSelectedBlock];
    [self.parallax setNavigationBarProperties:self.navigationController.navigationBar];
    
    setButtonTintColor(self.previewMapButton, kAppColor);
    [self.ad firstMediaImageLoaded:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profileImageView.image = image;
        });
    }];
    
    [self.ad fetched:^{
        [self.ad userProfileThumbnailLoaded:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoView.image = image;
                self.photoView.backgroundColor = [UIColor clearColor];
            });
        }];
        self.nicknameLabel.text = self.ad.user.nickname;
        self.genderLabel.text = self.ad.user.genderTypeString;
        self.genderLabel.backgroundColor = self.ad.user.genderColor;
        self.ageLabel.text = self.ad.user.age;
        self.titleLabel.text = self.ad.title;
        self.categoryLabel.text = self.ad.activity.category.name;
        self.activityLabel.text = self.ad.activity.name;
        self.paymentLabel.text = self.ad.paymentTypeString;
        self.participantsLabel.text = [@(self.ad.participants).stringValue stringByAppendingString:@" ppl."];
        self.introLabel.text = self.ad.intro;
        
        self.eventDateLabel.text = [NSDateFormatter dateFormatFromTemplate:@"EEE dd. HH:MM" options:0 locale:[NSLocale currentLocale]];
        self.eventDateLabel.hidden = !(self.ad.eventDate);
    }];
    [self.ad.adLocation fetched:^{
        self.addressLabel.text = self.ad.adLocation.address;
        [self.ad.adLocation mapImageWithPinColor:colorBlue size:self.mapView.bounds.size handler:^(UIImage *image) {
            self.mapView.image = image;
        }];
        
        self.viewedByLabel.image = [UIImage imageNamed:@"viewedby"];
        self.likedByLabel.image = [UIImage imageNamed:@"like"];
        [self.ad countViewed:^(NSUInteger count) {
            self.viewedByLabel.text = @(count).stringValue;
        }];
        [self.ad countLikes:^(NSUInteger count) {
            self.likedByLabel.text = @(count).stringValue;
        }];
    }];

    [UserMedia fetchAllIfNeededInBackground:self.ad.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.mediaCollection setIsMine:self.ad.isMine];
        [self.mediaCollection setButtonColor:kAppColor];
        [self.mediaCollection setViewController:self];
        [self.mediaCollection setItems:self.ad.media];
        [self.mediaCollection setCellSizeRatio:0.8f];
    }];
    
    [self.candidatesCollection setAd:self.ad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PreviewLocation"]) {
        PreviewMap *vc = segue.destinationViewController;
        vc.adLocation = self.ad.adLocation;
    }
    if ([segue.identifier isEqualToString:@"PreviewUser"]) {
        UINavigationController *nvc = segue.destinationViewController;
        PreviewUser *preview = nvc.viewControllers.firstObject;
        preview.user = [sender isKindOfClass:[User class]] ? sender : self.ad.user;
    }
    if ([segue.identifier isEqualToString:@"JoinRequest"]) {
        JoinRequest *join = segue.destinationViewController;
        join.ad = self.ad;
    }
}

- (void)setAd:(Ad *)ad
{
    __LF
    _ad = ad;
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

CGRect rectForString(NSString *string, UIFont *font, CGFloat maxWidth);

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        CGFloat y = CGRectGetMinY(self.introLabel.frame);
        CGFloat w = CGRectGetWidth(self.introLabel.frame);
        CGRect rect = rectForString(self.ad.intro, self.introLabel.font, w);
        CGFloat h = CGRectGetHeight(rect);
        
        return y + h + 50;
    }
    else if (indexPath.row == 1)
    {
        return 200;
    }
    else if (indexPath.row == 2) { // Candidates Collection
        return 130;
    }
    else {
        return 280;
    }
}

#pragma mark - Table view data source


@end
