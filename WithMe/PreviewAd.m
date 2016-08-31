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
#import "PostAd.h"
#import "AdMediaCollection.h"

@interface PreviewAdHeaderView : UIView

@end

@implementation PreviewAdHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

@end

@interface PreviewAd ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *viewedByIcon;
@property (weak, nonatomic) IBOutlet UIImageView *likedByIcon;
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
@property (weak, nonatomic) IBOutlet IndentedLabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *likedByLabel;
@property (weak, nonatomic) IBOutlet UIButton *previewMapButton;
@property (weak, nonatomic) IBOutlet CandidatesCollection *candidatesCollection;
@property (weak, nonatomic) IBOutlet AdMediaCollection *adMediaCollection;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editMenuButton;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *addressBack;
@end

@implementation PreviewAd

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.parallax setScrollOffset:scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.parallax setNavigationBarProperties:self.navigationController.navigationBar];
    
    self.viewedByIcon.tintColor = kAppColor;
    self.likedByIcon.tintColor = kAppColor;
    self.viewedByLabel.textColor = kAppColor;
    self.likedByLabel.textColor = kAppColor;
    
    ActionBlock refreshAdBlock = ^(Ad* ad) {
        [self prepareViewWithContentsOfTheAd];
    };
    [self setNotification:kNotifyAdSaved forAction:refreshAdBlock];
    
    VoidBlock requestJoinHandler = ^{
        [self performSegueWithIdentifier:@"JoinRequest" sender:nil];
    };
    
//    UserBlock userSelectedBlock = ^(User* user) {
//        [self performSegueWithIdentifier:@"PreviewUser" sender:user];
//    };
    
    [self.candidatesCollection setRequestJoinBlock:requestJoinHandler];
//    [self.candidatesCollection setUserIdSelectedBlock:userSelectedBlock];
    
    setButtonTintColor(self.previewMapButton, kAppColor);
    self.addressBack.backgroundColor = kAppColor;

    [self prepareViewWithContentsOfTheAd];
}

- (void) prepareViewWithContentsOfTheAd
{
    self.editMenuButton.enabled = self.ad.isMine;

    
    [self.ad fetched:^{
        [self.ad firstMediaImageLoaded:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImageView.image = image;
            });
        }];
        
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
        self.introLabel.text = self.ad.intro;
        
        self.eventDateLabel.text = [NSDateFormatter dateFormatFromTemplate:@"EEE dd. HH:MM" options:0 locale:[NSLocale currentLocale]];
        self.eventDateLabel.hidden = !(self.ad.eventDate);
    }];
    [self.ad.adLocation fetched:^{
        self.addressLabel.text = self.ad.adLocation.address;
        [self.ad.adLocation mapImageWithPinColor:colorBlue size:self.mapView.bounds.size handler:^(UIImage *image) {
            self.mapView.image = image;
        }];
        
        [self.ad countViewed:^(NSUInteger count) {
            self.viewedByLabel.text = @(count).stringValue;
        }];
        [self.ad countLikes:^(NSUInteger count) {
            self.likedByLabel.text = @(count).stringValue;
        }];
    }];
    
    self.adMediaCollection.editable = NO;
    self.adMediaCollection.tintColor = kAppColor;
    [UserMedia fetchAllIfNeededInBackground:self.ad.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.adMediaCollection.parentController = self;
        self.adMediaCollection.ad = self.ad;
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
        join.adJoinRequestBlock = ^(AdJoin* adjoin) {
            [self.candidatesCollection addJoin:adjoin];
        };
    }
    if ([segue.identifier isEqualToString:@"EditAd"]) {
        UINavigationController *nvc = segue.destinationViewController;
        PostAd *postAd = nvc.viewControllers.firstObject;
        postAd.ad = [sender isKindOfClass:[Ad class]] ? sender : self.ad;
    }
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    NSLog(@"AD:%@", ad);
    [self prepareViewWithContentsOfTheAd];
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
        
        return y + h + 10;
    }
    else if (indexPath.row == 1) // Candidates Collection
    {
        return 130;
    }
    else if (indexPath.row == 2) // Media Collection
    {
        return 200;
    }
    else {
        return 280;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

#pragma mark - Table view data source


@end
