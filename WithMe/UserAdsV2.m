//
//  UserAdsV2.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserAdsV2.h"
#import "AdButton.h"
#import "RefreshControl.h"
#import "QueryManager.h"
#import "LocationManager.h"
#import "QueryManager.h"
#import "UserProfile.h"
#import "AdDetail.h"

#define kQueryLimit 20

@interface UserAdsV2 ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (strong, nonatomic) LocationManager *locationManager;
@end

@implementation UserAdsV2

static NSString* const kUpdatedAt = @"updatedAt";
static NSString* const kAdsCollectionRow = @"AdsCollectionRow";
static NSString* const kAdButton = @"AdButton";
static NSString* const kAdsCategoryRow = @"AdsCategoryRow";


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.locationManager = [LocationManager new];
}

- (PFQuery *) queryAdsNew
{
    PFQuery *query = [Ad query];
    [query orderByDescending:kUpdatedAt];
    return query;
}

- (PFQuery *) queryAdsByUser
{
    PFQuery *query = [Ad query];
    [query whereKey:@"user" equalTo:[User me]];
    [query orderByDescending:kUpdatedAt];
    return query;
}

- (PFQuery *) queryAdsRecent
{
    PFQuery *query = [Ad query];
    [query fromPinWithName:@"RecentAdsPin"];
    [query orderByDescending:kUpdatedAt];
    return query;
}

- (PFQuery *) queryAdsArea
{
    PFQuery *query = [Ad query];
    [query whereKey:@"location" nearGeoPoint:self.locationManager.location];
    return query;
}

- (PFQuery *) queryAdsTrending
{
    PFQuery *query = [Ad query];
    [query orderByDescending:@"likesCount"];
    [query orderByDescending:kUpdatedAt];
    return query;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    registerTableViewCellNib(kAdButton, self.tableView);
    registerTableViewCellNib(kAdsCategoryRow, self.tableView);
    registerTableViewCellNib(kAdsCollectionRow, self.tableView);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupUserPage];
}

- (void)setupUserPage
{
    BOOL returningUser = [[[NSUserDefaults standardUserDefaults] valueForKey:@"returningUser"] boolValue];
    self.welcomeLabel.text = returningUser ? @"Welcome back" : @"Welcome";
    if (!returningUser) {
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"returningUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    User *me = [User me];
    showView(self.photoView, NO);
    [me fetched:^{
        self.nicknameLabel.text = me.nickname;
        UserMedia *media = me.profileMedia;
        [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
            self.photoView.image = [UIImage imageWithData:data];
            showView(self.photoView, YES);
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    NSInteger count = 1;
    
    switch ((AdCollectionSections)indexPath.row) {
        case kSectionPostNewAd:
        case kSectionInvite:
            count = 1;
            height = 100;
            break;
        case kSectionByUser:
        case kSectionRecent:
        case kSectionNewAds:
        case kSectionArea:
        case kSectionTrending:
            height = 360;
            break;
        case kSectionCategory:
            height = 280;
            break;
    }
    
    return count > 0 ? height : 80;
}

- (void)adSelected:(Ad *)ad
{
    __LF
    [ad addUniqueObject:[User me] forKey:@"viewedBy"];
    [ad saveEventually];
    [self performSegueWithIdentifier:@"ShowAd" sender:ad];
}

- (void)viewCategory:(Category *)category
{
    NSLog(@"Category selected:%@", category);
}

- (void)buttonSelected:(NSInteger)index
{
    if (index == 0) {
        NSLog(@"POST NEW AD");
    }
    else {
        NSLog(@"INVITE MORE FRIENDS");
    }
}

- (void)viewUserProfile:(User *)user
{
    [self performSegueWithIdentifier:@"EditProfile" sender:user];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    __LF
    if ([segue.identifier isEqualToString:@"EditProfile"] && [sender isKindOfClass:[User class]]) {
        UserProfile *vc = segue.destinationViewController;
        vc.user = sender;
    }
    if ([segue.identifier isEqualToString:@"ShowAd"] && [sender isKindOfClass:[Ad class]]) {
        AdDetail *vc = segue.destinationViewController;
        vc.ad = sender;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((AdCollectionSections)indexPath.row) {
        case kSectionPostNewAd:
        {
            AdButton *cell = [tableView dequeueReusableCellWithIdentifier:kAdButton forIndexPath:indexPath];
            cell.titleLabel.text = @"Post your Ad";
            cell.subTitleLabel.text = @"and discover new friends @ withme";
            cell.imageView.image = [UIImage imageNamed:@"NewPost"];
            cell.index = 0;
            cell.buttonDelegate = self;
            return cell;
        }
        case kSectionInvite:
        {
            AdButton *cell = [tableView dequeueReusableCellWithIdentifier:kAdButton forIndexPath:indexPath];
            cell.titleLabel.text = @"Invite your friends";
            cell.subTitleLabel.text = @"and earn free credit to chat online";
            cell.imageView.image = [UIImage imageNamed:@"NewPost"];
            cell.index = 1;
            cell.buttonDelegate = self;
            return cell;
        }
        case kSectionRecent:
        case kSectionNewAds:
        case kSectionArea:
        case kSectionByUser:
        case kSectionTrending:
        {
            AdsCollectionRow *cell = [tableView dequeueReusableCellWithIdentifier:kAdsCollectionRow forIndexPath:indexPath];
            cell.titleLabel.text = [self labelForSection:indexPath.row];
            cell.adsCollection.adDelegate = self;
            [cell.adsCollection setQuery:[self queryForRowForSection:indexPath.row] named:[self queryNamesForSection:indexPath.row]];
            return cell;
        }
        case kSectionCategory:
        {
            AdsCategoryRow *cell = [tableView dequeueReusableCellWithIdentifier:kAdsCategoryRow forIndexPath:indexPath];
            cell.categoriesCollection.categoryDelegate = self;
            cell.categoriesCollection.categories = [WithMe new].categories;
            cell.titleLabel.text = @"Ads by category";
            return cell;
        }
    }
}

- (NSString*) queryNamesForSection:(AdCollectionSections)section
{
    switch (section) {
        case kSectionRecent:
            return @"QueryRecent";
        case kSectionArea:
            return @"QueryNear";
        case kSectionByUser:
            return @"QueryUser";
        case kSectionNewAds:
            return @"QueryNew";
        case kSectionTrending:
            return @"QueryTrending";
        default:
            return @"DefaultQueryName";
    }
}

- (PFQuery*) queryForRowForSection:(AdCollectionSections)section
{
    switch (section) {
        case kSectionRecent:
            return [self queryAdsRecent];
        case kSectionArea:
            return [self queryAdsArea];
        case kSectionByUser:
            return [self queryAdsByUser];
        case kSectionNewAds:
            return [self queryAdsNew];
        case kSectionTrending:
            return [self queryAdsTrending];
        default:
            return nil;
    }
}

- (NSString*) labelForSection:(AdCollectionSections)section
{
    switch (section) {
        case kSectionRecent:
            return @"Recent searches";
        case kSectionArea:
            return @"Ads near you";
        case kSectionByUser:
            return @"Ads by you";
        case kSectionNewAds:
            return @"New Ads";
        case kSectionTrending:
            return @"Trending Ads";
        default:
            return nil;
    }
}

@end
