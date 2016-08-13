//
//  User.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PFSubClassing.h"

static NSString* const longStringOfWords = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";


@implementation User
@dynamic nickname,location,locationUdateAt, address, gender, age, withMe, introduction, media, likes, posts;

+ (instancetype) me
{
    return [User currentUser];
}

- (void) removeMe
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UNIQUEDEVICEID"];
    if ([User me]) {
        [[User me] delete];
        [User logOut];
    }
}

+ (NSString*) uniqueUsername
{
    NSString *cudid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UNIQUEDEVICEID"];
    NSString *idString;
    if (cudid) {
        idString = cudid;
    }
    else {
        idString = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        [[NSUserDefaults standardUserDefaults] setObject:idString forKey:@"UNIQUEDEVICEID"];
    }
    
    return idString;
}

- (void)setGenderTypeFromString:(NSString *)gender
{
    id info = [User genderInfo];
    
    NSNumber *ret = info[gender];
    if (ret) {
        self.gender = [ret integerValue];
    }
    else {
        self.gender = kGenderTypeUnknown;
    }
}

+ (NSDictionary*) genderInfo
{
    return @{
                @"Male" : @(kGenderTypeMale),
                @"Female" : @(kGenderTypeFemale),
                @"Gay" : @(kGenderTypeMaleGay),
                @"Lesbian" : @(kGenderTypeFemaleLesbian),
                @"Male Bisexual" : @(kGenderTypeMaleBi),
                @"Female Bisexual" : @(kGenderTypeFemaleBi),
                };
}

+ (NSArray *)genders
{
    return @[
             @"Male",
             @"Female",
             @"Gay",
             @"Lesbian",
             @"Male Bisexual",
             @"Female Bisexual",
             ];
}

+ (NSArray*) ageGroups
{
    return @[
                @"Child",
                @"20s",
                @"30s",
                @"40s",
                @"Senior",
             ];
}

+ (NSArray*) withMes
{
    return @[
             @"Meet",
             @"Flirt",
             @"Vacation",
             @"Drive",
             @"Ride",
             @"Chat",
             @"Drink",
             @"Lunch",
             @"Dinner",
             @"Picknick",
             @"Work",
             @"Watch a movie",
             @"Make Love",
             ];
}

+ (void) diveIntoCategories:(NSArray*)categories usingSet:(NSMutableSet*)ecats
{
    [categories enumerateObjectsUsingBlock:^(id _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([category isKindOfClass:[NSString class]]) {
            [ecats addObject:category];
        }
        else {
            [User diveIntoCategories:category[@"content"] usingSet:ecats];
        }
    }];
}

+ (NSArray*) endCategories
{
    NSMutableSet *ecats = [NSMutableSet set];
    [User diveIntoCategories:[User categories] usingSet:ecats];
    return [ecats allObjects];
}

+ (UIColor*) categoryColorForEndCategory:(NSString*)endCategory
{
    __block UIColor *ret;
    
    NSArray *categories = [User categories];
    [categories enumerateObjectsUsingBlock:^(id  _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![category isKindOfClass:[NSString class]])
        {
            if ([User diveIntoCategories:category[@"content"] forEndCategory:endCategory]) {
                ret = category[@"color"];
                *stop = YES;
            }
        }
    }];
    return ret;
}

+ (NSString*) categoryForEndCategory:(NSString*)endCategory
{
    __block NSString *ret;
    
    NSArray *categories = [User categories];
    [categories enumerateObjectsUsingBlock:^(id  _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![category isKindOfClass:[NSString class]])
        {
            if ([User diveIntoCategories:category[@"content"] forEndCategory:endCategory]) {
                ret = category[@"title"];
                *stop = YES;
            }
        }
    }];
    return ret;
}

