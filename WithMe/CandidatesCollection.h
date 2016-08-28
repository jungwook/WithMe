//
//  CandidatesCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CandidatesCollection : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) Ad *ad;
@property (nonatomic, copy) UserBlock userSelectedBlock;
@property (nonatomic, copy) VoidBlock requestJoinBlock;
@end
