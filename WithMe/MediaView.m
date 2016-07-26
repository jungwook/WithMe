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

@interface CircularGradientView : UIView

@end

@implementation CircularGradientView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Create gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 0.3, 1.0};
    
    UIColor *centerColor = [UIColor clearColor];
    UIColor *edgeColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    
    NSArray *colors = [NSArray arrayWithObjects:
                       (__bridge id)centerColor.CGColor,
                       (__bridge id)centerColor.CGColor,
                       (__bridge id)edgeColor.CGColor,
                       nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGPoint center = self.center;
    CGFloat radius = sqrt(self.bounds.size.width*self.bounds.size.width + self.bounds.size.height*self.bounds.size.height);
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, radius, kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

@interface MediaView()
@property (strong, nonatomic)   UIView* base;
@property (strong, nonatomic)   UIImageView *photo;
@property (strong, nonatomic)   CircularGradientView *gradient;
@property (strong, nonatomic)   UIButton *editButton;
@property (strong, nonatomic)   UIActivityIndicatorView *indicator;
@property (strong, nonatomic)   UILabel *profileMediaLabel;

@property (nonatomic, copy)     MediaViewEditBlock editBlock;
@property (nonatomic, strong)   User *user;
@property (nonatomic, strong)   UserMedia *media;
@property (nonatomic, readonly) MediaType mediaType;
@property (nonatomic, weak)     UIImage *image;
@property (nonatomic)           BOOL isProfileMedia;
@property (nonatomic)           BOOL editable;
@property (nonatomic, readonly) BOOL isReal;
@end

@implementation MediaView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.base = [UIView new];
    self.base.clipsToBounds = YES;
    addSubviewAndSetContrainstsOnView(self.base, self, UIEdgeInsetsZero);
    
    self.photo = [UIImageView new];
    self.photo.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    [self.photo setContentMode:UIViewContentModeScaleAspectFill];
    addSubviewAndSetContrainstsOnView(self.photo, self.base, UIEdgeInsetsMake(-4, -4, -4, -4));
    
    self.profileMediaLabel = [UILabel new];
    self.profileMediaLabel.text = @"Main";
    self.profileMediaLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    
    
    
    self.gradient = [CircularGradientView new];
    self.gradient.hidden = YES;
    addSubviewAndSetContrainstsOnView(self.gradient, self.base, UIEdgeInsetsMake(-4, -4, -4, -4));
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.editButton setTitle:@"EDIT" forState:UIControlStateNormal];
    [self.editButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2]];
    [self.editButton.titleLabel setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightSemibold]];
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

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.editButton.hidden = !editable;
}

- (void)makeCircle:(BOOL)makeCircle
{
    [self.base makeCircle:makeCircle];
}

- (void) setShadowOnView:(UIView*)view
{
    __LF
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.radius];
    view.backgroundColor = [UIColor clearColor];
    view.layer.shadowPath = shadowPath.CGPath;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOpacity = 0.8f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void) setIsProfileMedia:(BOOL)isProfileMedia
{
    _isProfileMedia = isProfileMedia;
    if (isProfileMedia && self.editable == NO) {
        self.base.layer.borderWidth = MAX(MIN(self.base.radius / 10, 10), 8);
        self.base.layer.borderColor = [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1.0f].CGColor;
    }
}

- (void) setEditableAndUserProfileMediaHandler:(MediaViewEditBlock)block
{
    _editable = YES;
    self.editButton.hidden = NO;
    self.editBlock = block;
}

- (void)editUserMedia:(UIButton*)sender
{
    __LF
    if (self.user) {
        [self startIndicating];
        [MediaPicker pickMediaOnViewController:nil withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
            if (picked) {
                [S3File getDataFromFile:userMedia.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        [self setImage:image];
                    }
                }];
                if (self.user.profileMedia) {
                    [self.user removeObjectsInArray:@[self.user.profileMedia] forKey:@"media"];
                }
                [self.user saved:^{
                    [self.user setProfileMedia:userMedia];
                    if (self.editBlock) {
                        self.editBlock(userMedia);
                    }
                    [self stopIndicating];
                }];
            }
        }];
    }
}

- (void)setImage:(UIImage *)image
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gradient.alpha = 0;
        [self.photo setImage:image];
        if (self.editable) {
            self.photo.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                self.photo.alpha = 1.0f;
                self.gradient.alpha = (image != nil);
            }];
        }
        self.gradient.alpha = (image != nil);
    });
}

- (UIImage *)image
{
    return self.photo.image;
}

- (void) setUser:(User *)user
{
    _user = user;
    
    if (!self.user) {
        _isReal = NO;
        self.isProfileMedia = NO;
        self.image = nil;
        return;
    }
    
    [self.user fetched:^{
        [self loadMediaFromUserMedia:[self.user profileMedia]];
    }];
}

- (void) loadMediaFromUser:(User *)user
{
    self.user = user;
}

- (void)loadMediaFromUserMedia:(UserMedia *)media
{
    _media = media;
    
    if (!self.media) {
        _isReal = NO;
        self.isProfileMedia = NO;
        self.image = nil;
        return;
    }
    
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
            
            self.isProfileMedia = media.isProfileMedia;
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

- (void) saveRawMediaExample
{
    
    
    [MediaPicker pickMediaOnViewController:nil withMediaHandler:^(MediaType mediaType,
                                                                  NSData *thumbnailData,
                                                                  NSData *originalData,
                                                                  NSData *movieData,
                                                                  BOOL isReal,
                                                                  BOOL picked)
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

@end
