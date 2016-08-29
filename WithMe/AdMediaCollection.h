//
//  AdMediaCollection.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdMediaCollection : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak)   Ad        *ad;
@property (nonatomic, weak)   UIViewController* parentController;
@property (nonatomic, strong) UIColor   *tintColor;
@property (nonatomic, strong) NSMutableArray <UserMedia *> *media;
@property (nonatomic)         BOOL editable;
- (void) refresh;
@end
