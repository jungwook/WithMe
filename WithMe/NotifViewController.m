//
//  NotifViewController.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NotifViewController.h"

@interface NotifViewController ()
@end

@implementation NotifViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _notif = [Notifications new];
    }
    return self;
}

- (void)setNotification:(id)notification forSuperSegue:(id)segueIdentifier
{
    [self.notif setNotification:notification forAction:^(id actionParam){
        [super performSegueWithIdentifier:segueIdentifier sender:actionParam];
    }];
}

- (void)setNotification:(id)notification forAction:(ActionBlock)actionHandler
{
    [self.notif setNotification:notification forAction:actionHandler];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _notif = [Notifications new];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _notif = [Notifications new];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    _notif = [Notifications new];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.notif.on = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.notif.on = YES;
}

@end
