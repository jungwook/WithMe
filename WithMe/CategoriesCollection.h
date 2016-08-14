//
//  CategoriesCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdCategoryCell.h"

@protocol CategoriesCollectionDelegate <NSObject>

- (void) viewCategory:(Category*)category;

@end

@interface CategoriesCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, weak) id <CategoriesCollectionDelegate> categoryDelegate;
@end
