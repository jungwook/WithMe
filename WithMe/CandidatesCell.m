//
//  CandidatesCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 28..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CandidatesCell.h"
#import "IndentedLabel.h"

@interface CandidatesCell()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *leaveButton;
@end

@implementation CandidatesCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.leaveButton.hidden = YES;
}

- (IBAction)unjoin:(id)sender
{
    NOTIFY(kNotifyUnjoinedAd, self.adjoin);
}

- (void)setAdjoin:(AdJoin *)adjoin
{
    _adjoin = adjoin;
    [self.adjoin fetched:^{
        NSLog(@"THIS JOIN REQUEST %@", self.adjoin.isMine ? @"IS MINE" : @"IS NOT MINE");
        self.leaveButton.hidden = !(self.adjoin.isMine);
        [self.adjoin loadFirstMediaThumbnailImage:^(UIImage *image) {
            self.photoView.image = image;
        }];
    }];
}
@end
