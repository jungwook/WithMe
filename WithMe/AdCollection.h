//
//  AdCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AdCollectionQueryBlock)(PFQuery *query, NSArray <Ad *>* ads, NSString *pinName);

@interface AdCollection : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)   PFQuery *query;
@property (nonatomic, strong)   NSString *emptyTitle;
@property (nonatomic) CGFloat   widthRatioToHeight;
@property (nonatomic) CGFloat   cellWidth;
@property (nonatomic, copy)     AdBlock adSelectedBlock;
@property (nonatomic, copy)     UserBlock userSelectedBlock;
@property (nonatomic, strong)   NSString *cellIdentifier;
@property (nonatomic)           BOOL isGeoSpatial;
@end
