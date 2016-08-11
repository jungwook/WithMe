//
//  WithMe.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "WithMe.h"

@interface WithMe()
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableDictionary *categoryImages;
@end

static NSString * const kCategories = @"CategoriesV1.1";
static NSString * const kActivities = @"ActivitiesV1.1";

@implementation WithMe

+ (instancetype) new
{
    static WithMe* sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[WithMe alloc] init];
    });
    return sharedFile;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.categoryImages = [NSMutableDictionary dictionary];
        [self initializeCategories:^{
            NSLog(@"Initialized Categories...");
            [self downloadCategoryImages];
        } andActivities:^{
            NSLog(@"Initialized Activities...");
        }];
    }
    return self;
}

- (UIImage*) imageForCategory:(Category *)category
{
    return [self.categoryImages objectForKey:category.objectId];
}

- (void) downloadCategoryImages
{
    __block NSInteger count = self.categories.count;
    [self.categories enumerateObjectsUsingBlock:^(Category* _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self imageForCategory:category]) {
            [S3File getDataFromFile:category.imageFile dataBlock:^(NSData *data) {
                if (data) {
                    [self.categoryImages setObject:[UIImage imageWithData:data] forKey:category.objectId];
                }
                if (--count == 0) {
                    NSLog(@"Initialized all Category images...");
                }
            }];
        }
        if (--count == 0) {
            NSLog(@"Initialized all Category images...");
        }
    }];
}

- (void) initializeCategories:(CategorieReadyBlock)categoryBlock andActivities:(ActivitiesReadyBlock)activityBlock
{
    PFQuery *categories = [Category query];
    [categories fromPinWithName:kCategories];
    [categories findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            self.categories = objects;
            categoryBlock();
        }
        else {
            PFQuery *q = [Category query];
            [q findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                self.categories = objects;
                [PFObject pinAllInBackground:objects withName:kCategories block:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        categoryBlock();
                    }
                }];
            }];
        }
    }];
    
    PFQuery *activities = [Activity query];
    [activities fromPinWithName:kActivities];
    [activities findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            self.activities = objects;
            activityBlock();
        }
        else {
            PFQuery *q = [Activity query];
            [q findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                self.activities = objects;
                [PFObject pinAllInBackground:objects withName:kActivities block:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        activityBlock();
                    }
                }];
            }];
        }
    }];
}


@end
