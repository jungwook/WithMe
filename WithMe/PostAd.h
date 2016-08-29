//
//  PostAd.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalTableViewController.h"

@interface PostAd : ModalTableViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) Ad* ad;
@end
