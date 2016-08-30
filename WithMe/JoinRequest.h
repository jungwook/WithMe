//
//  JoinRequest.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ModalViewController.h"
typedef void (^AdJoinBlock)(AdJoin* adjoin);

@interface JoinRequest : ModalViewController <UITextFieldDelegate>
@property (nonatomic, strong) Ad *ad;
@property (nonatomic, copy) AdJoinBlock adJoinRequestBlock;
@end
