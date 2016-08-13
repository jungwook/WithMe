//
//  AdCollectionCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionObject.h"

@protocol AdCollectionCellDelegate <NSObject>
@required
- (void) viewUserProfile:(User*)user;
@end

@interface AdCollectionCell : UICollectionViewCell
@property (nonatomic, strong) Ad* ad;
@property (nonatomic, weak) id<AdCollectionCellDelegate> delegate;
@end
