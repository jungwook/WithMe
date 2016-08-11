//
//  ImagePanel.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ImagePanel.h"

@implementation ImagePanel

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
        
//        CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
//        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
//        [filter setDefaults];
//        [filter setValue:ciimage forKey:kCIInputImageKey];
//        //        [filter setValue:@(0.8) forKey:kCIInputIntensityKey];
//        //        [filter setValue:[CIColor colorWithCGColor:[UIColor colorWithWhite:1 alpha:1].CGColor] forKey:kCIInputColorKey];
//        
//        UIImage *output = [UIImage imageWithCIImage:filter.outputImage];
        
        UIImage *output = [self convertImageToGrayScale:image];
        output = image;
        [output drawInRect:CGRectMake(0, height, w, h)];
        height+=(h+1);
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
