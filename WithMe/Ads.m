//
//  Ads.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Ads.h"
#import "AdCollection.h"
#import "ParallaxView.h"

#define kPinRecentQuery @"PinRecentQuery"

@interface Ads ()
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet AdCollection *visitedCollection;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet AdCollection *recentCollection;
@property (weak, nonatomic) IBOutlet AdCollection *areaCollection;
@end

#define kQueryLimit 5

@implementation Ads

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.addButton setTintColor:kAppColor forState:UIControlStateNormal];
    
    [self setDefaultQueriesFor:self.recentCollection usingQuery:[self recentQuery]];
    [self setDefaultQueriesFor:self.visitedCollection usingQuery:[self visitedQuery]];
    [self setGeoSpatialQueriesFor:self.areaCollection usingQuery:[self areaQuery]];
    
    self.profileImageView.backgroundColor = kAppColor;
    self.nicknameLabel.text = [User me].nickname;
    
    [[User me] profileMediaThumbnailLoaded:^(UIImage *image) {
        self.profileImageView.image = image;
    }];
}

- (void)setDefaultQueriesFor:(AdCollection*) adCollection usingQuery:(PFQuery *)query
{
    AdCollectionQueryBlock allBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:0];
        [query setLimit:kQueryLimit];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [adCollection initializeAdsWithAds:objects];
        }];
    };
    
    AdCollectionQueryBlock moreBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:ads.count];
        [query setLimit:kQueryLimit];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count >0) {
                [adCollection loadMoreAdsWithAds:objects];
            }
        }];
    };

    AdCollectionQueryBlock recentBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        NSDate *firstCreatedAt = ads.firstObject.createdAt;
        [query cancel];
        [query setSkip:0];
        [query whereKey:@"createdAt" greaterThan:firstCreatedAt];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            if (number) {
                NSLog(@"FOUND:%d MORE ADS", number);
                [query setLimit:number];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    [adCollection loadRecentAdsWithAds:objects];
                }];
            }
        }];
    };
    
    [adCollection setLoadAllBlock:allBlock];
    [adCollection setLoadMoreBlock:moreBlock];
    [adCollection setLoadRecentBlock:recentBlock];
    
    adCollection.query = query;
}

- (void)setGeoSpatialQueriesFor:(AdCollection*) adCollection usingQuery:(PFQuery *)query
{
    AdCollectionQueryBlock allBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:0];
        [query setLimit:kQueryLimit];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [adCollection initializeAdsWithAds:objects];
        }];
    };
    
    AdCollectionQueryBlock moreBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:ads.count];
        [query setLimit:kQueryLimit];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count >0) {
                [adCollection loadMoreAdsWithAds:objects];
            }
        }];
    };
    
    AdCollectionQueryBlock recentBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:0];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            if (number) {
                NSLog(@"FOUND:%d MORE ADS", number);
                [query setLimit:number];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    [adCollection loadRecentAdsWithAds:objects];
                }];
            }
        }];
    };
    
    [adCollection setLoadAllBlock:allBlock];
    [adCollection setLoadMoreBlock:moreBlock];
    [adCollection setLoadRecentBlock:recentBlock];

    adCollection.query = query;
}


- (IBAction)addOneMoreAd:(id)sender
{
    [Ad randomlyCreateOneAd];
}

- (PFQuery *) visitedQuery
{
    PFQuery *query = [Ad query];
    [query fromPinWithName:kPinRecentQuery];
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (PFQuery *) recentQuery
{
    PFQuery *query = [Ad query];
    [query orderByDescending:@"createdAt"];
    
    return query;
}


- (PFQuery *) areaQuery
{
    PFQuery *query = [Ad query];
    [query whereKey:@"location" nearGeoPoint:[User me].location];
    
    return query;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.parallax.scrollOffset = scrollView.contentOffset.y;
}

@end
