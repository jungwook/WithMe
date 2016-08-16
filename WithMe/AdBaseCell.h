//
//  AdBaseCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 16..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdDelegateProtocol.h"
@interface AdBaseCell : UICollectionViewCell
@property (nonatomic, weak) Ad* ad;
@property (nonatomic, weak) id <AdDelegate> delegate;
@end
