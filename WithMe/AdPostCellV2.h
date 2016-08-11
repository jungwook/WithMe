//
//  AdPostCellV2.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdPostCellV2 : UICollectionViewCell
@property (strong, nonatomic) Ad *ad;
@property (weak, nonatomic) UICollectionView *collectionView;
@end
