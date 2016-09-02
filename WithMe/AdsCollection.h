//
//  AdsCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdsCellBase.h"

@interface AdsCollection : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (void) setQuery:(PFQuery*)query andCellIdentifier:(id)cellIdentifier;
@end
