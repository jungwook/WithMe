//
//  AdCollectionCellBase.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 28..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdCollectionCellBase : UICollectionViewCell
@property (copy, nonatomic) UserBlock userSelectedBlock;
@property (weak, nonatomic) Ad* ad;
@end
