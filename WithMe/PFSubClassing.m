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

- (AdLocation*) adLocation
{
    AdLocation *adLoc = [AdLocation object];
    
    adLoc.location = self.location;
    adLoc.address = self.address;
    adLoc.locationType = kLocationTypeAdhoc;
    
    return adLoc;
}

- (void)profileMediaLoaded:(UserMediaBlock)block
{
    [self fetched:^{
        [PFObject fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            __block UserMedia *profileMedia = self.media.firstObject;
            [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
                if (media.isProfileMedia) {
                    *stop = YES;
                    profileMedia = media;
                }
            }];
            block(profileMedia);
        }];
    }];
}

- (void)profileMediaImageLoaded:(ImageLoadedBlock)block
{
    NSAssert(block != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        [PFObject fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            __block UserMedia *profileMedia = self.media.firstObject;
            [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
                if (media.isProfileMedia) {
                    *stop = YES;
                    profileMedia = media;
                }
            }];
            [profileMedia imageLoaded:^(UIImage *image) {
                block(image);
            }];
        }];
    }];
}

- (void)profileMediaThumbnailLoaded:(ImageLoadedBlock)block
{
    NSAssert(block != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        [PFObject fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            __block UserMedia *profileMedia = self.media.firstObject;
            [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
                if (media.isProfileMedia) {
                    *stop = YES;
                    profileMedia = media;
                }
            }];
            [profileMedia thumbnailLoaded:^(UIImage *image) {
                block(image);
            }];
        }];
    }];
}

- (void)mediaImagesLoaded:(ImageArrayBlock)block
{
    NSAssert(block != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        __block NSInteger count = self.media.count;
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
        [PFObject fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
                [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
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
    }];
}

- (void)fetched:(VoidBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        } else {
            handler();
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
                [Notifications notify:@"NotifyUserSaved" object:self];
                handler();
            }
        }
    }];
}

- (void) clearProfileMedia
{
    [PFObject fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
            media.isProfileMedia = NO;
        }];
    }];
}

- (void) setProfileMedia:(UserMedia*)profileMedia
{
    [PFObject fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
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
    }];
}

- (NSArray *)sortedMedia
{
    NSArray* sorted = [self.media sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isProfileMedia" ascending:NO]]];
    return sorted;
}

@end

@implementation UserMedia
@dynamic userId, comment, mediaType, thumbnailFile, mediaFile, mediaSize, isRealMedia, isProfileMedia;

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
        [S3File getDataFromFile:self.thumbnailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            if (block) {
                block([UIImage imageWithData:data]);
            }
        }];
    }];
}

- (void)fetched:(VoidBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        } else {
            handler();
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
                [Notifications notify:@"NotifyUserMediaSaved" object:self];
                handler();
            }
        }
    }];
}

@end


@interface Ad()
@end

#pragma mark Ad

@implementation Ad
{
    NSInteger __count;
}
@dynamic user, title, activity, payment, intro, media, /*location, address, */ likes, locations, viewedBy, likesCount, viewedByCount, ourParticipants, yourParticipants;

+ (NSString *)parseClassName
{
    return @"Ad";
}

- (void)location:(LocationBlock)handler
{
    
    [PFObject fetchAllIfNeededInBackground:self.locations block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __block double latitude = 0, longitude = 0;
        if (self.locations.count != 0) {
            [self.locations enumerateObjectsUsingBlock:^(AdLocation* _Nonnull adLoc, NSUInteger idx, BOOL * _Nonnull stop) {
                if (adLoc.dataAvailable) {
                    latitude+=adLoc.location.latitude;
                    longitude+=adLoc.location.longitude;
                }
            }];
            handler([PFGeoPoint geoPointWithLatitude:latitude/self.locations.count longitude:longitude/self.locations.count]);
        }
    }];
}

- (void)address:(AddressBlock)handler
{
    [PFObject fetchAllIfNeededInBackground:self.locations block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (self.locations.count == 1) {
            AdLocation *adLoc = [self.locations firstObject];
            handler(adLoc.address);
        }
        else if (self.locations.count > 1) {
            handler(@"Multiple locations");
        }
        else {
            handler(nil);
        }
    }];
}

- (UIColor*) paymentTypeColor
{
    switch (self.payment) {
        case kPaymentTypeNone:
            return [UIColor colorWithRed:31/255.f green:101/255.f blue:102/255.f alpha:1.0f];
        case kPaymentTypeIBuy:
            return [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f];
        case kPaymentTypeYouBuy:
            return [UIColor colorWithRed:167/255.f green:229/255.f blue:95/255.f alpha:1.0f];
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

- (void)addLocation:(AdLocation *)location
{
    if (location) {
        [self addUniqueObject:location forKey:@"locations"];
    }
}

- (void)removeLocation:(AdLocation *)location
{
    if (location) {
        [self removeObject:location forKey:@"locations"];
    }
}

- (void)fetched:(VoidBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        } else {
            handler();
        }
    }];
}

