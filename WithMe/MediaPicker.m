//
//  MediaPicker.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaPicker.h"
#import "S3File.h"
#import "AppDelegate.h"

#define kThumbnailWidth 300
#define kVideoThumbnailWidth 600

@import MobileCoreServices;

@interface MediaPicker ()
@property (nonatomic, copy) MediaPickerMediaInfoBlock userMediaInfoBlock;
@property (nonatomic, copy) MediaPickerUserMediaBlock userMediaBlock;
@property (nonatomic, copy) MediaPickerMediaBlock mediaBlock;
@end

@implementation MediaPicker

typedef void(^ActionHandlers)(UIAlertAction * _Nonnull action);

+ (void) pickMediaOnViewController:(UIViewController*)viewController withMediaInfoHandler:(MediaPickerMediaInfoBlock)handler
{
    UIViewController* vc = viewController ? viewController : [MediaPicker currenViewController];
    [MediaPicker handleAlertOnViewController:vc
                              libraryHandler:^(UIAlertAction * _Nonnull action) {
        [vc presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary
                                                                  userMediaInfoBlock:handler]
                                     animated:YES
                                   completion:nil];
    }
                               cameraHandler:^(UIAlertAction * _Nonnull action) {
        [vc presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypeCamera
                                                                  userMediaInfoBlock:handler]
                                     animated:YES
                                   completion:nil];
    }];
}

+ (void) pickMediaOnViewController:(UIViewController *)viewController withUserMediaHandler:(MediaPickerUserMediaBlock)handler
{
    UIViewController* vc = viewController ? viewController : [MediaPicker currenViewController];
    [MediaPicker handleAlertOnViewController:vc
                              libraryHandler:^(UIAlertAction * _Nonnull action) {
                                  [vc presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary userMediaBlock:handler]
                                                               animated:YES
                                                             completion:nil];
                              }
                               cameraHandler:^(UIAlertAction * _Nonnull action) {
                                   [vc presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypeCamera userMediaBlock:handler]
                                                                animated:YES
                                                              completion:nil];
                               }];
}

+ (void)pickMediaOnViewController:(UIViewController *)viewController withMediaHandler:(MediaPickerMediaBlock)handler
{
    UIViewController* vc = viewController ? viewController : [MediaPicker currenViewController];
    [MediaPicker handleAlertOnViewController:vc
                              libraryHandler:^(UIAlertAction * _Nonnull action) {
                                  [vc presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary mediaBlock:handler]
                                                   animated:YES
                                                 completion:nil];
                              }
                               cameraHandler:^(UIAlertAction * _Nonnull action) {
                                   [vc presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypeCamera mediaBlock:handler]
                                                    animated:YES
                                                  completion:nil];
                               }];
}

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaInfoBlock:(MediaPickerMediaInfoBlock)block
{
    return [[MediaPicker alloc] initWithSourceType:sourceType userMediaInfoBlock:block];
}

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaBlock:(MediaPickerUserMediaBlock)block
{
    return [[MediaPicker alloc] initWithSourceType:sourceType userMediaBlock:block];
}

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType mediaBlock:(MediaPickerMediaBlock)block
{
    return [[MediaPicker alloc] initWithSourceType:sourceType mediaBlock:block];
}


- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaInfoBlock:(MediaPickerMediaInfoBlock)block
{
    self = [super init];
    if (self) {
        [self selfInitializersWithSourceType:sourceType userMediaInfoBlock:block userMediaBlock:nil mediaBlock:nil];
    }
    return self;
}

- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaBlock:(MediaPickerUserMediaBlock)block
{
    self = [super init];
    if (self) {
        [self selfInitializersWithSourceType:sourceType userMediaInfoBlock:nil userMediaBlock:block mediaBlock:nil];
    }
    return self;
}

- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType)sourceType mediaBlock:(MediaPickerMediaBlock)block
{
    self = [super init];
    if (self) {
        [self selfInitializersWithSourceType:sourceType userMediaInfoBlock:nil userMediaBlock:nil mediaBlock:block];
    }
    return self;
}

