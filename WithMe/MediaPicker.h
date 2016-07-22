//
//  MediaPicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^MediaPickerMediaInfoBlock)(MediaType mediaType,
                                         NSData* thumbnailData,
                                         NSString* thumbnailFile,
                                         NSString* mediaFile,
                                         CGSize mediaSize,
                                         BOOL isReal);

typedef void(^MediaPickerMediaBlock)(MediaType mediaType,
                                     NSData* thumbnailData,
                                     NSData* originalData,
                                     NSData* movieData,
                                     BOOL isReal);

typedef void(^MediaPickerUserMediaBlock)(UserMedia* userMedia);

@interface MediaPicker : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (void) pickMediaOnViewController:(UIViewController*)viewController withMediaInfoHandler:(MediaPickerMediaInfoBlock)handler;
+ (void) pickMediaOnViewController:(UIViewController*)viewController withUserMediaHandler:(MediaPickerUserMediaBlock)handler;
+ (void) pickMediaOnViewController:(UIViewController*)viewController withMediaHandler:(MediaPickerMediaBlock)handler;

+ (UIViewController*) currenViewController;
@end
