//
//  AdCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionObject.h"

@protocol AdCollectionDelegate <NSObject>
@required
- (void) loadMoreForSection:(SectionObject*)section;
- (void) categorySelected:(Category*)category;
- (void) adSelected:(Ad*)ad;
@end

@interface AdCollection : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) SectionObject *section;
@property (nonatomic, weak) id<AdCollectionDelegate> delegate;

- (void) moreItemsAdded:(NSArray*)arrayOfIndexPathOfAddedItems;
@end
