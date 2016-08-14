//
//  AdCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionObject.h"
#import "AdCollectionCell.h"
#import "AdCategoryCell.h"

@protocol AdCollectionDelegate <NSObject>
@optional
- (void) loadMoreForSection:(SectionObject*)section;
- (void) categorySelected:(Category*)category;
- (void) adSelected:(Ad*)ad;
- (void) viewUserProfile:(User*)user;
@end

@interface AdCollection : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AdCollectionCellDelegate>
@property (nonatomic, strong) SectionObject *section;
@property (nonatomic, weak) id<AdCollectionDelegate> delegate;

- (void) moreItemsAdded:(NSArray*)arrayOfIndexPathOfAddedItems;
@end
