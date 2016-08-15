//
//  AdsCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdCollectionCell.h"

@interface AdsCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) id <AdsCollectionDelegate> adDelegate;
- (void) setQuery:(PFQuery *)query named:(NSString*)name index:(NSInteger)index;
@end