- (void)viewedByUser:(User *)user handler:(VoidBlock)handler
{
    [PFObject fetchAllIfNeededInBackground:self.viewedBy block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
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
    }];
}

- (void)likedByUser:(User *)user handler:(VoidBlock)handler
{
    [PFObject fetchAllIfNeededInBackground:self.likes block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
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
    }];
}

- (void) unlikedByUser:(User *)user handler:(VoidBlock)handler
{
    [PFObject fetchAllIfNeededInBackground:self.likes block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
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
    }];
}

- (void) userProfileMediaLoaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");

    [self fetched:^{
        [self.user fetched:^{
            [self fetched:^{
                [self.user profileMediaImageLoaded:^(UIImage *image) {
                    handler(image);
                }];
            }];
        }];
    }];
}

- (void) userProfileThumbnailLoaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");
    
    [self fetched:^{
        [self.user fetched:^{
            [self fetched:^{
                [self.user profileMediaThumbnailLoaded:^(UIImage *image) {
                    handler(image);
                }];
            }];
        }];
    }];
}

- (void) firstMediaImageLoaded:(ImageLoadedBlock)handler
{
    [self fetched:^{
        UserMedia *media = [self.media firstObject];
        if (media) {
            [media fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
                    handler(data ? [UIImage imageWithData:data] : nil);
                }];
            }];
        }
        else {
            handler(nil);
        }
    }];
}

- (void) firstThumbnailImageLoaded:(ImageLoadedBlock)handler
{
    [self fetched:^{
        UserMedia *media = [self.media firstObject];
        if (media) {
            [media fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
                    handler(data ? [UIImage imageWithData:data] : nil);
                }];
            }];
        }
        else {
            handler(nil);
        }
    }];
}


- (void) mediaImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");
    NSAssert(index<self.media.count, @"index must be within range of Ad.media");
    
    [self fetched:^{
        UserMedia *media = [self.media objectAtIndex:index];
        [media fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
                if (handler) {
                    handler(data ? [UIImage imageWithData:data] : nil);
                }
            }];
        }];
    }];
}

- (void) thumbnailImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");
    NSAssert(index<self.media.count, @"index must be within range of Ad.media");
    
    [self fetched:^{
        UserMedia *media = [self.media objectAtIndex:index];
        [media fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
                if (handler) {
                    handler(data ? [UIImage imageWithData:data] : nil);
                }
            }];
        }];
    }];
}

- (void)mediaImagesLoaded:(ImageArrayBlock _Nonnull)handler
{
    NSAssert(handler != nil, @"Must provide an ImageLoadedBlock handler");

    [self fetched:^{
        __block NSInteger count = self.media.count;
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
        [PFObject fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
                [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
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
    }];
}

@end

#pragma mark Category

@implementation Category
@dynamic name, intro, imageFile, activities;

+ (NSString *)parseClassName
{
    return @"Category";
}
@end

#pragma mark Activity

@implementation Activity
@dynamic name, intro, imageFile, category;

+ (NSString *)parseClassName
{
    return @"Activity";
}

@end

#pragma mark AdLocation

@implementation AdLocation
@dynamic location, address, locationType, thumbnailFile, latitudeDelta, longitudeDelta;

+(NSString *)parseClassName
{
    return @"AdLocation";
}

- (void) updateWithNewLocation:(PFGeoPoint*)location
                          span:(MKCoordinateSpan)span
                      pinColor:(UIColor *)pinColor
                          size:(CGSize)size
                    completion:(AdLocationBlock)createdBlock
{
    self.location = location;
    self.span = span;
    
    getAddressForPFGeoPoint(self.location, ^(NSString *address) {
        self.address = address;
        [self mapImageWithPinColor:pinColor size:size handler:^(UIImage *image) {
            self.thumbnailFile = [S3File saveMapImage:image];
            if (createdBlock) {
                createdBlock(self);
            }
        }];
    });
}

+ (instancetype) adLocationWithLocation:(PFGeoPoint*)location
                                   span:(MKCoordinateSpan)span
                               pinColor:(UIColor *)pinColor
                                   size:(CGSize)size
                             completion:(AdLocationBlock)createdBlock
{
    AdLocation *adLoc = [AdLocation object];
    adLoc.location = location;
    adLoc.span = span;
    
    getAddressForPFGeoPoint(location, ^(NSString *address) {
        adLoc.address = address;
        [adLoc mapImageWithPinColor:pinColor size:size handler:^(UIImage *image) {
            adLoc.thumbnailFile = [S3File saveMapImage:image];
            if (createdBlock) {
                createdBlock(adLoc);
            }
        }];
    });
    
    return adLoc;
}

+ (instancetype) adLocationWithLocation:(PFGeoPoint*)location
                           spanInMeters:(CGFloat)span
                               pinColor:(UIColor *)pinColor
                                   size:(CGSize)size
                             completion:(AdLocationBlock)createdBlock
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.latitude, location.longitude), span, span);
    
    AdLocation *adLoc = [AdLocation object];
    adLoc.location = location;
    adLoc.span = region.span;
    
    getAddressForPFGeoPoint(location, ^(NSString *address) {
        adLoc.address = address;
        [adLoc mapImageWithPinColor:pinColor size:size handler:^(UIImage *image) {
            adLoc.thumbnailFile = [S3File saveMapImage:image];
            if (createdBlock) {
                createdBlock(adLoc);
            }
        }];
    });
    
    return adLoc;
}

