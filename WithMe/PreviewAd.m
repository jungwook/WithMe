//
//  PreviewAd.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PreviewAd.h"
#import "IndentedLabel.h"
#import "CollectionView.h"
#import "ParallaxView.h"
#import "IconLabel.h"

@interface PreviewAd ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *categoryLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *activityLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *paymentLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *participantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet CollectionView *mediaCollection;
@property (weak, nonatomic) IBOutlet UIImageView *mapView;
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;
@property (weak, nonatomic) IBOutlet IconLabel *viewedByLabel;
@property (weak, nonatomic) IBOutlet IconLabel *likedByLabel;
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
    
    [self.parallax setNavigationBarProperties:self.navigationController.navigationBar];

    [self.ad firstMediaImageLoaded:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profileImageView.image = image;
        });
    }];
    
    [self.ad fetched:^{
        [self.ad userProfileThumbnailLoaded:^(UIImage *image) {
            NSLog(@"UIIMAGE:%@ %@", image, self.profileImageView);
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
        self.participantsLabel.text = [@(self.ad.ourParticipants + self.ad.yourParticipants).stringValue stringByAppendingString:@" ppl."];
        self.introLabel.text = self.ad.intro;
        
        self.eventDateLabel.text = [NSDateFormatter dateFormatFromTemplate:@"EEE dd. HH:MM" options:0 locale:[NSLocale currentLocale]];
        self.eventDateLabel.hidden = !(self.ad.eventDate);
    }];
    [self.ad.adLocation fetched:^{
        NSLog(@"AD:%@", self.ad.adLocation);
        self.addressLabel.text = self.ad.adLocation.address;
        [self.ad.adLocation mapImageWithPinColor:colorBlue size:self.mapView.bounds.size handler:^(UIImage *image) {
            NSLog(@"AD LOC");
            self.mapView.image = image;
        }];
        
        self.viewedByLabel.image = [UIImage imageNamed:@"viewedby"];
        self.likedByLabel.image = [UIImage imageNamed:@"like red"];
        self.viewedByLabel.text = @(self.ad.viewedByCount).stringValue;
        self.likedByLabel.text = @(self.ad.likesCount).stringValue;
    }];
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
        NSLog(@"INTROLABEL:%@", NSStringFromCGRect(self.introLabel.frame));
        CGRect rect = rectForString(self.ad.intro, self.introLabel.font, w);
        CGFloat h = CGRectGetHeight(rect);
        
        return y + h + 20;
    }
    return 280;
}

#pragma mark - Table view data source


@end
