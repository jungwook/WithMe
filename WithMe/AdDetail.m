//
//  AdDetail.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdDetail.h"
#import "SlideShow.h"
#import "UserProfile.h"
#import "QueryManager.h"

#define kUpdatedAt @"updatedAt"
#define kAdRowCell @"AdRowCell"
#define kAdDetailCell @"AdDetailCell"
#define kViewControllerIdentifier @"AdDetail"
#define kShowUserIdentifier @"ShowUser"

enum {
    kViewSectionDetail = 0,
    kViewSectionAds,
};

@interface AdDetail ()
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoView;
@property (weak, nonatomic) IBOutlet SlideShow *slideShow;
@property (weak, nonatomic) IBOutlet UIPageControl *sliderPage;
@property (strong, nonatomic) NSArray *mediaImages;
@property (strong, nonatomic) UIFont* introFont;
@property (strong, nonatomic) NSArray *sections;
@end

@implementation AdDetail

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.introFont = [UIFont systemFontOfSize:15];
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    
    self.activityLabel.text = ad.activity.name;
    self.categoryLabel.text = ad.activity.category.name;
}

- (void)viewDidLoad {
    __LF
    [super viewDidLoad];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:kAdDetailCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kAdDetailCell];
    [self.tableView registerNib:[UINib nibWithNibName:kAdRowCell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kAdRowCell];
        
    [self.ad userProfileThumbnailLoaded:^(UIImage *image) {
        self.userPhotoView.image = image;
        self.activityLabel.text = self.ad.activity.name;
        self.categoryLabel.text = self.ad.activity.category.name;
    }];
    
    [self.ad mediaImagesLoaded:^(NSArray *array) {
        self.mediaImages = array;
        self.sliderPage.numberOfPages = array.count;
        self.slideShow.images = array;
        self.slideShow.delay = 5;
        self.slideShow.transitionDuration = 0.4;
        self.slideShow.transitionType = SlideShowTransitionSlideHorizontal;
        self.slideShow.imagesContentMode = UIViewContentModeScaleAspectFill;
        self.slideShow.showingHandler = ^(NSInteger index) {
            self.sliderPage.currentPage = index;
        };
        [self.slideShow addGesture:SlideShowGestureAll];
        [self.slideShow start];
    }];
    
    self.sections = @[
                      [NSMutableDictionary dictionaryWithDictionary:
                       @{
                         @"id" : @(0),
                         @"query" : [self queryByUser],
                         @"title" : [NSString stringWithFormat:@"Other Ads by %@", self.ad.user.nickname],
                         @"items" : [NSMutableArray array],
                         @"cell"  : [[[NSBundle mainBundle] loadNibNamed:@"AdRowCell" owner:self options:nil] firstObject],
                         @"rowHeight" : @(200),
                         @"cellGeometry" : [NSValue valueWithCGSize:CGSizeMake(.9f, 1.0f)],
                         @"cellIdentifier" : @"AdCell",
                         }],
                      [NSMutableDictionary dictionaryWithDictionary:
                       @{
                         @"id" : @(1),
                         @"query" : [self querySimilar],
                         @"title" : @"Similar Ads",
                         @"items" : [NSMutableArray array],
                         @"cell"  : [[[NSBundle mainBundle] loadNibNamed:@"AdRowCell" owner:self options:nil] firstObject],
                         @"rowHeight" : @(200),
                         @"cellGeometry" : [NSValue valueWithCGSize:CGSizeMake(.9f, 1.0f)],
                         @"cellIdentifier" : @"AdCell",
                         }],
                      ];
                      
}

- (PFQuery*) queryByUser
{
    PFQuery *query = [Ad query];
    
    [query whereKey:@"user" equalTo:self.ad.user];
    [query whereKey:@"objectId" notEqualTo:self.ad.objectId];
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

- (PFQuery*) querySimilar
{
    PFQuery *query = [Ad query];
    
    [query whereKey:@"activity" equalTo:self.ad.activity];
    [query whereKey:@"objectId" notEqualTo:self.ad.objectId];
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

#pragma mark - KASlideShow delegate

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        AdDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kAdDetailCell forIndexPath:indexPath];
        cell.ad = self.ad;
        cell.showUserDelegate = self;
        return cell;
    }
    else {
        id params = [self.sections objectAtIndex:indexPath.row];
        AdRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kAdRowCell forIndexPath:indexPath];
        [cell setParams:params forRow:indexPath.row];
        [cell setAdDelegate:self];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kViewSectionDetail: {
            CGFloat w = CGRectGetWidth(tableView.bounds);
            CGRect rect = rectForString(self.ad.intro, self.introFont, w-36);
            return CGRectGetHeight(rect)+355;
        }
        default: {
            return 300;
        }
    }
}

- (void)viewAdDetail:(Ad *)ad
{
    AdDetail* vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier];
    vc.ad = ad;
    [self.navigationController showViewController:vc sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowUserIdentifier]) {
        UserProfile *vc = segue.destinationViewController;
        vc.user = self.ad.user;
    }
}

- (IBAction)userTapped:(id)sender
{
    [self viewUserProfile:self.ad.user];
}

- (void)viewUserProfile:(User *)user
{
    [self performSegueWithIdentifier:kShowUserIdentifier sender:nil];
}

@end