- (MKCoordinateSpan) span
{
    if (self.latitudeDelta == 0 || self.longitudeDelta == 0) {
        return MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude), 2500, 2500).span;
    }
    else {
        return MKCoordinateSpanMake(self.latitudeDelta, self.longitudeDelta);
    }
}

- (void)setSpan:(MKCoordinateSpan)span
{
    self.latitudeDelta = span.latitudeDelta;
    self.longitudeDelta = span.longitudeDelta;
}

- (void)setSpanInMeters:(CGFloat)meters
{
    [self setSpan:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude), meters, meters).span];
}

- (CLLocationCoordinate2D)coordinates
{
    return CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
}

- (void)setCoordinates:(CLLocationCoordinate2D)coordinates
{
    self.location = [PFGeoPoint geoPointWithLatitude:coordinates.latitude longitude:coordinates.longitude];
}

- (void)updateWithNewLocation:(PFGeoPoint *)location
                     pinColor:(UIColor *)pinColor
                         size:(CGSize)size
                   completion:(AdLocationBlock)createdBlock
{
    self.location = location;
    
    getAddressForPFGeoPoint(self.location, ^(NSString *address) {
        self.address = address;
        [self mapImageWithPinColor:pinColor size:size handler:^(UIImage *image) {
            self.thumbnailFile = [S3File saveMapImage:image];
            if (createdBlock) {
                createdBlock(self);
            }
        }];
    });
}

- (void) mapImageWithPinColor:(UIColor *)pinColor
                              size:(CGSize)size
                           handler:(ImageLoadedBlock)block
{
    MKCoordinateRegion region = MKCoordinateRegionMake(self.coordinates, self.span);
    [self mapImageUsingRegion:region pinColor:pinColor size:size handler:block];
}

- (void) mapImageUsingRegion:(MKCoordinateRegion)region
                              pinColor:(UIColor*)pinColor
                                  size:(CGSize)size
                                    handler:(ImageLoadedBlock)block
{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = size;
    
    CGFloat mw = MAX(MIN(size.width, size.height) / 10, 20);
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (snapshot.image) {
                if (block) {
                    block([self mapImage:snapshot.image usingPinNamed:@"location" width:mw color:pinColor]);
                }
            }
        });
    }];
}


- (UIImage*) pinNamed:(NSString*)name colored:(UIColor*)color imageWidth:(CGFloat)width
{
    UIImage *newImage = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    CGSize size = CGSizeMake(width, width*newImage.size.height/newImage.size.width);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale); {
        [color set];
        [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)mapImage:(UIImage*)image usingPinNamed:(NSString*)name width:(CGFloat)width color:(UIColor *)color
{
    CGPoint point = CGPointMake(image.size.width/2, image.size.height/2);
    
    UIImage *pinImage = [self pinNamed:name colored:color imageWidth:width];
    UIImage *compositeImage = nil;
    UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
    {
        [image drawAtPoint:CGPointZero];
        
        CGRect visibleRect = CGRectMake(0, 0, image.size.width, image.size.height);
        if (CGRectContainsPoint(visibleRect, point)) {
            point.x = point.x - (pinImage.size.width / 2.0f);
            point.y = point.y - (pinImage.size.height);
            [pinImage drawAtPoint:point];
        }
        compositeImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return compositeImage;
}


@end
