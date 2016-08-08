//
//  LocationPicker.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationPicker.h"
#import "LocationPickerView.h"
@import CoreImage;

@interface LocationPicker()
@property (nonatomic)           PickerPosition position;
@property (nonatomic, weak)     LocationPickerView *locationPickerView;
@property (nonatomic)           CGRect mapFrame;
@property (nonatomic)           CGPoint anchorPoint;
@property (nonatomic, strong)   CAShapeLayer *borderLayer;
@property (nonatomic, strong)   UIView* parentView;
@property (nonatomic, copy)     LocationPickerBlock pickerBlock;
@end

@implementation LocationPicker

+ (instancetype)pickerOnView:(UIView*)view picked:(LocationPickerBlock)pickerBlock
{
    return [LocationPicker pickerOnView:view titled:@"Update Location" picked:(LocationPickerBlock)pickerBlock];
}

+ (instancetype)pickerOnView:(UIView *)view titled:(NSString *)title picked:(LocationPickerBlock)pickerBlock
{
    return [LocationPicker pickerOnView:view titled:title fromView:nil picked:(LocationPickerBlock)pickerBlock];
}

+ (instancetype)pickerOnView:(UIView *)view titled:(NSString *)title fromView:(UIView *)parentView picked:(LocationPickerBlock)pickerBlock
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    static LocationPickerView *sharedPickerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPickerView = [[[NSBundle mainBundle] loadNibNamed:@"LocationPickerView" owner:self options:nil] firstObject];
    });
    
    sharedPickerView.title = title;
    LocationPicker *locationPicker = [[LocationPicker alloc] initOnView:view pickerView:sharedPickerView onWindow:window];
    locationPicker.pickerBlock = pickerBlock;
    locationPicker.parentView = parentView;
    
    [window addSubview:locationPicker];
    return locationPicker;
}


UIImage *grayRootScreen()
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIGraphicsBeginImageContextWithOptions(screenRect.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIView *copy = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    
    CGContextSetBlendMode(ctx, kCGBlendModeLuminosity);
    [copy.layer renderInContext:ctx];
    
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screengrab;
}

UIImage *grayScaleImageFromView(UIView * view)
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeLuminosity);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

UIImage* grayscaleCGImageFromUIImage(UIImage* image)
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorspace, kCGBitmapByteOrderDefault);
    CGContextDrawImage(context, CGRectMake(0,0, width,height), image.CGImage);
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    
    return retImage;
}

- (UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

-(UIImage*)makeUIImageFromCIImage:(CIImage*)ciImage
{
    CIContext *cicontext = [CIContext contextWithOptions:nil];
    UIImage * returnImage;
    CGImageRef processedCGImage = [cicontext createCGImage:ciImage fromRect:[ciImage extent]];
    returnImage = [UIImage imageWithCGImage:processedCGImage];
    CGImageRelease(processedCGImage);
    
    return returnImage;
}

- (instancetype) initOnView:(UIView*)view
                 pickerView:(LocationPickerView*)pickerView
                   onWindow:(UIWindow*)window
{
    self = [super initWithFrame:window.bounds];
    if (self)
    {
        UIColor *tintColor = [view isKindOfClass:[UIButton class]] ? view.tintColor : view.backgroundColor;

        self.locationPickerView = pickerView;
        self.locationPickerView.hidden = NO;
        self.locationPickerView.parent = self;
        self.locationPickerView.tintColor = tintColor;
        
        [self mapFrameAndPositionOnLocationPickerView:self.locationPickerView
                                       fromSenderRect:[view convertRect:view.bounds toView:window]
                                        andWindowRect:window.bounds];

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOutside:)]];
        [self addSubview:self.locationPickerView];
        
        CGFloat sx = 0.01;
        CGFloat sy = sx*self.locationPickerView.frame.size.height/self.locationPickerView.frame.size.width;

        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.78];
        
        UIView *buttonCopy = [view snapshotViewAfterScreenUpdates:NO];
        buttonCopy.frame = [view convertRect:view.bounds toView:window];
        [self addSubview:buttonCopy];
        
        self.alpha = 0;
        CATransform3D scale = CATransform3DMakeScale(sx, sy, 1);
        
        self.locationPickerView.layer.transform = scale;
        
        [UIView animateWithDuration:0.5
                              delay:0.1f
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                self.locationPickerView.layer.transform = CATransform3DIdentity;
                                self.alpha = 1.0f;
                            } completion:nil];

    }
    return self;
}

