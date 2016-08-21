//
//  CollectionView.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ItemBlock)(id item);

#define kCollectionRowColor [UIColor colorWithRed:240/255.f green:82/255.f blue:44/255.f alpha:0.8]


@interface CollectionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic)           UIEdgeInsets sectionInsets;
@property (nonatomic)           CGFloat cellSizeRatio;
@property (nonatomic, copy)     ItemBlock selectionBlock;
@property (nonatomic, copy)     ItemBlock deletionBlock;
@property (nonatomic, copy)     VoidBlock additionBlock;
@property (nonatomic, strong)   UIColor *buttonColor;
@property (nonatomic, weak)     UIViewController *viewController;
- (void)addAddMoreButtonTitled:(NSString*) title;
- (void)setItems:(NSArray *)items;
- (void)refresh;
@end
