//
//  CollectionRow.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ItemBlock)(id item);
typedef void(^DeleteItemBlock)(id item);
typedef void(^AddItemBlock)(void);

#define kCollectionRowColor [UIColor colorWithRed:240/255.f green:82/255.f blue:44/255.f alpha:1]

@interface CollectionRow : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic)           UIEdgeInsets sectionInsets;
@property (nonatomic)           CGFloat cellSizeRatio;
@property (nonatomic, strong)   UIColor *buttonColor;
@property (nonatomic, strong)   UIColor *buttonTitleColor;
@property (nonatomic, copy)     ItemBlock selectionBlock;
@property (nonatomic, copy)     DeleteItemBlock deletionBlock;
@property (nonatomic, copy)     AddItemBlock addItemBlock;

- (void)setItems:(NSArray *)items;
@end
