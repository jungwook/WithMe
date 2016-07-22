//
//  S3File.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "S3File.h"

@interface S3File ()
@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, strong) NSURL* cachePath;
@end


@implementation S3File

+ (instancetype) file
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] init];
    });
    return sharedFile;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        NSURL* applicationPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL* systemPath = [applicationPath URLByAppendingPathComponent:@"Engine"];
        self.cachePath = [systemPath URLByAppendingPathComponent:@"MediaCache"];
        self.cache = [NSMutableDictionary dictionaryWithContentsOfURL:self.cachePath];
        if (!self.cache) {
            self.cache = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

+ (id)objectForKey:(id)key
{
    return [[S3File file] objectForKey:key];
}

+ (void) getDataFromFile:(id)filename completedBlock:(S3GetBlock)block progressBlock:(S3ProgressBlock)progress
{
    [[S3File file] getDataFromFile:filename completedBlock:block progressBlock:progress];
}

+ (void) getDataFromFile:(id)filename completedBlock:(S3GetBlock)block
{
    [[S3File file] getDataFromFile:filename completedBlock:block progressBlock:nil];
}

- (id) objectForKey:(id)key
{
    if (!key) {
        NSLog(@"ERROR: Cannot retrieve data from (null) key");
        return nil;
    }
    
    id cacheItem = [self.cache objectForKey:key];
    return cacheItem[@"data"];
}

- (void) setObject:(id)data forKey:(id)key
{
    if (!key) {
        NSLog(@"ERROR: Cannot store data to (null) key");
        return;
    }
    
    if (!data) {
        [self.cache removeObjectForKey:key];
        return;
    }
    else {
        @synchronized (self.cache) {
            id cacheItem = @{ @"updatedAt" : [NSDate date],
                              @"data" : data };
            
            [self.cache setObject:cacheItem forKey:key];
        }
    }
}

+ (void)synchronize
{
    [[S3File file] writeToCacheFile];
}

- (void) writeToCacheFile
{
    BOOL ret = [self.cache writeToURL:self.cachePath atomically:YES];
    if (!ret) {
        NSLog(@"ERROR: Error writing to S3FILE cache.");
    }
}

- (void) getDataFromFile:(id)filename completedBlock:(S3GetBlock)block progressBlock:(S3ProgressBlock)progress
{
    if (!filename) {
        if (block) {
            block(nil, nil, YES);
        }
        return;
    }

    NSData *data = [self objectForKey:filename];
    if (data) {
        if (block) {
            block(data, nil, YES);
        }
        return;
    }
    else {
        NSString *tempId = [ObjectIdStore randomId];
        NSURL *downloadURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempId]];
        [[NSFileManager defaultManager] removeItemAtURL:downloadURL error:nil];
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        downloadRequest.bucket = @"parsekr";
        downloadRequest.key = filename;
        downloadRequest.downloadingFileURL = downloadURL;
        downloadRequest.downloadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            int rate = (int)(totalBytesSent * 100.0 / totalBytesExpectedToSend);
            if (progress) {
                progress(rate);
            }
        };
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
            if (task.error != nil) {
                NSLog(@"%s %@ (%@)","Error downloading :", downloadRequest.key, filename);
                if (block) {
                    block(nil, task.error, NO);
                }
            }
            else {
                NSData *data = [NSData dataWithContentsOfURL:downloadURL];
                [self setObject:data forKey:filename];
                if (block) {
                    block(data, nil, NO);
                }
            }
            [[NSFileManager defaultManager] removeItemAtURL:downloadURL error:nil];
            
            return nil;
        }];
        return;
    }
}

+ (NSString*) saveData:(NSData *)data named:(id)filename extension:(NSString*)extension group:(id)group completedBlock:(S3PutBlock)block progress:(UIProgressView *)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        progress.progress = 0.0f;
    });
    return [[S3File file] saveData:data named:filename extension:extension group:group completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = 0.0f;
        });
        if (block) {
            block(file, succeeded, error);
        }
    } progressBlock:^(int percentDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = percentDone / 100.0f;
        });
    }];
}


+ (NSString*) saveData:(NSData *)data named:(id)filename extension:(NSString*)extension group:(id)group completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress
{
    return [[S3File file] saveData:data named:filename extension:extension group:group completedBlock:block progressBlock:progress];
}

