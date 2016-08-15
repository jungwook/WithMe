//
//  UserAdsV2.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdButton.h"
#import "AdsCategoryRow.h"
#import "AdsCollectionRow.h"

typedef enum : NSUInteger {
    kSectionRecent = 0,
    kSectionByUser,
    kSectionNewAds,
    kSectionPostNewAd,
    kSectionArea,
    kSectionCategory,
    kSectionTrending,
    kSectionInvite
} AdCollectionSections;

@interface UserAdsV2 : UITableViewController <AdButtonDelegate, CategoriesCollectionDelegate, AdsCollectionDelegate>

@end
