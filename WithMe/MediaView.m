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

#define kParallexFactorInPts 30

@interface CircularGradientView : UIView

@end

@implementation CircularGradientView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Create gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 0.1, 1.0};
    
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
@property (strong, nonatomic)   CAShapeLayer *profileMediaBorderLayer;
@property (strong, nonatomic)   CAEmitterLayer *emitterLayer;

@property (strong, nonatomic)   CADisplayLink *displayLink;

@property (nonatomic, copy)     MediaViewEditBlock editBlock;
@property (nonatomic, strong)   User *user;
@property (nonatomic, strong)   UserMedia *media;
@property (nonatomic, readonly) MediaType mediaType;
@property (nonatomic, weak)     UIImage *image;
@property (nonatomic)           BOOL isProfileMedia;
@property (nonatomic)           BOOL editable;
@property (nonatomic, readonly) BOOL isReal;
@property (nonatomic)           CGFloat oldY;
@end

@implementation MediaView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplayLink)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.base = [UIView new];
    self.base.clipsToBounds = YES;
    addSubviewAndSetContrainstsOnView(self.base, self, UIEdgeInsetsZero);
    
    self.photo = [UIImageView new];
    self.photo.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    [self.photo setContentMode:UIViewContentModeScaleAspectFill];
    addSubviewAndSetContrainstsOnView(self.photo, self.base, UIEdgeInsetsMake(-kParallexFactorInPts, -4, -kParallexFactorInPts, -4));
    
    self.gradient = [CircularGradientView new];
    self.gradient.alpha = 0.0f;
    addSubviewAndSetContrainstsOnView(self.gradient, self.base, UIEdgeInsetsMake(-4, -4, -4, -4));
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.editButton setTitle:@"EDIT MAIN" forState:UIControlStateNormal];
    [self.editButton setTitleShadowColor:colorWhite forState:UIControlStateNormal];
    [self.editButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4]];
    [self.editButton.titleLabel setFont:appFont(20)];
    [self.editButton setTitleColor:colorBlue forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editUserMedia:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.editButton];
    
    [[self.editButton.bottomAnchor constraintEqualToAnchor:self.base.bottomAnchor constant:-5] setActive: YES];
    [[self.editButton.leadingAnchor constraintEqualToAnchor:self.base.leadingAnchor] setActive: YES];
    [[self.editButton.trailingAnchor constraintEqualToAnchor:self.base.trailingAnchor] setActive: YES];
    [[self.editButton.heightAnchor constraintEqualToAnchor:self.base.heightAnchor multiplier:0.25 constant:0] setActive:YES];
    
    self.editable = NO;
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicator.hidden = NO;
    self.indicator.alpha = 0;
    addSubviewAndSetContrainstsOnView(self.indicator, self.base, UIEdgeInsetsZero);
    [self.indicator startAnimating];
    
    self.profileMediaBorderLayer = [CAShapeLayer layer];
    self.profileMediaBorderLayer.strokeColor = colorBlue.CGColor;
    self.profileMediaBorderLayer.lineWidth = 10;
    self.profileMediaBorderLayer.fillColor = [UIColor clearColor].CGColor;
    self.profileMediaBorderLayer.hidden = YES;
    
    [self.layer addSublayer:self.profileMediaBorderLayer];
}

- (void) updateDisplayLink
{
    static int count = 0;
    CGRect rect = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
    CGFloat y = CGRectGetMidY(rect);
    CGFloat mid = CGRectGetMidY([UIApplication sharedApplication].keyWindow.bounds);
    
    if (y!= self.oldY && (++count % 10)) {
        self.oldY = y;
        
        CGFloat ref = MIN(MAX((y - mid) / mid, -1.f), 1.f); // BOUND ref from -1 to 1 where center screen is 0
        CGFloat f = ref*kParallexFactorInPts;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.photo.layer.transform = CATransform3DMakeTranslation(0, f, 0);
        });
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.profileMediaBorderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.radius].CGPath;
}

- (CAAnimation*) setupAnimationsOnProfileMedia
{
    CAMediaTimingFunction *timeFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CABasicAnimation *pa1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pa1.duration = 0.2;
    pa1.fromValue = @1;
    pa1.toValue = @1.01;
    pa1.timingFunction = timeFunction;
    pa1.autoreverses = YES;
    pa1.repeatCount = 1;
    
    CABasicAnimation *pa2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pa2.beginTime = 0.3;
    pa2.duration = 0.1;
    pa2.toValue = @1.03;
    pa2.timingFunction = timeFunction;
    pa2.autoreverses = YES;
    pa2.repeatCount = 1;
    
    CAAnimationGroup* groupAnimation = [CAAnimationGroup new];
    groupAnimation.animations = @[pa1, pa2];
    groupAnimation.duration = 1.1+(arc4random()%10)/10.f;
    groupAnimation.repeatCount = INFINITY;
    
    return groupAnimation;
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

- (void) setIsProfileMedia:(BOOL)isProfileMedia
{
    self.profileMediaBorderLayer.hidden = !isProfileMedia;
    if (isProfileMedia) {
        [self.base.layer addAnimation:[self setupAnimationsOnProfileMedia] forKey:@"pulse"];
    }
    else {
        [self.base.layer removeAnimationForKey:@"pulse"];
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
