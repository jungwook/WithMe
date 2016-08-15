//
//  AdCollectionCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdsCollectionDelegate <NSObject>
@optional
- (void) viewUserProfile:(User*)user;
- (void) viewAdDetail:(Ad*)ad;
- (void) adsCollectionLoaded:(NSInteger)index additional:(BOOL)additionalLoaded;
@end

@interface AdCollectionCell : UICollectionViewCell
@property (nonatomic, strong) Ad* ad;
@property (nonatomic, weak) id<AdsCollectionDelegate> delegate;
@end
