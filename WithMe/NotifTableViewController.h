//
//  NotifTableViewController.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifTableViewController : UITableViewController
@property (nonatomic) BOOL notificationOn;
- (void)setNotification:(id)notification forSuperSegue:(id)segueIdentifier;
- (void)setNotification:(id)notification forAction:(ActionBlock) actionHandler;
@end
