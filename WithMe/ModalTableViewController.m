//
//  ModalTableViewController.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ModalTableViewController.h"
#import "ModalAnimator.h"

@interface ModalTableViewController ()

@end

@implementation ModalTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.transitioningDelegate = self;

}

- (CGFloat)offsetHeight
{
    return 35;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [ModalAnimator modalAnimatorPresenting:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [ModalAnimator modalAnimatorPresenting:NO];
}

@end
