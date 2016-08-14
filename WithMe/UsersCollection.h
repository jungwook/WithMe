//
//  UsersCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UsersCollectionDelegate <NSObject>
@required
- (void) viewUserProfile:(User*)user;
@end

@interface UsersCollection : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray <User*> *users;
@property (nonatomic, weak) id <UsersCollectionDelegate> showUserDelegate;
@end