+ (BOOL) diveIntoCategories:(NSArray*)categories forEndCategory:(NSString*)endCategory
{
    __block BOOL ret = NO;
    
    [categories enumerateObjectsUsingBlock:^(id  _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([category isKindOfClass:[NSString class]]) {
            ret = [category isEqualToString:endCategory];
            *stop = ret;
        }
        else {
            ret = [User diveIntoCategories:category[@"content"] forEndCategory:endCategory];
            *stop = ret;
        }
    }];
    return ret;
}

+ (NSArray*) categories
{
    return @[
             @{
                 @"title" : @"Eat/Drink",
                 @"color" : [UIColor colorWithRed:0.3 green:0.7 blue:0 alpha:1.0],
                 @"content" : @[
                         @"Dinner",
                         @"Lunch",
                         @"Breakfast",
                         @"Brunch",
                         @"Coffee & tea",
                         @"Beer",
                         @"Light drinks",
                         @"Heavy drinks",
                         @"Other events",
                         ],
                 },
             @{
                 @"title": @"Flirt/Date",
                 @"color" : [UIColor colorWithRed:0 green:0.8 blue:0 alpha:1.0],
                 @"content" : @[
                         @"Blind Date",
                         @"Movies",
                         @"Drive",
                         @"Ride",
                         @"Holiday",
                         @"Chat",
                         @"Talk",
                         @"Other meets",
                         ],
                 },
             @{
                 @"title": @"Work",
                 @"color" : [UIColor colorWithRed:0 green:0.8 blue:0.3 alpha:1.0],
                 @"content" : @[
                         @"Consult",
                         @"Design",
                         @"Code",
                         @"Mentor / Advise",
                         @"Legal advise",
                         @"Other collaborations",
                         ],
                 },
             @{
                 @"title": @"Learn",
                 @"color" : [UIColor colorWithRed:100/255. green:1.0 blue:100/255. alpha:1.0],
                 @"content" : @[
                         @"Music & Instruments",
                         @"Arts",
                         @"School stuff",
                         @"Knitting",
                         @"Flowers",
                         @"Other activities",
                         ],
                 },
             @{
                 @"title": @"Play/Sports",
                 @"color" : [UIColor colorWithRed:102/255. green:205/255. blue:255/255. alpha:1.0],
                 @"content" : @[
                         @"Golf",
                         @"Billiards",
                         @"Tennis",
                         @"Basketball",
                         @"Ski & snowboard",
                         @"Water sports",
                         @"Fishing",
                         @"Rafting",
                         @"Other sports",
                         ],
                 },
             @{
                 @"title": @"Workout",
                 @"color" : [UIColor colorWithRed:0/255. green:128/255. blue:255/255. alpha:1.0],
                 @"content" : @[
                         @"Run / Jog",
                         @"Walk / Hike",
                         @"Health & Body building",
                         @"Cylce",
                         @"Rock climing",
                         @"Swimming",
                         @"Other workouts",
                         ],
                 },
             @{
                 @"title": @"Share",
                 @"color" : [UIColor colorWithRed:0/255. green:128/255. blue:128/255. alpha:1.0],
                 @"content" : @[
                         @"Car pool",
                         @"Taxi",
                         @"Room",
                         @"Other shares",
                         ],
                 },
             @{
                 @"title": @"Play/Games",
                 @"color" : [UIColor colorWithRed:255/255. green:128/255. blue:0/255. alpha:1.0],
                 @"content" : @[
                         @"Poker",
                         @"Go",
                         @"Chess",
                         @"Board games",
                         @"Hwatu",
                         @"Computer games",
                         @"Other games",
                         ],
                 },
             @{
                 @"title": @"Trade/Buy/Sell",
                 @"color" : [UIColor colorWithRed:255/255. green:204/255. blue:102/255. alpha:1.0],
                 @"content" : @[
                         @"Car",
                         @"Motorcycle",
                         @"Bicycle",
                         @"Segway",
                         @"Other machines",
                         @"Errands",
                         @"Cooking",
                         @"Cleaning",
                         @"Delivery",
                         @"Other services",
                         @"Apartment",
                         @"Officetel",
                         @"Office space",
                         @"House",
                         @"Other realestate",
                         @"Electronics",
                         @"Toys",
                         @"Other goods",
                         ],
                 },
             @{
                 @"title": @"Other stuff",
                 @"color" : [UIColor colorWithRed:102/255. green:102/255. blue:255/255. alpha:1.0],
                 @"content" : @[
                         @"etc",
                         ],
                 },
             ];
}

