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

#define kQueryLimit 20

@interface UserAdsV2 ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) QueryManager *queryManagerRecent;
@property (strong, nonatomic) NSMutableArray *adsRecent;
@property (strong, nonatomic) NSMutableArray *adsTrending;
@property (strong, nonatomic) NSDate *lastUpdateAdsNew;
@property (strong, nonatomic) NSDate *lastUpdateAdsTrending;
@property (strong, nonatomic) NSDate *lastUpdateAdsArea;
@end

@implementation UserAdsV2

static NSString* const kUpdatedAt = @"updatedAt";
static NSString* const kAdCollection = @"AdCollection";
static NSString* const kAdButton = @"AdButton";



- (void)awakeFromNib
{
    [super awakeFromNib];
    self.locationManager = [LocationManager new];
}

- (void) loadAdsNew:(BOOL)isInitialLoad
{
    AdCollectionSections colSection = kSectionNewAds;
    
    SectionObject *section = [self.sections objectAtIndex:colSection];
    __block NSInteger numLoaded = section.items.count;
    
    PFQuery *query = [Ad query];
    [query setSkip:numLoaded];
    [query setLimit:5];
    [query orderByDescending:kUpdatedAt];
    
    [QueryManager query:query objects:^(NSArray * _Nullable objects) {
        numLoaded += objects.count;
        [self workItems:section objects:objects section:colSection initialLoad:isInitialLoad];
    }];
}

- (void) loadAdsRecent:(BOOL)isInitialLoad
{
    AdCollectionSections colSection = kSectionRecent;
    
    SectionObject *section = [self.sections objectAtIndex:colSection];
    __block NSInteger numLoaded = section.items.count;
    
    PFQuery *query = [Ad query];
    [query fromPinWithName:@"RecentAdsPin"];
    [query orderByDescending:kUpdatedAt];
    [query setSkip:numLoaded];
    [query setLimit:5];
    
    [QueryManager query:query objects:^(NSArray * _Nullable objects) {
        numLoaded += objects.count;
        [self workItems:section objects:objects section:colSection initialLoad:isInitialLoad];
    }];
}

- (void) loadAdsArea:(BOOL)isInitialLoad
{
    AdCollectionSections colSection = kSectionArea;

    SectionObject *section = [self.sections objectAtIndex:colSection];
    __block NSInteger numLoaded = section.items.count;
    
    PFQuery *query = [Ad query];
    [query setSkip:numLoaded];
    [query setLimit:5];
    [query whereKey:@"location" nearGeoPoint:self.locationManager.location];
    
    [QueryManager query:query objects:^(NSArray * _Nullable objects) {
        numLoaded += objects.count;
        [self workItems:section objects:objects section:colSection initialLoad:isInitialLoad];
    }];
}

- (void) loadAdsTrending:(BOOL)isInitialLoad
{
    AdCollectionSections colSection = kSectionTrending;
    
    SectionObject *section = [self.sections objectAtIndex:colSection];
    __block NSInteger numLoaded = section.items.count;
    
    PFQuery *query = [Ad query];
    [query setSkip:numLoaded];
    [query setLimit:5];
//    [query whereKey:@"likesCount" greaterThan:@(0)];
    [query orderByDescending:@"likesCount"];
    [query orderByDescending:kUpdatedAt];
    
    [QueryManager query:query objects:^(NSArray * _Nullable objects) {
        numLoaded += objects.count;
        [self workItems:section objects:objects section:colSection initialLoad:isInitialLoad];
    }];
}

- (void) loadAdsCategories
{
    SectionObject *section = [self.sections objectAtIndex:kSectionCategory];
    section.items = [NSMutableArray arrayWithArray:[WithMe new].categories];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kSectionCategory inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) workItems:(SectionObject*)section
           objects:(NSArray*)objects
           section:(AdCollectionSections)colSection
       initialLoad:(BOOL)isInitialLoad
{
    if (isInitialLoad) {
        __block NSInteger count = objects.count;
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad mediaAndUserReady:^{
                if (--count == 0) {
                    section.items = [NSMutableArray arrayWithArray:objects];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:colSection inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
        }];
    }
    else {
        AdCollection *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:colSection inSection:0]];
        __block NSInteger count = objects.count;
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad mediaAndUserReady:^{
                if (--count == 0) {
                    [section.items addObjectsFromArray:objects];
                    [cell moreItemsAdded:indexPathsFromIndex(section.items.count-objects.count, objects.count)];
                }
            }];
        }];
    }
}

