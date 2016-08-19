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
#import "AdMiniCell.h"
#import "AdRowCell.h"
#import "ParallaxView.h"
#import "LocationManagerController.h"

#define kQueryLimit 20
#define kRecentAdsPin @"RecentAdsPin"


@interface UserAdsV2 ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;

@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) Notifications *notifications;
@end

@implementation UserAdsV2

static NSString* const kUpdatedAt = @"updatedAt";
static NSString* const kCreatedAt = @"createdAt";

static NSString* const kAdsCollectionRow = @"AdsCollectionRow";
static NSString* const kAdButton = @"AdButton";
static NSString* const kAdsCategoryRow = @"AdsCategoryRow";

typedef enum {
    kSectionTypeAd = 0,
    kSectionTypeButton,
    kSectionTypeCategory,
} AdSectionTypes;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.locationManager = [LocationManager new];
    self.notifications = [Notifications new];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.parallax.scrollOffset = scrollView.contentOffset.y;
}

- (IBAction)test:(id)sender
{
    [LocationManagerController controllerFromViewController:self withHandler:^(AdLocation *adLoc, UIImage *image) {
        __LF
    } pinColor:nil initialLocation:[User me].location];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    registerTableViewCellNib(kAdButton, self.tableView);
    registerTableViewCellNib(kAdsCategoryRow, self.tableView);
    registerTableViewCellNib(kAdsCollectionRow, self.tableView);
    
    CGFloat w = CGRectGetWidth(self.tableView.bounds);
    
    CGFloat cw = w - 40;
    CGFloat ch = floor(cw * 0.8);
    CGFloat rh = floor(ch+70);
    
    CGFloat ms = (cw - 10) / 2.0f;
    CGFloat mh = ms + 70;
    
    self.sections = @[
                      [NSMutableDictionary dictionaryWithDictionary:
                      @{
                          @"id" : @(kSectionRecent),
                          @"type"  : @(kSectionTypeAd),
                          @"query" : [self queryAdsRecent],
                          @"title" : @"Recent searches",
                          @"items" : [NSMutableArray array],
                          @"cell"  : [AdRowCell new],
                          @"rowHeight" : @(mh),
                          @"cellGeometry" : [NSValue valueWithCGSize:CGSizeMake(.4f, 1.0f)],
                          @"cellSize" : [NSValue valueWithCGSize:CGSizeMake(ms, ms)],
                          @"cellIdentifier" : @"AdMiniCell",
                          }],
                      @{
                          @"id" : @(kSectionPostNewAd),
                          @"type"  : @(kSectionTypeButton),
                          @"title" : @"Post new Ad",
                          @"subTitle" : @"and discover new friends @ withme",
                          @"coverImage" : [UIImage imageNamed:@"NewPost"],
                          @"visible" : @(YES),
                          @"rowHeight" : @(290),
                          },
                      @{
                          @"id" : @(kSectionCategory),
                          @"type"  : @(kSectionTypeCategory),
                          @"title" : @"By Category",
                          @"visible" : @(YES),
                          @"rowHeight" : @(280),
                          },
                      [NSMutableDictionary dictionaryWithDictionary:
                      @{
                          @"id" : @(kSectionByUser),
                          @"type"  : @(kSectionTypeAd),
                          @"query" : [self queryAdsByUser],
                          @"title" : @"Your Ads",
                          @"items" : [NSMutableArray array],
                          @"cell"  : [AdRowCell new],
                          @"rowHeight" : @(mh),
                          @"cellGeometry" : [NSValue valueWithCGSize:CGSizeMake(.4f, 1.0f)],
                          @"cellSize" : [NSValue valueWithCGSize:CGSizeMake(ms, ms)],
                          @"cellIdentifier" : @"AdMiniCell",
                          }],
                      [NSMutableDictionary dictionaryWithDictionary:
                       @{
                         @"id" : @(kSectionNewAds),
                         @"type"  : @(kSectionTypeAd),
                         @"query" : [self queryAdsNew],
                         @"title" : @"New Ads",
                         @"items" : [NSMutableArray array],
                         @"cell"  : [AdRowCell new],
                         @"rowHeight" : @(rh),
                         @"cellGeometry" : [NSValue valueWithCGSize:CGSizeMake(.9f, 1.0f)],
                         @"cellSize" : [NSValue valueWithCGSize:CGSizeMake(cw, ch)],
                         @"cellIdentifier" : @"AdCell",
                         }],
                      [NSMutableDictionary dictionaryWithDictionary:
                       @{
                         @"id" : @(kSectionArea),
                         @"type"  : @(kSectionTypeAd),
                         @"query" : [self queryAdsArea],
                         @"queryName" : [ObjectIdStore newObjectId],
                         @"title" : @"Ads in your area",
                         @"items" : [NSMutableArray array],
                         @"cell"  : [AdRowCell new],
                         @"rowHeight" : @(rh),
                         @"cellGeometry" : [NSValue valueWithCGSize:CGSizeMake(.9f, 1.0f)],
                         @"cellSize" : [NSValue valueWithCGSize:CGSizeMake(cw, ch)],
                         @"cellIdentifier" : @"AdCell",
                         }],
                      [NSMutableDictionary dictionaryWithDictionary:
                       @{
                         @"id" : @(kSectionTrending),
                         @"type"  : @(kSectionTypeAd),
                         @"query" : [self queryAdsTrending],
                         @"queryName" : [ObjectIdStore newObjectId],
                         @"title" : @"Trending currently...",
                         @"items" : [NSMutableArray array],
                         @"cell"  : [AdRowCell new],
                         @"rowHeight" : @(mh),
                         @"cellGeometry" : [NSValue valueWithCGSize:CGSizeMake(.4f, 1.0f)],
                         @"cellSize" : [NSValue valueWithCGSize:CGSizeMake(ms, ms)],
                         @"cellIdentifier" : @"AdMiniCell",
                         }],
                        @{
                          @"id" : @(kSectionInvite),
                          @"type"  : @(kSectionTypeButton),
                          @"title" : @"Invite your friends",
                          @"subTitle" : @"and discover new friends @ withme",
                          @"coverImage" : [UIImage imageNamed:@"NewPost"],
                          @"visible" : @(YES),
                          @"rowHeight" : @(290),
                          },
                      ];
    
//    [PFObject unpinAllObjectsWithName:kRecentAdsPin];
    
    ActionBlock action = ^(id actionParams) {
        [self setupUserPage];
        [self.tableView reloadData];
    };
    
    [self.notifications setNotification:@"NotifyUserSaved" forAction:action];
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
        [me profileMediaThumbnailLoaded:^(UIImage *image) {
            self.photoView.image = image;
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
    CGFloat height = [params[@"rowHeight"] floatValue];
    
    return height == 0 ? 280 : height;
}

- (void)viewAdDetail:(Ad *)ad
{
    [ad pinInBackgroundWithName:kRecentAdsPin block:^(BOOL succeeded, NSError * _Nullable error) {
        id params = [self.sections firstObject]; // Recent;
        [params setObject:@(NO) forKey:@"queryInitiated"];
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
    AdSectionTypes type = (AdSectionTypes)[params[@"type"] integerValue];
    
    switch (type) {
        case kSectionTypeButton: {
            AdButton *cell = [tableView dequeueReusableCellWithIdentifier:kAdButton forIndexPath:indexPath];
            [cell setButtonIndex:section
                           title:params[@"title"]
                        subTitle:params[@"subTitle"]
                      coverImage:params[@"coverImage"]
                  buttonDelegate:self];
            return cell;
        }
            break;
        case kSectionTypeCategory:
        {
            AdsCategoryRow *cell = [tableView dequeueReusableCellWithIdentifier:kAdsCategoryRow forIndexPath:indexPath];
            cell.categoriesCollection.categoryDelegate = self;
            cell.categoriesCollection.categories = [WithMe new].categories;
            cell.titleLabel.text = params[@"title"];
            return cell;
        }
            
        default:
        {
            AdRowCell* cell = params[@"cell"];
            cell.adDelegate = self;
            [cell setParams:params forRow:indexPath.section];
            return cell;
        }
            break;
    }
}

@end
