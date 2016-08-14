//
//  AdsCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdCollectionCell.h"

@protocol AdsCollectionDelegate <NSObject>

- (void) viewAdDetail:(Ad*)ad;

@end

@interface AdsCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, weak) id <AdsCollectionDelegate> adDelegate;
@end