- (NSString *)genderTypeString
{
    switch (self.gender) {
        case kGenderTypeMale:
            return @"Male";
        case kGenderTypeFemale:
            return @"Female";
        case kGenderTypeMaleGay:
            return @"Gay";
        case kGenderTypeFemaleLesbian:
            return @"Lesbian";
        case kGenderTypeMaleBi:
            return @"Male Bisexual";
        case kGenderTypeFemaleBi:
            return @"Female Bisexual";
        case kGenderTypeUnknown:
            return @"Unknown";
    }
}

- (NSString*) genderCode
{
    switch (self.gender) {
        case kGenderTypeMale:
            return @"M";
        case kGenderTypeFemale:
            return @"F";
        case kGenderTypeMaleGay:
            return @"G";
        case kGenderTypeFemaleLesbian:
            return @"L";
        case kGenderTypeMaleBi:
            return @"MB";
        case kGenderTypeFemaleBi:
            return @"FB";
        case kGenderTypeUnknown:
            return @"??";
    }
}

- (void) setLocation:(PFGeoPoint *)location
{
    [self setObject:location forKey:@"location"];
    [self setObject:[NSDate date] forKey:@"locationUpdatedAt"];
    [self saveInBackground];
}

- (UIColor*) genderColor
{
    switch (self.gender) {
        case kGenderTypeMale:
            return [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f];
        case kGenderTypeFemale:
            return [UIColor colorWithRed:240/255.f green:82/255.f blue:10/255.f alpha:1.0f];
        case kGenderTypeMaleGay:
            return [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f];
        case kGenderTypeFemaleLesbian:
            return [UIColor colorWithRed:240/255.f green:82/255.f blue:10/255.f alpha:1.0f];
        case kGenderTypeMaleBi:
            return [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f];
        case kGenderTypeFemaleBi:
            return [UIColor colorWithRed:240/255.f green:82/255.f blue:10/255.f alpha:1.0f];
        case kGenderTypeUnknown:
            return [UIColor colorWithRed:128/255.f green:128/255.f blue:128/255.f alpha:1.0f];
    }
}

- (BOOL)isMe
{
    return ([self.objectId isEqualToString:[User me].objectId]);
}

- (void)mediaReady:(VoidBlock)handler
{
    __block NSUInteger count = self.media.count;
    if (count == 0) {
        if (handler) {
            handler();
        }
    }
    else {
        [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull userMedia, NSUInteger idx, BOOL * _Nonnull stop) {
            [userMedia ready:^{
                if (--count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (handler) {
                            handler();
                        }
                    });
                }
            }];
        }];
    }
}

- (void)mediaFetched:(VoidBlock)handler
{
    __block NSUInteger count = self.media.count;
    if (count == 0) {
        if (handler) {
            handler();
        }
    }
    else {
        [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull userMedia, NSUInteger idx, BOOL * _Nonnull stop) {
            [userMedia fetched:^{
                if (--count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (handler) {
                            handler();
                        }
                    });
                }
            }];
        }];
    }
}

- (void)fetched:(VoidBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        else {
            [self mediaFetched:handler];
        }
    }];
}

- (void)saved:(VoidBlock)handler
{
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        else {
            if (handler) {
                handler();
            }
        }
    }];
}

- (UserMedia *)profileMedia
{
    __block UserMedia *profileMedia = self.media.firstObject;
    [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
        if (media.isProfileMedia) {
            *stop = YES;
            profileMedia = media;
        }
    }];
    return profileMedia;
}

