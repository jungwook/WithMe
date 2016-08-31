//
//  EditUserDetail.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "EditUserDetail.h"
#import "ShadowView.h"

@interface EditUserDetail ()
@property (weak, nonatomic) IBOutlet ShadowView *shadowView;
@end

@implementation EditUserDetail


- (void)awakeFromNib
{
    UIView *view = [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:NO];
    [self.view insertSubview:view atIndex:0];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shadowView.layer.transform = CATransform3DMakeScale(1.4, 1.4, 1);
    [UIView animateWithDuration:1.0 animations:^{
        self.shadowView.layer.transform = CATransform3DIdentity;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
