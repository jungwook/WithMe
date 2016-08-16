//
//  User.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PFSubClassing.h"

static NSString* const longStringOfWords = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";

@interface User()
{
    NSInteger __count;
}
@end

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

- (CLLocationCoordinate2D) locationCoordinates
{
    return CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
}

- (CLLocation*) locationCLLocation
{
    return [[CLLocation alloc] initWithLatitude:self.location.latitude longitude:self.location.longitude];
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

//- (void)mediaReady:(VoidBlock)handler
//{
//    __block NSUInteger count = self.media.count;
//    if (count == 0) {
//        if (handler) {
//            handler();
//        }
//    }
//    else {
//        [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull userMedia, NSUInteger idx, BOOL * _Nonnull stop) {
//            [userMedia ready:^{
//                if (--count == 0) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (handler) {
//                            handler();
//                        }
//                    });
//                }
//            }];
//        }];
//    }
//}
//

- (void)profileMediaImageLoaded:(ImageLoadedBlock)block
{
    NSAssert(block != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        [S3File getDataFromFile:self.profileMedia.mediaFile dataBlock:^(NSData *data) {
            block([UIImage imageWithData:data]);
        }];
    }];
}

- (void)profileMediaThumbnailLoaded:(ImageLoadedBlock)block
{
    NSAssert(block != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        [S3File getDataFromFile:self.profileMedia.thumbailFile dataBlock:^(NSData *data) {
            block([UIImage imageWithData:data]);
        }];
    }];
}

- (void)mediaImagesLoaded:(ImageArrayBlock)block
{
    NSAssert(block != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        __block NSInteger count = self.media.count;
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
        
        [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
            [S3File getDataFromFile:media.thumbailFile dataBlock:^(NSData *data) {
                [images addObject:[UIImage imageWithData:data]];
                if (--count == 0) {
                    block(images);
                }
            }];
        }];
        if (count == 0) {
            block(nil);
        }
    }];
}

- (void) fetch:(NSArray*)array named:(NSString*)name handler:(VoidBlock)handler count:(NSInteger)totalCount
{
    __count = totalCount;
    if (array.count>0) {
        NSLog(@"USER %@ - FETCHING %@ OF COUNT:%ld / %ld", self.nickname, name, array.count, __count);
        [PFObject fetchAllIfNeededInBackground:array block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            __count -= objects.count;
            NSLog(@"USER %@ NOW HAS %ld OBJECTS TO FETCH AFTER %@", self.nickname, __count, name);
            if (__count == 0) {
                NSLog(@">>>>>> %@ FETCHED ALL ITEMS", self.nickname);
                handler();
            }
        }];
    }
}

- (void)fetched:(VoidBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        __count = self.media.count + self.likes.count + self.posts.count;
        NSLog(@"FETCHING USER:%@ COUNT:%ld", self.nickname, __count);
        if (__count == 0 && handler) {
            NSLog(@">>>>>> %@ NO ITEMS", self.nickname);
            handler();
            return;
        }
        [self fetch:self.media named:@"MEDIA" handler:handler count:__count];
        [self fetch:self.likes named:@"LIKES" handler:handler count:__count];
        [self fetch:self.posts named:@"POSTS" handler:handler count:__count];
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
    if (self.dataAvailable) {
        __block UserMedia *profileMedia = self.media.firstObject;
        [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
            if (media.isProfileMedia) {
                *stop = YES;
                profileMedia = media;
            }
        }];
        return profileMedia;
    }
    return nil;
}

- (void) clearProfileMedia
{
    [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
        media.isProfileMedia = NO;
    }];
}

- (void) setProfileMedia:(UserMedia*)profileMedia
{
    if ([self.media containsObject:profileMedia]) {
        [self clearProfileMedia];
        profileMedia.isProfileMedia = YES;
        [profileMedia saveInBackground];
    }
    else {
        [self clearProfileMedia];
        profileMedia.isProfileMedia = YES;
        [self addUniqueObject:profileMedia forKey:@"media"];
        [self saved:^{
            [Notifications notify:@"NotifyProfileMediaChanged" object:profileMedia];
        }];
    }
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

//- (void)ready:(VoidBlock)block
//{
//    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//        [S3File getDataFromFile:self.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
//            if (block)
//                block();
//        }];
//    }];
//}

- (void)imageLoaded:(ImageLoadedBlock)block
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [S3File getDataFromFile:self.mediaFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            if (block) {
                block([UIImage imageWithData:data]);
            }
        }];
    }];
}

- (void)thumbnailLoaded:(ImageLoadedBlock)block
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [S3File getDataFromFile:self.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            if (block) {
                block([UIImage imageWithData:data]);
            }
        }];
    }];
}