NSArray* indexPathsFromIndex(NSInteger index, NSInteger count)
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        [array addObject:[NSIndexPath indexPathForRow:index+i inSection:0]];
    }
    return array;
}

- (void)loadMoreForSection:(SectionObject *)section
{
    __LF
    switch (section.section) {
        case kSectionArea:
            [self loadAdsArea:NO];
            break;
        case kSectionNewAds:
            [self loadAdsNew:NO];
            break;
        
        case kSectionTrending:
            [self loadAdsTrending:NO];
            break;
            
        case kSectionRecent:
            [self loadAdsRecent:NO];
            break;
        
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sections = @[
                      [SectionObject sectionObjectWithIdentifier:kAdCollection
                                                         section:kSectionRecent
                                                           title:@"Recent Searches"
                                                        subTitle:@""
                                                           image:nil
                                                           items:nil],
                      [SectionObject sectionObjectWithIdentifier:kAdCollection
                                                         section:kSectionNewAds
                                                           title:@"New Ads"
                                                        subTitle:@""
                                                           image:nil
                                                           items:nil],
                      [SectionObject sectionObjectWithIdentifier:kAdButton
                                                         section:kSectionPostNewAd
                                                           title:@"Post your Ad"
                                                        subTitle:@"and discover new friends @ withme"
                                                           image:[UIImage imageNamed:@"NewPost"]
                                                           items:nil],
                      [SectionObject sectionObjectWithIdentifier:kAdCollection
                                                         section:kSectionArea
                                                           title:@"Ads in your area"
                                                        subTitle:@""
                                                           image:nil
                                                           items:nil],
                      [SectionObject sectionObjectWithIdentifier:kAdCollection 
                                                         section:kSectionCategory
                                                           title:@"Ads by category" 
                                                        subTitle:@""
                                                           image:nil
                                                           items:nil],
                      [SectionObject sectionObjectWithIdentifier:kAdCollection 
                                                         section:kSectionTrending
                                                           title:@"Trending Ads..." 
                                                        subTitle:@"" 
                                                           image:nil 
                                                           items:nil],
                      [SectionObject sectionObjectWithIdentifier:kAdButton 
                                                         section:kSectionInvite
                                                           title:@"Invite your friends @ withme"
                                                        subTitle:@"and receive credits to chat online"
                                                           image:[UIImage imageNamed:@"Invite"]
                                                           items:nil],
                      ];
    
    registerTableViewCellNib(kAdCollection, self.tableView);
    registerTableViewCellNib(kAdButton, self.tableView);

    [self loadAdsNew:YES];
    [self loadAdsRecent:YES];
    [self loadAdsArea:YES];
    [self loadAdsTrending:YES];
    [self loadAdsCategories];
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
    SectionObject *section = [self.sections objectAtIndex:indexPath.row];

    CGFloat height = 0;
    NSInteger count = section.items.count;
    switch ((AdCollectionSections)indexPath.row) {
        case kSectionPostNewAd:
        case kSectionInvite:
            count = 1;
            height = 260;
            break;
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
    
    return count > 0 ? height : 0;
}

- (void)adSelected:(Ad *)ad
{
    __LF
    NSLog(@"Ad selected:%@", ad);
}

- (void)categorySelected:(Category *)category
{
    __LF
    NSLog(@"Category selected:%@", category);
}

- (void)buttonSelected:(SectionObject *)section
{
    if (section.section == kSectionPostNewAd) {
        NSLog(@"POST NEW AD");
    }
    else if (section.section == kSectionInvite) {
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionObject *section = [self.sections objectAtIndex:indexPath.row];
    id cellIndentifier = section.identifier;
    
    switch ((AdCollectionSections)indexPath.row) {
        case kSectionPostNewAd:
        case kSectionInvite:
        {
            AdButton *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
            cell.section = section;
            cell.delegate = self;
            return cell;
        }
        case kSectionRecent:
        case kSectionNewAds:
        case kSectionArea:
        case kSectionTrending:
        {
            AdCollection *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
            cell.section = section;
            cell.delegate = self;
            return cell;
        }
        case kSectionCategory:
        {
            AdCollection *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
            cell.section = section;
            cell.delegate = self;
            return cell;
        }
    }
}


@end
