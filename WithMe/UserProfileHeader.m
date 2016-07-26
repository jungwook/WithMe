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
    CGFloat locations[] = {0.0, 0.3, 1};
    
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

@property (nonatomic, strong)   Notifications *notif;
@end

@implementation UserProfileHeader

#define setAppFont(__X__) __X__ = appFont([__X__ pointSize]*1.2)

- (void)awakeFromNib
{
    __LF
    [super awakeFromNib];
//    self.nickname.textColor = colorBlue;
    self.ageGroup.textColor = colorBlue;
    self.gender.textColor = colorBlue;
//    self.withMe.textColor = colorBlue;
    self.desc.textColor = colorBlue;
    self.location.textColor = colorBlue;
    
//    self.withMe.font = appFont([self.withMe.font pointSize]*1.2);
//    setAppFont(self.withMe.font);
    setAppFont(self.ageGroup.font);
    setAppFont(self.gender.font);
    setAppFont(self.desc.font);
    setAppFont(self.location.font);
    
    [self setControlFontAndColor:self.nickname ratio:1.0f];
    [self setControlFontAndColor:self.withMe ratio:1.2f];
    
    self.nickname.radius = 5.0f;
    self.ageGroup.radius = 5.0f;
    self.gender.radius = 5.0f;
    self.withMe.radius = 5.0f;

    self.photo.radius = 8.0f;
    self.notif = [Notifications new];
    
    ActionBlock deleteAction = ^(id param) {
        [self.photo loadMediaFromUserMedia:param];
    };
    ActionBlock changeAction = ^(id param) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photo loadMediaFromUserMedia:param];
        });
    };
    [self.notif setNotification:@"NotifyProfileMediaDeleted" forAction:deleteAction];
    [self.notif setNotification:@"NotifyProfileMediaChanged" forAction:changeAction];

    UIImage *editImage = [UIImage imageNamed:@"edit"];
    editImage = [editImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.gpsButton setImage:editImage forState:UIControlStateNormal];
    [self.gpsButton setTintColor:colorBlue];
}

- (void) setControlFontAndColor:(id)control ratio:(CGFloat)ratio
{
    UIFont *font = appFont(20);
    if ([control respondsToSelector:@selector(font)]) {
        font = [control performSelector:@selector(font)];
    }
    
    if ([control respondsToSelector:@selector(setTextColor:)]) {
        [control performSelector:@selector(setTextColor:) withObject:colorBlue];
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
    }];
}
@end
