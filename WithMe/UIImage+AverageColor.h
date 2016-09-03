//
//  UIImage+AverageColor.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#ifndef UIImage_AverageColor_h
#define UIImage_AverageColor_h

@interface UIImage(AverageColor)
- (UIColor *)averageColor;
- (UIImage *)imageWithColor:(UIColor *)color;
- (UIColor *)averageColorWithPoints:(NSUInteger)points;
- (UIColor *)averageColorInRect:(CGRect)frame withPoints:(NSUInteger)points;
- (UIImage *)grayscaleImage;
@end

#endif /* UIImage_AverageColor_h */
