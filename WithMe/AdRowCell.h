//
//  AdRowCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 16..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdBaseCell.h"

@interface AdRowCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AdDelegate>
@property (weak, nonatomic) id <AdDelegate> adDelegate;
- (void)setParams:(id)params forRow:(NSInteger)row;
@end