- (void) mapFrameAndPositionOnLocationPickerView:(LocationPickerView*)locationPickerView fromSenderRect:(CGRect)rect andWindowRect:(CGRect)windowRect
{
    PickerPosition position;
    const CGFloat windowIndent = 4; //indent from edge of the window
    const CGFloat arrowIndent = 4;
    
    CGFloat cx = CGRectGetMidX(rect), cy = CGRectGetMidY(rect);
    CGFloat sx = rect.origin.x, sy = rect.origin.y;
    CGFloat x = 0, y = 0, w = 0, h = 0, f = 0.3;
    
    CGFloat ls = sx, rs = CGRectGetWidth(windowRect)-(sx+rect.size.width), ts = sy, bs = CGRectGetHeight(windowRect)-(sy+rect.size.height);
    if (ls>rs && ls>ts && ls>bs) {
        x = 20+arrowIndent;
        w = sx - x;
        h = CGRectGetHeight(windowRect)*0.6f;
        y = MAX(cy-f*h, 20);
        position = kPickerPositionLeft;
    }
    else if (rs > ls && rs > ts && rs > bs) {
        x = sx+rect.size.width-arrowIndent;
        w = CGRectGetWidth(windowRect)-10-x;
        h = CGRectGetHeight(windowRect)*0.6f;
        y = MAX(cy-f*h, 20);
        position = kPickerPositionRight;
    }
    else if (ts > bs && ts > ls && ts > rs) { // top position
        w = CGRectGetWidth(windowRect)*0.9f;
        h = sy*0.75f;
        x = (cx > CGRectGetMidX(windowRect)) ? CGRectGetWidth(windowRect) - (w+windowIndent) : windowIndent;
        y = MAX(sy - h, 20);
        position = kPickerPositionTop;
    }
    else { //bottom position
        w = CGRectGetWidth(windowRect)*0.9f;
        h = (CGRectGetHeight(windowRect)-cy)*0.75f;
        x = (cx > CGRectGetMidX(windowRect)) ? CGRectGetWidth(windowRect) - (w+windowIndent) : windowIndent;
        y = -arrowIndent + sy + CGRectGetHeight(rect);
        position = kPickerPositionBottom;
    }
    
    locationPickerView.frame = CGRectMake(x, y, w, h);
    [locationPickerView setPosition:position fromSenderRect:rect windowRect:windowRect];
}

- (void)dealloc
{
    __LF
}

- (void) saveAndCloseWithLocation:(CLLocationCoordinate2D)coordinate address:(NSString*)address image:(UIImage*)mapImage
{
    if (self.pickerBlock) {
        self.pickerBlock(coordinate, address, mapImage);
        [self closeAndKill];
    }
}

- (void) closeAndKill
{
    UIView *sv = [self snapShotViewWithFrameAnchorAndPosition:self.locationPickerView];
    [self addSubview:sv];
    self.locationPickerView.hidden = YES;
    
    [UIView animateWithDuration:0.1 animations:^{
        sv.layer.transform = CATransform3DMakeScale(1.01, 1.01, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            sv.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1);
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.alpha = 1.0f;
            [self.borderLayer removeFromSuperlayer];
            [self removeFromSuperview];
        }];
    }];
}

- (UIView*) snapShotViewWithFrameAnchorAndPosition:(UIView*)view
{
    UIView *sv = [view snapshotViewAfterScreenUpdates:NO];
    sv.frame = view.frame;
    setAnchorPoint(view.layer.anchorPoint, sv.layer);
    return sv;
}

- (void) tappedOutside:(id)sender
{
//    [self closeAndKill];
}
@end
