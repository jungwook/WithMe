//
//  UserMediaView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMediaView.h"

@interface UserMediaView()
@property (nonatomic, strong) NSMutableArray <UIImage *> *images;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *animationTimer;
@end

@implementation UserMediaView

static const NSTimeInterval kKBDefaultTimePerImage      = 11.0f;
static const NSTimeInterval kKBDefaultChangeImageTime   = 1.0f;
static const NSTimeInterval kAnimationTime              = 5.4f;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    self.timePerImage = self.timePerImage ? : kKBDefaultTimePerImage;
    self.changeImageTime = self.changeImageTime ? : kKBDefaultChangeImageTime;
    self.animationTime = kAnimationTime;
    _index = -1;
    
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationTime+0.5f
                                                           target:self
                                                         selector:@selector(animateLayer)
                                                         userInfo:nil
                                                          repeats:YES];
    
    [self.animationTimer fire];
}

- (void)dealloc
{
    [self.timer invalidate];
    [self.animationTimer invalidate];
}

- (void)setUser:(User *)user
{
    [self.layer removeAllAnimations];
    [self.timer invalidate];

    self.images = [NSMutableArray array];
    
    _user = user;
    
    [user fetched:^{
        [user.media.firstObject imageLoaded:^(UIImage *image) {
            self.images = [NSMutableArray array];
            [self.images addObject:image ? image.grayscaleImage : [UIImage imageNamed:@"main face"].grayscaleImage];
            [self tickUser];
        }];
    }];
}

- (void) setAd:(Ad *)ad
{
    [self.layer removeAllAnimations];
    [self.timer invalidate];
    
    _ad = ad;
    
    [ad firstMediaImageLoaded:^(UIImage *image) {
        self.images = [NSMutableArray array];
        [self.images addObject:image.grayscaleImage];
        [self tickAd];
    }];
}

- (void) tickUser
{
    static NSInteger index = 0;
    static NSInteger imageIndex = 0;
    
    imageIndex = imageIndex % self.images.count;
    [self changeToImage:[self.images objectAtIndex:imageIndex++]];
    
    index = (index + 1) % self.user.media.count;
    [[self.user.media objectAtIndex:index] imageLoaded:^(UIImage *image) {
        [self.images addObject:image ? image.grayscaleImage : [UIImage imageNamed:@"main face"].grayscaleImage];
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timePerImage - self.changeImageTime
                                                      target:self
                                                    selector:@selector(tickUser)
                                                    userInfo:nil
                                                     repeats:NO];
    }];
}

- (void) tickAd
{
    static NSInteger index = 0;
    static NSInteger imageIndex = 0;
    
    imageIndex = imageIndex % self.images.count;
    [self changeToImage:[self.images objectAtIndex:imageIndex++]];
    
    index = (index + 1) % self.ad.media.count;
    [self.ad mediaImageAtIndex:index loaded:^(UIImage *image) {
        [self.images addObject:image ? image.grayscaleImage : [UIImage imageNamed:@"main face"].grayscaleImage];
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timePerImage - self.changeImageTime
                                                      target:self
                                                    selector:@selector(tickAd)
                                                    userInfo:nil
                                                     repeats:NO];
    }];
}

- (void)changeToImage:(UIImage *)image
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setImage:image ? image : [UIImage imageNamed:@"main face"]];
        CATransition *transition = [CATransition animation];
        transition.duration = self.changeImageTime;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.removedOnCompletion = YES;
        
        [self.layer addAnimation:transition forKey:nil];
    });
}

- (void)animateLayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat scale = 0;
        CGFloat moveX = 0;
        CGFloat moveY = 0;
        
        NSInteger rs = arc4random()%20;
        NSInteger rx = arc4random()%(2*rs)-rs;
        NSInteger ry = arc4random()%(2*rs)-rs;
        
        CGFloat frs = rs / 100.0f, frx = rx / 100.0f, fry = ry / 100.0;
        
        scale = 1 + frs;
        moveX = (self.frame.size.width * frx);
        moveY = (self.frame.size.width * fry);
        
        CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        CAKeyframeAnimation *transXnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
        CAKeyframeAnimation *transYnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        
        scaleAnim.values = @[[self.layer.presentationLayer valueForKeyPath:@"transform.scale"] ? : @(self.layer.transform.m11), @(scale)];
        transXnim.values = @[[self.layer.presentationLayer valueForKeyPath:@"transform.translation.x"] ? : @(self.layer.transform.m14), @(moveX / 2)];
        transYnim.values = @[[self.layer.presentationLayer valueForKeyPath:@"transform.translation.y"] ? : @(self.layer.transform.m24), @(moveY / 2)];
        
        scaleAnim.fillMode =
        transXnim.fillMode =
        transYnim.fillMode = kCAFillModeForwards;
        
        scaleAnim.removedOnCompletion =
        transXnim.removedOnCompletion =
        transYnim.removedOnCompletion = NO;
        
        scaleAnim.duration =
        transXnim.duration =
        transYnim.duration = self.animationTime;
        
        scaleAnim.timingFunction =
        transXnim.timingFunction =
        transYnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        scaleAnim.removedOnCompletion =
        transXnim.removedOnCompletion =
        transYnim.removedOnCompletion = NO;
        
        [self.layer removeAnimationForKey:@"S"];
        [self.layer removeAnimationForKey:@"X"];
        [self.layer removeAnimationForKey:@"Y"];
        
        [self.layer addAnimation:scaleAnim forKey:@"S"];
        [self.layer addAnimation:transXnim forKey:@"X"];
        [self.layer addAnimation:transYnim forKey:@"Y"];
    });
}

@end
