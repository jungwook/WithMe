//
//  MediaCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaCollection : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) User *user;
@end
