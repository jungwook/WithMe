//
//  MediaView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaView.h"
#import "AppDelegate.h"
#import "MediaPicker.h"

@interface MediaView()
@property (strong, nonatomic) UIView* base;
@property (strong, nonatomic) UIImageView *photo;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@end

@implementation MediaView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.base = [UIView new];
    self.base.clipsToBounds = YES;
    self.base.radius = 5.0f;
    addSubviewAndSetContrainstsOnView(self.base, self, UIEdgeInsetsZero);
    
    self.photo = [UIImageView new];
    self.photo.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    [self.photo setContentMode:UIViewContentModeScaleAspectFill];
    
    addSubviewAndSetContrainstsOnView(self.photo, self.base, UIEdgeInsetsMake(-4, -4, -4, -4));
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.editButton setTitle:@"EDIT" forState:UIControlStateNormal];
    [self.editButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2]];
    [self.editButton.titleLabel setFont:[UIFont systemFontOfSize:10 weight:UIFontWeightSemibold]];
    [self.editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editUserMedia:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.base addSubview:self.editButton];
    [[self.editButton.bottomAnchor constraintEqualToAnchor:self.base.bottomAnchor] setActive: YES];
    [[self.editButton.leadingAnchor constraintEqualToAnchor:self.base.leadingAnchor] setActive: YES];
    [[self.editButton.trailingAnchor constraintEqualToAnchor:self.base.trailingAnchor] setActive: YES];
    [[self.editButton.heightAnchor constraintEqualToAnchor:self.base.heightAnchor multiplier:0.25 constant:0] setActive:YES];
    
    self.editable = NO;
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicator.hidden = NO;
    self.indicator.alpha = 0;
    addSubviewAndSetContrainstsOnView(self.indicator, self.base, UIEdgeInsetsZero);
    [self.indicator startAnimating];
}

- (void) setShadowOnView:(UIView*)view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.radius];
    view.backgroundColor = [UIColor clearColor];
    view.layer.shadowPath = shadowPath.CGPath;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOpacity = 0.4f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self.base makeCircle:YES];
//    self.radius = self.base.radius;
//    self.indicator.frame = self.bounds;
//    const CGFloat f = 0.6f;
//    self.editButton.frame = CGRectMake(0, self.bounds.size.height*f, self.bounds.size.width, self.bounds.size.height*(1-f));
//    [self setShadowOnView:self];
}


- (void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.editButton.hidden = !editable;
}

- (void)editUserMedia:(UIButton*)sender
{
    __LF
    [MediaPicker pickMediaOnViewController:nil withMediaHandler:^(MediaType mediaType,
                                                                  NSData *thumbnailData,
                                                                  NSData *originalData,
                                                                  NSData *movieData,
                                                                  BOOL isReal)
    {
        [self startIndicating];
        
        switch (mediaType) {
            case kMediaTypePhoto: {
                UIImage *image = [UIImage imageWithData:originalData];
                self.image = image;
                
                [S3File saveImageData:thumbnailData completedBlock:^(NSString *thumbnailFile, BOOL succeeded, NSError *error)
                 {
                     if (succeeded && !error) {
                         [S3File saveImageData:originalData completedBlock:^(NSString *mediaFile, BOOL succeeded, NSError *error) {
                             if (succeeded && !error) {
                                 UserMedia *media = [UserMedia object];
                                 media.mediaSize = image.size;
                                 media.mediaFile = mediaFile;
                                 media.thumbailFile = thumbnailFile;
                                 media.mediaType = kMediaTypePhoto;
                                 media.isRealMedia = isReal;
                                 if (self.editBlock) {
                                     self.editBlock(media);
                                 }
                                 [self stopIndicating];
                             }
                             else {
                                 NSLog(@"ERROR:%@", error.localizedDescription);
                             }
                         }];
                     }
                     else {
                         NSLog(@"ERROR:%@", error.localizedDescription);
                     }
                 } progressBlock:nil];
            }
                break;
            case kMediaTypeVideo: {
                UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
                self.image = thumbnailImage;

                [S3File saveImageData:thumbnailData completedBlock:^(NSString *thumbnailFile, BOOL succeeded, NSError *error)
                {
                    if (succeeded && !error) {
                        [S3File saveMovieData:movieData completedBlock:^(NSString *mediaFile, BOOL succeeded, NSError *error) {
                            if (succeeded && !error) {
                                UserMedia *media = [UserMedia object];
                                media.mediaSize = thumbnailImage.size;
                                media.mediaFile = mediaFile;
                                media.thumbailFile = thumbnailFile;
                                media.mediaType = kMediaTypeVideo;
                                media.isRealMedia = isReal;
                                if (self.editBlock) {
                                    self.editBlock(media);
                                }
                                [self stopIndicating];
                            }
                            else {
                                NSLog(@"ERROR:%@", error.localizedDescription);
                            }
                        }];
                    }
                    else {
                        NSLog(@"ERROR:%@", error.localizedDescription);
                    }
                } progressBlock:nil];
            }
        }
    }];
}

- (void)setImage:(UIImage *)image
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photo setImage:image];
    });
}

- (UIImage *)image
{
    return self.photo.image;
}

- (void)setUser:(User *)user
{
    _user = user;
    [self loadMediaFromUser:self.user];
}

- (void)loadMediaFromUser:(User *)user
{
    _user = user;
    
    UserMedia *media = [self.user.media firstObject];
    [self loadMediaFromUserMedia:media];
}

- (void)loadMediaFromUserMedia:(UserMedia *)media
{
    __LF
    _media = media;
    
    [self startIndicating];
    
    if (!media) {
        [self stopIndicating];
    }
    else {
        [self.media fetched:^{
            [self stopIndicating];
            [S3File getDataFromFile:self.media.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                UIImage *image = [UIImage imageWithData:data];
                self.image = image;
            }];
        }];
    }
}

- (void) startIndicating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicator.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.indicator.alpha = 1.0f;
        }];
    });
}

- (void) stopIndicating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicator.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.indicator.alpha = 0.0f;
        }];
    });
}

@end
