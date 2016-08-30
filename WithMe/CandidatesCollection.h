//
//  CandidatesCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CandidatesCollection : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) Ad *ad;
@property (nonatomic, copy) IdBlock userIdSelectedBlock;
@property (nonatomic, copy) VoidBlock requestJoinBlock;
@property (nonatomic, copy) AdJoinBlock requestUnjoinBlock;
- (void) addJoin:(AdJoin*)adjoin;
@end
