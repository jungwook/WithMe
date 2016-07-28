//
//  UserProfileHeader.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserProfileHeader.h"
#import "MediaView.h"
#import "ListField.h"

@interface HorizonalGradientUILabel : UILabel

@end

@implementation HorizonalGradientUILabel

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Create gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 0.8, 1};
    
    UIColor *centerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIColor *edgeColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:
                       (__bridge id)centerColor.CGColor,
                       (__bridge id)centerColor.CGColor,
                       (__bridge id)edgeColor.CGColor,
                       nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, self.bounds.size.height/2.0f), CGPointMake(self.bounds.size.width, self.bounds.size.height/2.0f), kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
@end

@interface UserProfileHeader()
@property (weak, nonatomic) IBOutlet HorizonalGradientUILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet ListField *withMe;
@property (weak, nonatomic) IBOutlet ListField *ageGroup;
@property (weak, nonatomic) IBOutlet ListField *gender;
@property (weak, nonatomic) IBOutlet UIView *shadowBack;
@property (weak, nonatomic) IBOutlet UIButton *gpsButton;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@property (nonatomic, strong)   Notifications *notif;
@end

@implementation UserProfileHeader

#define setAppFont(__X__) __X__ = appFont([__X__ pointSize]*1.2)

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
    
    [self setControlFontAndColor:self.nickname ratio:1.0f color:colorBlue];
    [self setControlFontAndColor:self.desc ratio:1.2f color:colorBlue];
    [self setControlFontAndColor:self.location ratio:1.2f color:colorBlue];
    
    [self setControlFontAndColor:self.ageGroup ratio:1.2f color:colorWhite];
    [self setControlFontAndColor:self.gender ratio:1.2f color:colorWhite];
    [self setControlFontAndColor:self.withMe ratio:1.2f color:colorWhite];
    
    [self setControlFontAndColor:self.headerTitle ratio:1.2f color:[UIColor whiteColor]];
    
    self.nickname.radius = 5.0f;
    self.ageGroup.radius = 5.0f;
    self.gender.radius = 5.0f;
    self.withMe.radius = 5.0f;

    self.photo.radius = 18.0f;
    self.notif = [Notifications new];
    
    ActionBlock deleteAction = ^(id param) {
        [self.photo loadMediaFromUserMedia:param];
        [self setTitle:[NSString stringWithFormat:@"User Media (%ld)", self.user.media.count]];
    };
    ActionBlock changeAction = ^(id param) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photo loadMediaFromUserMedia:param];
            [self setTitle:[NSString stringWithFormat:@"User Media (%ld)", self.user.media.count]];
        });
    };
    ActionBlock updateAction = ^(id param) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:[NSString stringWithFormat:@"User Media (%ld)", self.user.media.count]];
        });
    };
    [self.notif setNotification:@"NotifyProfileMediaDeleted" forAction:deleteAction];
    [self.notif setNotification:@"NotifyProfileMediaChanged" forAction:changeAction];
    [self.notif setNotification:@"NotifyUserMediaChanged" forAction:updateAction];

    UIImage *editImage = [UIImage imageNamed:@"edit"];
    editImage = [editImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.gpsButton setImage:editImage forState:UIControlStateNormal];
    [self.gpsButton setTintColor:colorBlue];
    [self.desc.layer addAnimation:[self titleAnimations] forKey:@"transition"];
}

- (CAAnimation*) titleAnimations
{
    CATransition* transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 1.0;
    
    CABasicAnimation *ta1 =[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    ta1.duration = 1;
    ta1.repeatCount = 1;
    ta1.autoreverses = NO;
    ta1.fromValue = @(self.nickname.bounds.size.width);
    ta1.toValue = @(0);
    ta1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *fa1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fa1.duration = 1;
    fa1.fromValue = @(0);
    fa1.toValue = @(1);
    fa1.fillMode = kCAFillModeForwards;
    fa1.repeatCount = 1;
    fa1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *ta2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    ta2.beginTime = 4;
    ta2.duration = 1.5;
    ta2.repeatCount = 1;
    ta2.autoreverses = NO;
    ta2.fromValue = @(0);
    ta2.toValue = @(-self.nickname.bounds.size.width*1.5);
    ta2.fillMode = kCAFillModeForwards;
    ta2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *fa2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fa2.beginTime = 4;
    fa2.duration = 1.5;
    fa2.fromValue = @(1);
    fa2.toValue = @(0);
    fa2.fillMode = kCAFillModeForwards;
    fa2.repeatCount = 1;
    fa2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *group = [CAAnimationGroup new];
    group.duration = 10;
    group.repeatCount = INFINITY;
    group.animations = @[ta1, fa1, ta2, fa2];
    
    return group;
}


- (void)setTitle:(NSString*)title
{
    self.headerTitle.text = title;
}

- (void) setControlFontAndColor:(id)control ratio:(CGFloat)ratio color:(UIColor*) color
{
    UIFont *font = appFont(20);
    if ([control respondsToSelector:@selector(font)]) {
        font = [control performSelector:@selector(font)];
    }
    if ([control isKindOfClass:[UIView class]]) {
        [control setRadius:10];
    }
    if ([control respondsToSelector:@selector(setTextColor:)]) {
        [control performSelector:@selector(setTextColor:) withObject:color];
    }
    if ([control respondsToSelector:@selector(setFont:)]) {
        [control performSelector:@selector(setFont:) withObject:appFont(ratio*[font pointSize])];
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setShadowOnView:self.shadowBack];
}

- (void) setShadowOnView:(UIView*)view
{
    __LF
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:self.photo.radius];
    view.backgroundColor = [UIColor clearColor];
    view.layer.shadowPath = shadowPath.CGPath;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOpacity = 0.8f;
}

- (void)setUser:(User *)user
{
    _user = user;
    [self.user fetched:^{
        self.desc.text = [NSString stringWithFormat:@"%@/%@/%@ - \"%@ with me!\"", self.user.nickname, self.user.genderTypeString, self.user.age, self.user.withMe];
        [self.withMe setPickerForWithMesWithHandler:^(id item) {
            self.user.withMe = item;
            self.desc.text = [NSString stringWithFormat:@"%@/%@/%@ - \"%@ with me!\"", self.user.nickname, self.user.genderTypeString, self.user.age, self.user.withMe];
            [self.user saved:nil];
        }];
        [self.ageGroup setPickerForAgeGroupsWithHandler:nil];
        [self.gender setPickerForGendersWithHandler:nil];
        
        self.nickname.text = self.user.nickname;
        self.withMe.text = self.user.withMe;
        self.ageGroup.text = self.user.age;
        self.gender.text = self.user.genderTypeString;
        
        self.gender.radius = 5.0f;
        self.withMe.radius = 5.0f;
        self.ageGroup.radius = 5.0f;
        
        [self.photo setEditableAndUserProfileMediaHandler:nil];
        [self.photo loadMediaFromUser:self.user];

        [self setTitle:[NSString stringWithFormat:@"User Media (%ld)", self.user.media.count]];
    }];
}
@end
