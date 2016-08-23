//
//  AdCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AdCollectionQueryBlock)(PFQuery *query, NSArray <Ad *>* ads);

@interface AdCollection : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) CGFloat widthRatioToHeight;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic, copy) AdCollectionQueryBlock loadAllBlock;
@property (nonatomic, copy) AdCollectionQueryBlock loadMoreBlock;
@property (nonatomic, copy) AdCollectionQueryBlock loadRecentBlock;
@property (nonatomic, strong) NSString *cellIdentifier;

- (void) initializeAdsWithAds:(NSArray <Ad *> *) ads;
- (void) loadMoreAdsWithAds:(NSArray <Ad *> *) ads;
- (void) loadRecentAdsWithAds:(NSArray <Ad *> *) ads;

@end
