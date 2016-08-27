//
//  PreviewUser.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PreviewUser.h"
#import "IndentedLabel.h"
#import "CollectionView.h"
#import "AdCollection.h"
#import "ParallaxView.h"
#import "PreviewAd.h"

@interface PreviewUser ()
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet CollectionView *media;
@property (weak, nonatomic) IBOutlet AdCollection *posts;
@property (weak, nonatomic) IBOutlet AdCollection *likes;
@property (weak, nonatomic) IBOutlet AdCollection *views;
@property (weak, nonatomic) IBOutlet UILabel *viewedLabel;
@property (weak, nonatomic) IBOutlet UILabel *likedLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsLabel;
@end

@implementation PreviewUser

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.parallax setScrollOffset:scrollView];
}

- (void)viewDidLoad
{
    [self setNotification:kNotifyAdSelected forSuperSegue:@"PreviewAd"];    
    [self.parallax setNavigationBarProperties:self.navigationController.navigationBar];
    
    [super viewDidLoad];
    [self.user fetched:^{
        [self.user profileMediaThumbnailLoaded:^(UIImage *image) {
            self.photoView.image = image;
        }];
        self.introLabel.text = self.user.introduction;
        self.nicknameLabel.text = self.user.nickname;
        self.ageLabel.text = self.user.age;
        self.genderLabel.text = self.user.genderTypeString;
        self.genderLabel.backgroundColor = self.user.genderColor;
        
        self.viewedLabel.text = [[self.user.nickname uppercaseString] stringByAppendingString:@" VIEWED"];
        self.likedLabel.text = [[self.user.nickname uppercaseString] stringByAppendingString:@" LIKES"];
        self.postsLabel.text =[[self.user.nickname uppercaseString] stringByAppendingString:@"'S POSTS"];
    }];
    
    [UserMedia fetchAllIfNeededInBackground:self.user.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.media setIsMine:self.user.isMe];
        [self.media setButtonColor:kAppColor];
        [self.media setViewController:self];
        [self.media setItems:self.user.media];
        [self.media setCellSizeRatio:0.8f];
    }];
    
    NSLog(@"posts.%ld", self.user.posts.count);
    NSLog(@"viewed:%ld", self.user.viewed.count);
    NSLog(@"likes:%ld@", self.user.likes.count);

    [self setDefaultQueriesFor:self.views forItems:self.user.viewed usingQuery:nil cellWidth:0 cellIdentifier:@"AdCollectionCellMini"];
    [self setDefaultQueriesFor:self.likes forItems:self.user.likes usingQuery:nil cellWidth:0 cellIdentifier:@"AdCollectionCellMini"];
    [self setDefaultQueriesFor:self.posts forItems:nil usingQuery:self.myPosts cellWidth:0 cellIdentifier:@"AdCollectionCellMini"];
}

- (PFQuery*) myPosts
{
    PFQuery *query = [Ad query];
    [query whereKey:@"user" equalTo:self.user];
    return query;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    switch (row) {
        case 0:
        {
            CGRect rect = rectForString(self.user.introduction, self.introLabel.font, CGRectGetWidth(self.introLabel.bounds));
            return CGRectGetMinY(self.introLabel.frame)+CGRectGetHeight(rect)+20;
        }
            break;
        case 1:
            return 160;
        default:
            return 240;
    }
}

- (void)setDefaultQueriesFor:(AdCollection*)adCollection
                    forItems:(NSArray <Ad *> *)items
                  usingQuery:(PFQuery*)query
                   cellWidth:(CGFloat)cellWidth
              cellIdentifier:(NSString*)cellIdentifier
{
    AdCollectionQueryBlock allBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        if (items) {
            [adCollection initializeAdsWithAds:items];
        }
        else {
            [query findObjectsInBackgroundWithBlock:^(NSArray <Ad *> * _Nullable ads, NSError * _Nullable error) {
                [adCollection initializeAdsWithAds:ads];
            }];
        }
    };
    
    AdCollectionQueryBlock moreBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
    };
    
    AdCollectionQueryBlock recentBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
    };
    
    [adCollection setLoadAllBlock:allBlock];
    [adCollection setLoadMoreBlock:moreBlock];
    [adCollection setLoadRecentBlock:recentBlock];
    
    adCollection.query = query;
    adCollection.cellWidth = cellWidth;
    adCollection.cellIdentifier = cellIdentifier;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PreviewAd"]) {
        UINavigationController *nav = segue.destinationViewController;
        PreviewAd *vc = [nav.viewControllers firstObject];
        vc.ad = sender;
    }
    else if ([segue.identifier isEqualToString:@"PreviewUser"]) {
        UINavigationController *nav = segue.destinationViewController;
        PreviewUser *vc = [nav.viewControllers firstObject];
        vc.user = sender;
    }
}


- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
