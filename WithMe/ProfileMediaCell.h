//
//  ProfileMediaCell.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileCollectionCell.h"

@interface ProfileMediaCell : UICollectionViewCell
@property (nonatomic, weak) UserMedia *media;
@property (nonatomic, weak) ProfileCollectionCell *parent;
@end