- (void) setProfileMedia:(UserMedia*)profileMedia
{
    [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
        media.isProfileMedia = NO;
    }];
    
    profileMedia.isProfileMedia = YES;
    [self addUniqueObject:profileMedia forKey:@"media"];
    [self saved:^{
        [Notifications notify:@"NotifyProfileMediaChanged" object:profileMedia];
    }];
}

- (NSArray *)sortedMedia
{
    NSArray* sorted = [self.media sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isProfileMedia" ascending:NO]]];
    return sorted;
}

@end

@implementation UserMedia
@dynamic userId, comment, mediaType, thumbailFile, mediaFile, mediaSize, isRealMedia, isProfileMedia;

+ (NSString *)parseClassName {
    return @"UserMedia";
}

- (void)setMediaSize:(CGSize)mediaSize
{
    [self setObject:@(mediaSize.width) forKey:@"mediaWidth"];
    [self setObject:@(mediaSize.height) forKey:@"mediaHeight"];
}

- (CGSize)mediaSize
{
    return CGSizeMake([[self objectForKey:@"mediaWidth"] floatValue], [[self objectForKey:@"mediaHeight"] floatValue]);
}

- (void)ready:(VoidBlock)block
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [S3File getDataFromFile:self.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            if (block)
                block();
        }];
    }];
}

- (void)fetched:(VoidBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        else {
            if (handler) {
                handler();
            }
        }
    }];
}


- (void)saved:(VoidBlock)handler
{
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        else {
            if (handler) {
                handler();
            }
        }
    }];
}

@end

@interface Ad()
@property (retain)  NSArray     *likes;
@end

@implementation Ad
@dynamic user, title, activity, payment, location, intro, media, address, likes, likesCount;

+ (NSString *)parseClassName
{
    return @"Ad";
}

- (UIColor*) paymentTypeColor
{
    switch (self.payment) {
        case kPaymentTypeNone:
            return [UIColor colorWithRed:128/255.f green:128/255.f blue:128/255.f alpha:1.0f];
        case kPaymentTypeIBuy:
            return [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f];
        case kPaymentTypeYouBuy:
            return [UIColor colorWithRed:240/255.f green:82/255.f blue:10/255.f alpha:1.0f];
        case kPaymentTypeDutch:
            return [UIColor colorWithRed:240/255.f green:82/255.f blue:10/255.f alpha:1.0f];
    }
}

- (NSString *)paymentTypeString
{
    switch (self.payment) {
        case kPaymentTypeNone:
            return @"TBD";
        case kPaymentTypeIBuy:
            return @"I PAY";
        case kPaymentTypeYouBuy:
            return @"BUY ME";
        case kPaymentTypeDutch:
            return @"DUTCH";
    }
}

- (void)mediaAndUserReady:(VoidBlock)handler
{
    __block NSUInteger count = self.media.count;
    [self.user fetched:^{
        if (count == 0) {
            if (handler) {
                handler();
            }
        }
        else {
            [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull userMedia, NSUInteger idx, BOOL * _Nonnull stop) {
                [userMedia ready:^{
                    if (--count == 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (handler) {
                                handler();
                            }
                        });
                    }
                }];
            }];
        }
    }];
}

- (void)likedByUser:(User *)user handler:(VoidBlock)handler
{
    if (![self.likes containsObject:user]) {
        [self addUniqueObject:user forKey:@"likes"];
        self.likesCount++;
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
            else {
                if (handler) {
                    handler();
                }
            }
        }];
    }
    else {
        if (handler) {
            handler();
        }
    }
}

- (void) unlikedByUser:(User *)user handler:(VoidBlock)handler
{
    if ([self.likes containsObject:user]) {
        [self removeObject:user forKey:@"likes"];
        self.likesCount--;
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
            else {
                if (handler) {
                    handler();
                }
            }
        }];
    }
    else {
        if (handler) {
            handler();
        }
    }
}