- (void) selfInitializersWithSourceType:(UIImagePickerControllerSourceType)sourceType
                     userMediaInfoBlock:(MediaPickerMediaInfoBlock)userMediaInfoBlock
                         userMediaBlock:(MediaPickerUserMediaBlock)userMediaBlock
                             mediaBlock:(MediaPickerMediaBlock)mediaBlock
{
    self.delegate = self;
    self.allowsEditing = YES;
    self.videoMaximumDuration = 10;
    self.sourceType = sourceType;
    self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.userMediaInfoBlock = userMediaInfoBlock;
    self.userMediaBlock = userMediaBlock;
    self.mediaBlock = mediaBlock;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.mediaBlock) {
        self.mediaBlock( NO, nil, nil, nil, NO, NO);
    }
    else if (self.userMediaBlock) {
        self.userMediaBlock(nil, NO);
    }
    else if (self.userMediaInfoBlock) {
        self.userMediaInfoBlock(NO, nil, nil, nil, CGSizeZero, NO, NO);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSURL *url = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        [self handlePhoto:info url:url source:picker.sourceType];
    }
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)== kCFCompareEqualTo) {
        [self handleVideo:info url:url source:picker.sourceType];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) handlePhoto:(NSDictionary<NSString*, id>*)info url:(NSURL*)url source:(UIImagePickerControllerSourceType)sourceType
{
    BOOL isReal = (sourceType == UIImagePickerControllerSourceTypeCamera);
    // Original image
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Original image data
    NSData *imageData = UIImageJPEGRepresentation(image, kJPEGCompressionFull);
    
    // Thumbnail data
    NSData *thumbnailData = compressedImageData(imageData, kThumbnailWidth);
    
    if (self.mediaBlock) {
        self.mediaBlock(kMediaTypePhoto, thumbnailData, imageData, nil, isReal, YES);
    }
    else {
        [S3File saveImageData:thumbnailData completedBlock:^(NSString *thumbnailFile, BOOL succeeded, NSError *error)
         {
             if (succeeded && !error) {
                 [S3File saveImageData:imageData completedBlock:^(NSString *mediaFile, BOOL succeeded, NSError *error) {
                     
                     if (succeeded && !error) {
                         if (self.userMediaInfoBlock) {
                             self.userMediaInfoBlock( kMediaTypePhoto,
                                                     thumbnailData,
                                                     thumbnailFile,
                                                     mediaFile,
                                                     image.size,
                                                     isReal, YES);
                         }
                         
                         if (self.userMediaBlock) {
                             UserMedia *media = [UserMedia object];
                             media.mediaSize = image.size;
                             media.mediaFile = mediaFile;
                             media.thumbailFile = thumbnailFile;
                             media.mediaType = kMediaTypePhoto;
                             media.isRealMedia = isReal;
                             
                             self.userMediaBlock(media, YES);
                         }
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

- (void) handleVideo:(NSDictionary<NSString*, id>*)info url:(NSURL*)url source:(UIImagePickerControllerSourceType)sourceType
{
    BOOL isReal = (sourceType == UIImagePickerControllerSourceTypeCamera);
    NSString *tempId = randomObjectId();
    NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:tempId]];
    
    // Video Asset
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    // Thumbnail Image
    UIImage *thumbnailImage = [self thumbnailFromVideoAsset:asset source:sourceType];
    
    // Thumbnail Image data @ full compression
    NSData *thumbnailData = compressedImageData(UIImageJPEGRepresentation(thumbnailImage, kJPEGCompressionFull), kVideoThumbnailWidth);

    if (self.mediaBlock)
    {
        [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession) {
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
                self.mediaBlock(kMediaTypeVideo, thumbnailData, nil, videoData, isReal, YES);
                [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
            }
        }];
    }
    else {
        [S3File saveImageData:thumbnailData completedBlock:^(NSString *thumbnailFile, BOOL succeeded, NSError *error) {
            [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession) {
                if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                    NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
                    
                    [S3File saveMovieData:videoData completedBlock:^(NSString *mediaFile, BOOL succeeded, NSError *error) {
                        if (succeeded && !error) {
                            if (self.userMediaInfoBlock) {
                                self.userMediaInfoBlock(kMediaTypeVideo,
                                                        thumbnailData,
                                                        thumbnailFile,
                                                        mediaFile,
                                                        thumbnailImage.size,
                                                        isReal,
                                                        YES);
                            }
                            
                            if (self.userMediaBlock) {
                                UserMedia *media = [UserMedia object];
                                media.mediaSize = thumbnailImage.size;
                                media.mediaFile = mediaFile;
                                media.thumbailFile = thumbnailFile;
                                media.mediaType = kMediaTypeVideo;
                                media.isRealMedia = isReal;
                                
                                self.userMediaBlock(media, YES);
                            }
                        }
                        else {
                            NSLog(@"ERROR:%@", error.localizedDescription);
                        }
                        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
                    }];
                }
            }];
        } progressBlock:nil];
    }
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset1920x1080];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}

+ (UIViewController*) currenViewController
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    return [delegate.menuController.centerViewController.childViewControllers firstObject];
}


- (UIImage*) thumbnailFromVideoAsset:(AVAsset*)asset source:(UIImagePickerControllerSourceType)sourceType
{
    __LF
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generateImg.appliesPreferredTrackTransform = YES;
    
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:[generateImg copyCGImageAtTime:CMTimeMake(1, 1) actualTime:NULL error:nil]];
    return thumbnail;
}

+ (void) handleAlertOnViewController:(UIViewController*)viewController
                      libraryHandler:(ActionHandlers)library
                       cameraHandler:(ActionHandlers)camera
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Library"
                                                  style:UIAlertActionStyleDefault
                                                handler:library]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                  style:UIAlertActionStyleDefault
                                                handler:camera]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