- (NSString*) saveData:(NSData *)data named:(id)filename extension:(NSString*)extension group:(id)group completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress
{
    if (data) {
        if (!filename) {
            filename = [ObjectIdStore newObjectId];
        }
        NSString *username = [[User me] objectId];
        NSString *longname = [[[@"" stringByAppendingPathComponent:group] stringByAppendingPathComponent:username] stringByAppendingPathComponent:[filename stringByAppendingString:extension]];
        
        NSString *tempId = [ObjectIdStore randomId];
        NSURL *saveURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:tempId]];
        [[NSFileManager defaultManager] removeItemAtURL:saveURL error:nil];
        BOOL ret = [data writeToURL:saveURL atomically:YES];
        if (ret) {
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.bucket = @"parsekr";
            uploadRequest.key = longname;
            uploadRequest.body = saveURL;
            uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
            uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                int rate = (int)(totalBytesSent * 100.0 / totalBytesExpectedToSend);
                if (progress) {
                    progress(rate);
                }
            };
            
            [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                if (task.error != nil) {
                    NSLog(@"%s %@","Error uploading :", uploadRequest.key);
                    if (block) {
                        block(nil, NO, task.error);
                    }
                }
                else {
                    [self setObject:data forKey:longname];
                    if (block) {
                        block(longname, YES, nil);
                    }
                }
                [[NSFileManager defaultManager] removeItemAtURL:saveURL error:nil];
                return nil;
            }];
            
            return longname;
        }
        else {
            if (block) {
                block(nil, NO, nil);
            }
            return nil;
        }
    }
    else {
        if (block) {
            block(nil, NO, nil);
        }
        return nil;
    }
}

+ (NSString *)saveImageData:(NSData *)data
{
    return [S3File saveImageData:data completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

+ (NSString *)saveMovieData:(NSData *)data
{
    return [S3File saveMovieData:data completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

+ (NSString *)saveAudioData:(NSData *)data
{
    return [S3File saveAudioData:data completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

+ (NSString *)saveImageData:(NSData *)data completedBlock:(S3PutBlock)block
{
    return [S3File saveImageData:data completedBlock:block progressBlock:nil];
}

+ (NSString *)saveMovieData:(NSData *)data completedBlock:(S3PutBlock)block
{
    return [S3File saveMovieData:data completedBlock:block progressBlock:nil];
}

+ (NSString *)saveAudioData:(NSData *)data completedBlock:(S3PutBlock)block
{
    return [S3File saveAudioData:data completedBlock:block progressBlock:nil];
}

+ (NSString *)saveImageData:(NSData *)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress
{
    return [S3File saveData:data named:nil extension:@".jpg" group:@"ProfileMedia/" completedBlock:block progressBlock:progress];
}

+ (NSString *)saveImageData:(NSData *)data completedBlock:(S3PutBlock)block progress:(UIProgressView*)progress
{
    return [S3File saveData:data named:nil extension:@".jpg" group:@"ProfileMedia/" completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = 0.0f;
        });
        if (block) {
            block(file, succeeded, error);
        }
    } progressBlock:^(int percentDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = percentDone / 100.0f;
        });
    }];
}

+ (NSString *)saveMovieData:(NSData *)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress
{
    return [S3File saveData:data named:nil extension:@".mov" group:@"ProfileMedia/" completedBlock:block progressBlock:progress];
}

+ (NSString *)saveMovieData:(NSData *)data completedBlock:(S3PutBlock)block progress:(UIProgressView*)progress
{
    return [S3File saveMovieData:data completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = 0.0f;
        });
        if (block) {
            block(file, succeeded, error);
        }
    } progressBlock:^(int percentDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = percentDone / 100.0f;
        });
    }];
}

+ (NSString *)saveAudioData:(NSData *)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress
{
    return [S3File saveData:data named:nil extension:@".caf" group:@"AudioMedia/" completedBlock:block progressBlock:progress];
}

+ (NSString *)saveAudioData:(NSData *)data completedBlock:(S3PutBlock)block progress:(UIProgressView*)progress
{
    return [S3File saveAudioData:data completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = 0.0f;
        });
        if (block) {
            block(file, succeeded, error);
        }
    } progressBlock:^(int percentDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress.progress = percentDone / 100.0f;
        });
    }];
}

@end

