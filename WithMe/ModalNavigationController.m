//
//  ModalNavigationController.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ModalNavigationController.h"
#import "ModalAnimator.h"

@interface ModalNavigationController ()

@end

@implementation ModalNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.transitioningDelegate = self;
}

- (CGFloat)offsetHeight
{
    return kOffsetFromTop;
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
