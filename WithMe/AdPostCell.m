//
//  AdPostCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdPostCell.h"
#import "IndentedLabel.h"
#import "NSDate+TimeAgo.h"

@interface ShadowBackView : UIView
+ (instancetype) shadowOnToView:(UIView*)view;
@end

@implementation ShadowBackView

+ (instancetype) shadowOnToView:(UIView*)view
{
    return [[ShadowBackView alloc] initOnToView:view];
}

- (instancetype) initOnToView:(UIView*)view
{
    self = [super initWithFrame:view.bounds];
    if (self) {
        [view insertSubview:self atIndex:0];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        self.layer.shadowColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOpacity = 0.5f;
        self.backgroundColor = view.backgroundColor;
        self.layer.cornerRadius = view.layer.cornerRadius;
        view.clipsToBounds = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

@end

@interface AdPostImageView : UIView
@property (nonatomic, strong) NSArray *images;

- (void) clearAllContents;
@end

@implementation AdPostImageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.contents = nil;
    self.layer.masksToBounds = YES;
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return newImage;
}

-(UIImage*) imageFromCIImage:(CIImage*)ciImage
{
    CIContext* cicontext = [CIContext contextWithOptions:nil];
    CGImageRef processedCGImage = [cicontext createCGImage:ciImage fromRect:[ciImage extent]];
    UIImage * returnImage = [UIImage imageWithCGImage:processedCGImage];
    CGImageRelease(processedCGImage);
    return returnImage;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat totalHeight=[self totalHeight], panelHeight = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    __block CGFloat height = 0;
    
    [self.images enumerateObjectsUsingBlock:^(UIImage* _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat h = panelHeight * image.size.height / totalHeight;

        CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
        [filter setDefaults];
        [filter setValue:ciimage forKey:kCIInputImageKey];
//        [filter setValue:@(0.8) forKey:kCIInputIntensityKey];
//        [filter setValue:[CIColor colorWithCGColor:[UIColor colorWithWhite:1 alpha:1].CGColor] forKey:kCIInputColorKey];

        UIImage *output = [UIImage imageWithCIImage:filter.outputImage];
        [output drawInRect:CGRectMake(0, height, w, h)];
        height+=h;
    }];
}

- (void)clearAllContents
{
    self.images = nil;
    self.layer.contents = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (CGFloat) totalHeight
{
    __block CGFloat height = 0;
    [self.images enumerateObjectsUsingBlock:^(UIImage* _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        height += image.size.height;
    }];
    return height;
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    [self setNeedsLayout];
}

@end

@interface AdPostCell()
@property (weak, nonatomic) IBOutlet UIView *shadowPanel;
@property (weak, nonatomic) IBOutlet UIView *bottomPanel;
@property (weak, nonatomic) IBOutlet UIView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet IndentedLabel *gender;
@property (weak, nonatomic) IBOutlet IndentedLabel *distance;
@property (weak, nonatomic) IBOutlet IndentedLabel *payment;
@property (weak, nonatomic) IBOutlet IndentedLabel *category;
@property (weak, nonatomic) IBOutlet UILabel *withMeTag;
@property (weak, nonatomic) IBOutlet UILabel *timeAgo;
@property (weak, nonatomic) IBOutlet UIView *panel;
@property (weak, nonatomic) IBOutlet AdPostImageView *imagePanel;
@property (weak, nonatomic) IBOutlet IndentedLabel *endCategory;
@property (weak, nonatomic) IBOutlet UILabel *intro;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) NSObject  *lock;
@end

@implementation AdPostCell

UIImage* cropWithInset(UIImage *image, UIEdgeInsets inset)
{
    CGRect rect = CGRectMake(0, 0, image.size.width-inset.top-inset.bottom, image.size.height-inset.top-inset.bottom);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [image scale]);
    [image drawAtPoint:CGPointMake(-inset.left, -inset.top)];
    UIImage *cropped_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cropped_image;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    __LF
    
    self.lock = [NSObject new];
    self.imagePanel.clipsToBounds = YES;
    self.photo.layer.cornerRadius = 20.0f;
    self.photo.layer.masksToBounds = YES;
    self.clipsToBounds = NO;
    self.layer.cornerRadius = 8.0f;
    self.shadowPanel.layer.cornerRadius = 5;
    self.shadowPanel.clipsToBounds = NO;
}

- (void) setAd:(Ad *)ad
{
    [self initializeDefaultValues];
    
    _ad = ad;
    
    User *adUser = ad.user;
    UIColor *backColor = [UIColor grayColor];
    
    [adUser fetched:^{
        self.nickname.text = adUser.nickname;
        self.gender.text = adUser.genderCode;
        self.distance.text = @"<1km";

        // Colors
        self.bottomPanel.backgroundColor = adUser.genderColor;
        self.bottomPanel.backgroundColor = backColor;
        self.gender.backgroundColor = colorWhite;
        self.gender.textColor = adUser.genderColor;
        self.nickname.textColor = colorWhite;
        self.photo.layer.borderColor = colorWhite.CGColor;
        self.photo.layer.borderWidth = 3.0f;
        self.photo.backgroundColor = adUser.genderColor.lighterColor;

        [adUser profileMediaThumbnailLoaded:^(UIImage *image) {
            drawImage(image, self.photo);
        }];
    }];
//    UIColor *categoryColor = [User categoryColorForEndCategory:ad.category];
    
    self.title.text = ad.title;
    self.title.textColor = backColor;
    self.timeAgo.text = ad.updatedAt.timeAgoSimple;
    self.timeAgo.textColor = colorWhite;
    self.endCategory.text = [[@"#" stringByAppendingString:ad.activity.name] uppercaseString];
//    self.endCategory.backgroundColor = categoryColor;
    self.endCategory.backgroundColor = backColor;
    self.endCategory.textColor = colorWhite;
    self.category.text = [[User categoryForEndCategory:ad.activity.category.name] uppercaseString];
//    self.category.backgroundColor = categoryColor.darkerColor;
    self.category.backgroundColor = backColor;
//    self.withMeTag.textColor = categoryColor.darkerColor;
    self.withMeTag.textColor = backColor;
    self.category.textColor = colorWhite;
    self.intro.text = ad.intro;
    self.payment.text = ad.paymentTypeString;
//    self.payment.backgroundColor = ad.paymentTypeColor;
    self.payment.backgroundColor = backColor;
    self.distance.backgroundColor = backColor;

    [self loadAdMedia:ad];
}

- (void) loadAdMedia:(Ad*)ad
{
    __block NSUInteger count = ad.media.count;
    NSMutableArray *loadedImages = [NSMutableArray arrayWithCapacity:count];
    [ad.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
        [S3File getDataFromFile:media.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            UIImage *cropped = cropWithInset([UIImage imageWithData:data], UIEdgeInsetsMake(10, 10, 10, 10));
            [loadedImages addObject:cropped];
            if (--count == 0) {
                [self.imagePanel setImages:loadedImages];
            }
        }];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void) initializeDefaultValues
{
    self.backgroundColor = [UIColor whiteColor];
    self.panel.backgroundColor = [UIColor clearColor];

    self.title.text = @"Loading...";
    self.nickname.text = @"Loading...";
    self.gender.text = @".";
    self.distance.text = @"...";
    self.photo.layer.contents = nil;
    self.photo.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    self.category.font = kCategoryFont;
    self.endCategory.font = kEndCategoryFont;
    self.intro.font = kIntroFont;
    self.title.font = kTitleFont;
    [self.imagePanel clearAllContents];
}
@end
