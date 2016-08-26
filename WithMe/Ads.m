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
#import "CategoryCollection.h"
#import "Notifications.h"
#import "PreviewAd.h"

#define kPinRecentQuery @"PinRecentQuery"

@interface Ads ()
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet AdCollection *visitedCollection;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet AdCollection *recentCollection;
@property (weak, nonatomic) IBOutlet AdCollection *areaCollection;
@property (weak, nonatomic) IBOutlet AdCollection *userCollection;
@property (weak, nonatomic) IBOutlet CategoryCollection *categoryCollection;
@property (weak, nonatomic) IBOutlet UIImageView *addAdImageView;

@property (strong, nonatomic) Notifications *notif;
@end

#define kQueryLimit 5

@implementation Ads

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    ActionBlock adSelectedHandler = ^(Ad *ad) {
        [self performSegueWithIdentifier:@"PreviewAd" sender:ad];
    };
    
    self.notif = [Notifications new];
    [self.notif setNotification:kNotifyCategorySelected forAction:^(id actionParams) {
        NSLog(@"CATEGORY:%@ SELECTED", actionParams);
    }];
    [self.notif setNotification:kNotifyAdSelected forAction:adSelectedHandler];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PreviewAd"]) {
        UINavigationController *nav = segue.destinationViewController;
        PreviewAd *vc = [nav.viewControllers firstObject];
        vc.ad = sender;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.parallax setScrollOffset:scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.parallax setNavigationBarProperties:self.navigationController.navigationBar];

    [self.addButton setTintColor:kAppColor forState:UIControlStateNormal];
    [self setDefaultQueriesFor:self.recentCollection usingQuery:[self recentQuery] cellWidth:330 cellIdentifier:@"AdCollectionCellV2"];
    [self setDefaultQueriesFor:self.visitedCollection usingQuery:[self visitedQuery] cellWidth:0 cellIdentifier:@"AdCollectionCellMini"];
    [self setGeoSpatialQueriesFor:self.areaCollection usingQuery:[self areaQuery] cellWidth:0 cellIdentifier:@"AdCollectionCellMini"];
    [self setDefaultQueriesFor:self.userCollection usingQuery:[self yourQuery] cellWidth:0 cellIdentifier:@"AdCollectionCellMini"];
    
    self.profileImageView.backgroundColor = kAppColor;
    self.nicknameLabel.text = [User me].nickname;
    
    [[User me] profileMediaThumbnailLoaded:^(UIImage *image) {
        self.profileImageView.image = image;
    }];
}

- (void)setDefaultQueriesFor:(AdCollection*)adCollection
                  usingQuery:(PFQuery *)query
                   cellWidth:(CGFloat)cellWidth
              cellIdentifier:(NSString*)cellIdentifier
{
    AdCollectionQueryBlock allBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:0];
        [query setLimit:kQueryLimit];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [adCollection initializeAdsWithAds:[self newItems:ads with:objects]];
        }];
    };
    
    AdCollectionQueryBlock moreBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:ads.count];
        [query setLimit:kQueryLimit];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count >0) {
                [adCollection loadMoreAdsWithAds:[self newItems:ads with:objects]];
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
                    [adCollection loadRecentAdsWithAds:[self newItems:ads with:objects]];
                }];
            }
        }];
    };
    
    [adCollection setLoadAllBlock:allBlock];
    [adCollection setLoadMoreBlock:moreBlock];
    [adCollection setLoadRecentBlock:recentBlock];
    
    adCollection.query = query;
    adCollection.cellWidth = cellWidth;
    adCollection.cellIdentifier = cellIdentifier;
}

- (void)setGeoSpatialQueriesFor:(AdCollection*)adCollection
                     usingQuery:(PFQuery *)query
                      cellWidth:(CGFloat)cellWidth
                 cellIdentifier:(NSString*)cellIdentifier
{
    AdCollectionQueryBlock allBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
        [query cancel];
        [query setSkip:0];
//        [query setLimit:kQueryLimit];
        [query setLimit:1000];
        [query whereKey:@"objectId" notContainedIn:[self objectIdsFromAds:ads]];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [adCollection initializeAdsWithAds:[self ads:[self newItems:ads with:objects] orderedByDistanceFrom:[User me].location]];
        }];
    };
    
//    AdCollectionQueryBlock moreBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
//        [query cancel];
//        [query setSkip:ads.count];
//        [query setLimit:kQueryLimit];
//        [query whereKey:@"objectId" notContainedIn:[self objectIdsFromAds:ads]];
//        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//            [adCollection loadMoreAdsWithAds:[self ads:[self newItems:ads with:objects] orderedByDistanceFrom:[User me].location]];
//        }];
//    };
//    
//    AdCollectionQueryBlock recentBlock = ^void(PFQuery *query, NSArray <Ad*> *ads) {
//        [query cancel];
//        [query setSkip:0];
//        [query whereKey:@"objectId" notContainedIn:[self objectIdsFromAds:ads]];
//        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
//            if (number) {
//                [query setLimit:number];
//                [query findObjectsInBackgroundWithBlock:^(NSArray <Ad *> * _Nullable objects, NSError * _Nullable error) {
//                    [adCollection loadRecentAdsWithAds:[self ads:[self newItems:ads with:objects] orderedByDistanceFrom:[User me].location]];
//                }];
//            }
//        }];
//    };
    
    [adCollection setLoadAllBlock:allBlock];
//    [adCollection setLoadMoreBlock:moreBlock];
//    [adCollection setLoadRecentBlock:recentBlock];

    adCollection.query = query;
    adCollection.cellWidth = cellWidth;
    adCollection.cellIdentifier = cellIdentifier;
}

- (NSArray *) objectIdsFromAds:(NSArray <Ad*>*)ads
{
    NSMutableArray *ids = [NSMutableArray array];
    [ads enumerateObjectsUsingBlock:^(Ad * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:obj.objectId];
    }];
    return ids;
}

- (NSArray *) ads:(NSArray*)ads orderedByDistanceFrom:(PFGeoPoint*)here
{
    return [ads sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PFGeoPoint *p1 = ((User*)obj1).location;
        PFGeoPoint *p2 = ((User*)obj2).location;
        
        CGFloat distanceA = [here distanceInKilometersTo:p1];
        CGFloat distanceB = [here distanceInKilometersTo:p2];
        
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (NSArray *) newItems:(NSArray <Ad*> *)ads with:(NSArray <Ad*> *)newItems
{
    NSMutableArray *newSet = [NSMutableArray array];
    [newItems enumerateObjectsUsingBlock:^(Ad * _Nonnull newAd, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self ad:newAd notInsideAds:ads]) {
            [newSet addObject:newAd];
        }
    }];
    return newSet;
}


- (BOOL) ad:(Ad*)ad notInsideAds:(NSArray <Ad*>*)ads
{
    NSArray *set = [ads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId = %@", ad.objectId]];
    return (set.count == 0);
}


- (IBAction)addOneMoreAd:(id)sender
{
    //    [Ad randomlyCreateOneAd];
    [self.addAdImageView.layer addAnimation:buttonPressedAnimation() forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"PostNewAd" sender:sender];
    });
}

- (PFQuery *) yourQuery
{
    PFQuery *query = [Ad query];
    [query whereKey:@"user" equalTo:[User me]];
    [query orderByDescending:@"createdAt"];
    
    return query;
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

@end