- (void)fetched:(VoidBlock)handler
{
    if (self.dataAvailable) {
        handler();
    }

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

#pragma mark AdLocation

@implementation AdLocation
@dynamic location, address;

+(NSString *)parseClassName
{
    return @"AdLocation";
}

@end

@interface Ad()
@end

#pragma mark Ad

@implementation Ad
{
    NSInteger __count;
}
@dynamic user, title, activity, payment, intro, media, /*location, address, */ likes, locations, viewedBy, likesCount, viewedByCount;

+ (NSString *)parseClassName
{
    return @"Ad";
}

- (NSString *)address
{
    if (self.locations.count == 1) {
        AdLocation *adLoc = [self.locations firstObject];
        return adLoc.address;
    }
    else if (self.locations.count > 1) {
        return @"Multiple locations";
    }
    else {
        return nil;
    }
}

- (PFGeoPoint*) location
{
    __block double latitude = 0, longitude = 0;
    
    if (!self.locations || self.locations.count == 0) {
        return nil;
    }
    else {
        [self.locations enumerateObjectsUsingBlock:^(AdLocation* _Nonnull adLoc, NSUInteger idx, BOOL * _Nonnull stop) {
            if (adLoc.dataAvailable) {
                latitude+=adLoc.location.latitude;
                longitude+=adLoc.location.longitude;
            }
        }];
        return [PFGeoPoint geoPointWithLatitude:latitude/self.locations.count longitude:longitude/self.locations.count];
    }
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

- (void) fetch:(NSArray*)array named:(NSString*)name handler:(VoidBlock)handler count:(NSInteger)totalCount
{
    __count = totalCount;
    if (array.count>0) {
        NSLog(@"AD %@ - FETCHING %@ OF COUNT:%ld / %ld", self.title, name, array.count, __count);
        [PFObject fetchAllIfNeededInBackground:array block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            __count -= objects.count;
            NSLog(@"Ad %@ NOW HAS %ld OBJECTS TO FETCH AFTER %@", self.title, __count, name);
            if (__count == 0) {
                NSLog(@">>>>>> %@ FETCHED ALL ITEMS", self.title);
                handler();
            }
        }];
    }
}

- (void)fetched:(VoidBlock)handler
{
    __count = self.media.count + self.locations.count + self.likes.count + self.viewedBy.count;

    NSLog(@"FET:%@", self.title);
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSLog(@"INS:%@[%@]", self.title, self.user);
        [self.user fetched:^{
            NSLog(@"USE:%@ [%@]", self.title, self.user.nickname);
            if (__count == 0 && handler) {
                handler();
                return;
            }
            [self fetch:self.media named:@"MEDIA" handler:handler count:__count];
            [self fetch:self.likes named:@"LIKES" handler:handler count:__count];
            [self fetch:self.locations named:@"LOCAS" handler:handler count:__count];
            [self fetch:self.viewedBy named:@"VIEWY" handler:handler count:__count];
        }];
    }];
}

- (void)viewedByUser:(User *)user handler:(VoidBlock)handler
{
    if (![self.viewedBy containsObject:user]) {
        [self addUniqueObject:user forKey:@"viewedBy"];
        self.viewedByCount++;
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

- (void) userProfileMediaLoaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");

    [self fetched:^{
        UserMedia *media = self.user.profileMedia;
        [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
            handler(data ? [UIImage imageWithData:data] : nil);
        }];
    }];
}

- (void) userProfileThumbnailLoaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        UserMedia *media = self.user.profileMedia;
        [S3File getDataFromFile:media.thumbailFile dataBlock:^(NSData *data) {
            handler(data ? [UIImage imageWithData:data] : nil);
        }];
    }];
}

- (void) firstMediaImageLoaded:(ImageLoadedBlock)handler
{
    [self fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [UserMedia fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            UserMedia *media = [self.media firstObject];
            if (media) {
                [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
                    handler(data ? [UIImage imageWithData:data] : nil);
                }];
            }
            else {
                handler(nil);
            }
        }];
    }];
}

- (void) firstThumbnailImageLoaded:(ImageLoadedBlock)handler
{
    [self fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [UserMedia fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            UserMedia *media = [self.media firstObject];
            if (media) {
                [S3File getDataFromFile:media.thumbailFile dataBlock:^(NSData *data) {
                    handler(data ? [UIImage imageWithData:data] : nil);
                }];
            }
            else {
                handler(nil);
            }
        }];
    }];
}


- (void) mediaImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");
    NSAssert(index<self.media.count, @"index must be within range of Ad.media");
    
    [self fetched:^{
        UserMedia *media = [self.media objectAtIndex:index];
        [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
            if (handler) {
                handler(data ? [UIImage imageWithData:data] : nil);
            }
        }];
    }];
}

- (void) thumbnailImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");
    NSAssert(index<self.media.count, @"index must be within range of Ad.media");
    
    [self fetched:^{
        UserMedia *media = [self.media objectAtIndex:index];
        [S3File getDataFromFile:media.thumbailFile dataBlock:^(NSData *data) {
            if (handler) {
                handler(data ? [UIImage imageWithData:data] : nil);
            }
        }];
    }];
}

- (void)mediaImagesLoaded:(ImageArrayBlock _Nonnull)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");

    [self fetched:^{
        __block NSInteger count = self.media.count;
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
        [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
            [S3File getDataFromFile:media.thumbailFile dataBlock:^(NSData *data) {
                UIImage *image = [UIImage imageWithData:data];
                [images addObject:image];
                if (--count == 0) {
                    handler(images);
                }
            }];
        }];
        if (count == 0) {
            handler(nil);
        }
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

