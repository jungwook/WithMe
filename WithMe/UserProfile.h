//
//  UserProfile.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ProfileChangedBlock)(BOOL profileChanged);

@interface UserProfile : UITableViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) ProfileChangedBlock profileChangedBlock;
@end
