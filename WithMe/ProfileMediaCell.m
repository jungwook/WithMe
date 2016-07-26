//
//  ProfileMediaCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ProfileMediaCell.h"
#import "MediaView.h"

@interface ProfileMediaCell()
@property (weak, nonatomic) IBOutlet MediaView *photo;

@end

@implementation ProfileMediaCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setMedia:(UserMedia *)media
{
    _media = media;
    [self.photo loadMediaFromUserMedia:media];
}

- (IBAction)deleteUserMedia:(UIButton *)sender
{
    if ([self.parent respondsToSelector:@selector(deleteUserMedia:)]) {
        [self.parent performSelector:@selector(deleteUserMedia:) withObject:self.media];
    }
}

@end
