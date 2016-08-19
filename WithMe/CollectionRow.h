//
//  CollectionRow.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ItemBlock)(id item);

@interface CollectionRow : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic) UIEdgeInsets sectionInsets;
@property (nonatomic) CGFloat cellSizeRatio;
@property (nonatomic, copy) ItemBlock selectionBlock;
@end
