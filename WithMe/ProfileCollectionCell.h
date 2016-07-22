//
//  ProfileCollectionCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCollectionCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray *items;
@property (nonatomic) BOOL editable;
@end