+ (void) randomnizeAdAndSaveInBackgroundOfCount:(NSUInteger)count
{
    PFQuery *usersQuery = [User query];
    
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (int i=0; i<count; i++) {
            [Ad randomnizeAdUsingUsers:objects index:i];
        }
    }];
}

+ (void) randomnizeAdUsingUsers:(NSArray*)users index:(NSUInteger)index
{
    WithMe *me = [WithMe new];
    
    User *user = [users objectAtIndex:(arc4random()%users.count)];
    NSUInteger numberOfMedia = 1+ arc4random()%3;
    UIImage *images[] = {
        [UIImage imageNamed:@"image0"],
        [UIImage imageNamed:@"image1"],
        [UIImage imageNamed:@"image2"],
        [UIImage imageNamed:@"image3"],
        [UIImage imageNamed:@"image4"],
        [UIImage imageNamed:@"image5"],
        [UIImage imageNamed:@"image6"],
        [UIImage imageNamed:@"image7"],
        [UIImage imageNamed:@"image8"],
        [UIImage imageNamed:@"image9"]
    };
    
    Ad *ad = [Ad object];
    ad.user = user;
    
    static NSUInteger countMedia;
    countMedia = numberOfMedia;
    
    for (int i=0; i<numberOfMedia; i++) {
        UIImage *image = images[arc4random()%10];
        
        UserMedia *media = [UserMedia object];
        media.userId = user.objectId;
        
        NSData *imageData = UIImageJPEGRepresentation(image, kJPEGCompressionFull);
        NSData *thumbnailData = compressedImageData(imageData, kThumbnailWidth);

        NSString *thumbnailFilename = [S3File saveImageData:thumbnailData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
            NSLog(@"THUMB:%@ SAVED", file);
        }];
        NSString *imageFilename = [S3File saveImageData:imageData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
            NSLog(@"IMAGE:%@ SAVED", file);
        }];
        
        media.thumbailFile = thumbnailFilename;
        media.mediaFile = imageFilename;

        media.mediaType = kMediaTypePhoto;
        media.mediaSize = image.size;
        media.isRealMedia = NO;
        media.isProfileMedia = NO;
        
        [media saveInBackground];
        [ad addUniqueObject:media forKey:@"media"];
    }
    ad.payment = (PaymentType) arc4random()%4;
    ad.intro = [Ad wordsFromString:longStringOfWords numberOfWords:10+arc4random()%60];
    ad.title = [Ad wordsFromString:longStringOfWords numberOfWords:3+arc4random()%3];
    ad.activity = [me.activities objectAtIndex:arc4random()%me.activities.count];
    
    NSLog(@"Saving Ad(%ld)", index);
    [ad saveInBackground];
}

+ (NSString*) wordsFromString:(NSString*)string numberOfWords:(NSInteger)nWords
{
    NSRange wordRange = NSMakeRange(0, nWords);
    
    NSCharacterSet *delimiterCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *firstWords = [[string componentsSeparatedByCharactersInSet:delimiterCharacterSet] subarrayWithRange:wordRange];
    return [[firstWords componentsJoinedByString:@" "] stringByAppendingString:@"."];
}

+ (void) resetTitles
{
    PFQuery *query = [Ad query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable ads, NSError * _Nullable error) {
        [ads enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            ad.title = [Ad wordsFromString:longStringOfWords numberOfWords:3+arc4random()%3];
            [ad saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                NSLog(@"Ad saved:%ld", idx);
            }];
        }];
    }];
}

@end

@implementation Category
@dynamic name, intro, imageFile, activities;

+ (NSString *)parseClassName
{
    return @"Category";
}
@end

@implementation Activity
@dynamic name, intro, imageFile, category;

+ (NSString *)parseClassName
{
    return @"Activity";
}

@end

