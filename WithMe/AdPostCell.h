//
//  AdPostCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAds.h"

#define kTitleFont [UIFont systemFontOfSize:14 weight:UIFontWeightBlack]
#define kEndCategoryFont [UIFont systemFontOfSize:10 weight:UIFontWeightBold]
#define kCategoryFont [UIFont systemFontOfSize:12 weight:UIFontWeightBold]
#define kIntroFont [UIFont systemFontOfSize:12 weight:UIFontWeightMedium]

@interface AdPostCell : UICollectionViewCell
@property (nonatomic, weak) Ad* ad;
@property (nonatomic, strong) UserAds* parent;
@end
