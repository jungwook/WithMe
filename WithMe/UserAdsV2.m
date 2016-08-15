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
#define kRecentAdsPin @"RecentAdsPin"

@interface UserAdsV2 ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) NSArray *sections;
@end

@implementation UserAdsV2

static NSString* const kUpdatedAt = @"updatedAt";
static NSString* const kCreatedAt = @"createdAt";

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
    [query orderByDescending:kCreatedAt];
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
    [query fromPinWithName:kRecentAdsPin];
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
    [query orderByDescending:@"viewedByCount"];
    [query orderByDescending:kUpdatedAt];
    return query;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    registerTableViewCellNib(kAdButton, self.tableView);
    registerTableViewCellNib(kAdsCategoryRow, self.tableView);
    registerTableViewCellNib(kAdsCollectionRow, self.tableView);
    
    
    self.sections = @[
                      @{
                          @"id" : @(kSectionRecent),
                          @"query" : [self queryAdsRecent],
//                          @"queryName" : [ObjectIdStore newObjectId],
                          @"queryName" : @"QUERYNAMERECENT",
                          @"title" : @"Recent searches",
                          @"visible" : @(NO),
                          },
                      @{
                          @"id" : @(kSectionByUser),
                          @"query" : [self queryAdsByUser],
                          @"queryName" : [ObjectIdStore newObjectId],
                          @"title" : @"Your Ads",
                          @"visible" : @(NO),
                          },
                      @{
                          @"id" : @(kSectionNewAds),
                          @"query" : [self queryAdsNew],
                          @"queryName" : [ObjectIdStore newObjectId],
                          @"title" : @"Newest Ads",
                          @"visible" : @(NO),
                          },
                      @{
                          @"id" : @(kSectionPostNewAd),
                          @"title" : @"Post new Ad",
                          @"subTitle" : @"and discover new friends @ withme",
                          @"coverImage" : [UIImage imageNamed:@"NewPost"],
                          @"visible" : @(YES),
                          },
                      @{
                          @"id" : @(kSectionArea),
                          @"query" : [self queryAdsArea],
                          @"queryName" : [ObjectIdStore newObjectId],
                          @"title" : @"Ads near you",
                          @"visible" : @(NO),
                          },
                      @{
                          @"id" : @(kSectionCategory),
                          @"title" : @"By Category",
                          @"visible" : @(YES),
                          },
                      @{
                          @"id" : @(kSectionTrending),
                          @"query" : [self queryAdsTrending],
                          @"queryName" : [ObjectIdStore newObjectId],
                          @"title" : @"HOT Ads",
                          @"visible" : @(NO),
                          },
                      @{
                          @"id" : @(kSectionInvite),
                          @"title" : @"Invite your friends",
                          @"subTitle" : @"and discover new friends @ withme",
                          @"coverImage" : [UIImage imageNamed:@"NewPost"],
                          @"visible" : @(YES),
                          },
                      ];
    
    [PFObject unpinAllObjectsWithName:kRecentAdsPin];
}

- (NSString*) queryNameForSection:(AdCollectionSections)section
{
    __block NSString* name = nil;
    [self.sections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"id"] integerValue] == section) {
            *stop = YES;
            name = obj[@"queryName"];
        }
    }];
    return name;
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
    id params = [self.sections objectAtIndex:indexPath.section];
    AdCollectionSections section = [params[@"id"] integerValue];
    QueryManagerItem *qItem = [QueryManager queryItemNamed:params[@"queryName"]];

    CGFloat height = 0;
    NSInteger count = 1;
    
    switch (section) {
        case kSectionPostNewAd:
        case kSectionInvite:
            count = 1;
            height = 280;
            break;
        case kSectionByUser:
        case kSectionRecent:
        case kSectionNewAds:
        case kSectionArea:
        case kSectionTrending:
            count = qItem.items.count;
            height = 360;
            break;
        case kSectionCategory:
            count = 1;
            height = 280;
            break;
    }
    
    return count > 0 ? height : height;
}

- (void)adsCollectionLoaded:(NSInteger)index additional:(BOOL)additionalLoaded
{
    __LF
    if (!additionalLoaded) {
        [self.tableView beginUpdates];
        {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
    }
}

- (void)viewAdDetail:(Ad *)ad
{
    __LF
    [ad pinInBackgroundWithName:kRecentAdsPin block:^(BOOL succeeded, NSError * _Nullable error) {
        [QueryManager removeQueryItemNamed:[self queryNameForSection:kSectionRecent]];
        AdsCollectionRow *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionRecent]];
        [cell.adsCollection reset];
        [self.tableView reloadData];

        [ad viewedByUser:[User me] handler:^{
            [self performSegueWithIdentifier:@"ShowAd" sender:ad];
        }];
    }];
}

- (void)viewCategory:(Category *)category
{
    NSLog(@"Category selected:%@", category);
}

- (void)buttonSelected:(NSInteger)index
{
    if (index == kSectionNewAds) {
        NSLog(@"POST NEW AD");
    }
    else if (index == kSectionInvite){
        NSLog(@"INVITE MORE FRIENDS");
    }
    else {
        NSLog(@"SOEMTHING WRONG");
    }
}

- (void)viewUserProfile:(User *)user
{
    __LF
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id params = [self.sections objectAtIndex:indexPath.section];
    AdCollectionSections section = [params[@"id"] integerValue];
    
    switch (section) {
        case kSectionPostNewAd:
        case kSectionInvite:
        {
            AdButton *cell = [tableView dequeueReusableCellWithIdentifier:kAdButton forIndexPath:indexPath];
            [cell setButtonIndex:section
                           title:params[@"title"]
                        subTitle:params[@"subTitle"]
                      coverImage:params[@"coverImage"]
                  buttonDelegate:self];
            return cell;
        }
        case kSectionRecent:
        case kSectionNewAds:
        case kSectionArea:
        case kSectionByUser:
        case kSectionTrending:
        {
            AdsCollectionRow *cell = [tableView dequeueReusableCellWithIdentifier:kAdsCollectionRow forIndexPath:indexPath];
            cell.titleLabel.text = params[@"title"];
            cell.adsCollection.adDelegate = self;
            [cell.adsCollection setQuery:params[@"query"]
                                   named:params[@"queryName"]
                                   index:section
                         cellIndentifier:@"AdCollectionCell"];
            return cell;
        }
        case kSectionCategory:
        {
            AdsCategoryRow *cell = [tableView dequeueReusableCellWithIdentifier:kAdsCategoryRow forIndexPath:indexPath];
            cell.categoriesCollection.categoryDelegate = self;
            cell.categoriesCollection.categories = [WithMe new].categories;
            cell.titleLabel.text = params[@"title"];
            return cell;
        }
    }
}

@end
