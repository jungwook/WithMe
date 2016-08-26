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
@end

@implementation User
@dynamic nickname,location,locationUdateAt, address, gender, age, withMe, introduction, media, likes, viewed, posts;

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

- (NSString *)initials
{
    NSMutableString *result = [NSMutableString string];
    [[self.nickname componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(obj){
            [result appendString:[((NSString *)obj) substringToIndex:1]];
        }
    }];
    return [[result substringToIndex:MIN(result.length, 2)] uppercaseString];
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
            if (count == 0) {
                block(nil);
            }
            else {
                [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
                    [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
                        [images addObject:[UIImage imageWithData:data]];
                        if (--count == 0) {
                            block(images);
                        }
                    }];
                }];
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
                [Notifications notify:kNotifyUserSaved object:self];
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
                [Notifications notify:kNotifyProfileMediaChanged object:profileMedia];
            }];
        }
    }];
}

- (NSArray *)sortedMedia
{
    NSArray* sorted = [self.media sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isProfileMedia" ascending:NO]]];
    return sorted;
}

- (void) viewedAd:(Ad*) ad
{
    [self addUniqueObject:ad forKey:@"viewed"];
    [self saved:^{
        [Notifications notify:kNotifyUserViewedAd object:ad];
    }];
}

- (void) likesAd:(Ad*) ad
{
    [self addUniqueObject:ad forKey:@"likes"];
    [self saved:^{
        [Notifications notify:kNotifyUserLikesAd object:ad];
    }];
}

- (void) unlikesAd:(Ad*) ad
{
    __block Ad *adToRemoveFromLikes = nil;
    [self.likes enumerateObjectsUsingBlock:^(Ad* _Nonnull like, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([like.objectId isEqualToString:ad.objectId]) {
            *stop = YES;
            adToRemoveFromLikes = like;
        }
    }];
    
    if (adToRemoveFromLikes) {
        [self removeObject:adToRemoveFromLikes forKey:@"likes"];
        [self saved:^{
            [Notifications notify:kNotifyUserUnlikesAd object:ad];
        }];
    }
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
@dynamic user, title, activity, payment, intro, media, eventDate, likes, location, adLocation, viewedBy, likesCount, viewedByCount, ourParticipants, yourParticipants;

+ (NSString *)parseClassName
{
    return @"Ad";
}

- (BOOL)isMine
{
    return self.user.isMe;
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

- (void)addMedia:(UserMedia*)media
{
    if (media) {
        [self addUniqueObject:media forKey:@"media"];
    }
}

- (void) removeMedia:(UserMedia*)media
{
    if (media) {
        [self removeObject:media forKey:@"media"];
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
        self.viewedByCount = self.viewedBy.count;
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
        self.likesCount = self.likes.count;
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
            self.likesCount = self.likes.count;
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
            [self.user profileMediaThumbnailLoaded:^(UIImage *image) {
                handler(image);
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
            if (count == 0) {
                handler(nil);
            }
            else {
                [self.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
                    [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
                        UIImage *image = [UIImage imageWithData:data];
                        [images addObject:image];
                        if (--count == 0) {
                            handler(images);
                        }
                    }];
                }];
            }
        }];
    }];
}

///////////////////////////////////////////////////////////



+ (void) randomlyCreateOneAd
{
    NSArray *users = [Ad usersWithProfileMedia];
    NSArray *media = [Ad userMedia];
    NSArray *activities = [WithMe new].activities;
    
    Ad *ad = [Ad object];
    ad.title = [Ad sentence:3+arc4random()%10];
    ad.intro = [Ad sentence:30+arc4random()%30];
    ad.user = [users objectAtIndex:arc4random()%users.count];
    ad.activity = [activities objectAtIndex:arc4random()%activities.count];
    
    [ad addObjectsFromArray:[Ad itemsFromArray:media count:10] forKey:@"media"];
    [ad addObjectsFromArray:[Ad itemsFromArray:users count:1+arc4random()%30] forKey:@"viewedBy"];
    [ad addObjectsFromArray:[Ad itemsFromArray:users count:1+arc4random()%30] forKey:@"likes"];
    
    AdLocation *adLoc = [AdLocation object];
    CGFloat ranLat = 0.1*((arc4random()%1000)-500)/1000.0;
    CGFloat ranLng = 0.1*((arc4random()%1000)-500)/1000.0;
    adLoc.location = [PFGeoPoint geoPointWithLatitude:37.520884+ranLat longitude:127.028360+ranLng];
    
    getAddressForPFGeoPoint(adLoc.location, ^(NSString *address) {
        adLoc.address = address;
        [adLoc setSpanInMeters:1000 + arc4random()%2000];
        adLoc.comment = @"Simulated Location";
        
        ad.adLocation = adLoc;

        ad.ourParticipants = 1+arc4random()%3;
        ad.yourParticipants = 1+arc4random()%5;
        ad.payment = arc4random()%4;
        ad.likesCount = ad.likes.count;
        ad.viewedByCount = ad.viewedBy.count;
        
        [ad saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"new add created %ssuccessfully %@", succeeded ? "" : "UN", error ? error.localizedDescription : @"");
        }];
    });
}

+ (NSArray*)itemsFromArray:(NSArray *)array count:(NSInteger)count
{
    NSMutableArray *toAdd = [NSMutableArray array];
    for (int i=0; i<count; i++) {
        [toAdd addObject:[array objectAtIndex:arc4random()%(array.count)]];
    }
    return toAdd;
}

+ (NSArray*) adLocations
{
    static NSArray *ret = nil;
    if (!ret) {
        PFQuery *query = [AdLocation query];
        ret = [query findObjects];
        NSLog(@"LOADED ALL LOCATIONS");
    }
    return ret;
}

+ (NSArray*) userMedia
{
    static NSArray *ret = nil;
    if (!ret) {
        PFQuery *query = [UserMedia query];
        ret = [query findObjects];
        NSLog(@"LOADED ALL MEDIA");
    }
    return ret;
}

+ (NSArray*) usersWithProfileMedia
{
    static NSMutableArray *ret = nil;
    if (!ret) {
        ret = [NSMutableArray array];
        PFQuery *query = [User query];
        NSArray <User *> *users = [query findObjects];
        [users enumerateObjectsUsingBlock:^(User * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"LOADED ALL USERS");
            if (obj.media.count>0) {
                [ret addObject:obj];
            }
        }];
    }
    return ret;
}

+ (NSString*) sentence:(NSInteger) nWords
{
    NSRange wordRange = NSMakeRange(0, nWords);
    NSArray *firstWords = [[longStringOfWords componentsSeparatedByString:@" "] subarrayWithRange:wordRange];
    return [[firstWords componentsJoinedByString:@" "] stringByAppendingString:@"."];
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
@dynamic location, address, locationType, thumbnailFile, comment, latitudeDelta, longitudeDelta;

+(NSString *)parseClassName
{
    return @"AdLocation";
}

- (void)fetched:(VoidBlock)block
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (block) {
            block();
        }
    }];
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



//+ (NSArray*) categories
//{
//    return @[
//             @{
//                 @"title" : @"Eat/Drink",
//                 @"color" : [UIColor colorWithRed:0.3 green:0.7 blue:0 alpha:1.0],
//                 @"content" : @[
//                         @"Dinner",
//                         @"Lunch",
//                         @"Breakfast",
//                         @"Brunch",
//                         @"Coffee & tea",
//                         @"Beer",
//                         @"Light drinks",
//                         @"Heavy drinks",
//                         @"Other events",
//                         ],
//                 },
//             @{
//                 @"title": @"Flirt/Date",
//                 @"color" : [UIColor colorWithRed:0 green:0.8 blue:0 alpha:1.0],
//                 @"content" : @[
//                         @"Blind Date",
//                         @"Movies",
//                         @"Drive",
//                         @"Ride",
//                         @"Holiday",
//                         @"Chat",
//                         @"Talk",
//                         @"Other meets",
//                         ],
//                 },
//             @{
//                 @"title": @"Work",
//                 @"color" : [UIColor colorWithRed:0 green:0.8 blue:0.3 alpha:1.0],
//                 @"content" : @[
//                         @"Consult",
//                         @"Design",
//                         @"Code",
//                         @"Mentor / Advise",
//                         @"Legal advise",
//                         @"Other collaborations",
//                         ],
//                 },
//             @{
//                 @"title": @"Learn",
//                 @"color" : [UIColor colorWithRed:100/255. green:1.0 blue:100/255. alpha:1.0],
//                 @"content" : @[
//                         @"Music & Instruments",
//                         @"Arts",
//                         @"School stuff",
//                         @"Knitting",
//                         @"Flowers",
//                         @"Other activities",
//                         ],
//                 },
//             @{
//                 @"title": @"Play/Sports",
//                 @"color" : [UIColor colorWithRed:102/255. green:205/255. blue:255/255. alpha:1.0],
//                 @"content" : @[
//                         @"Golf",
//                         @"Billiards",
//                         @"Tennis",
//                         @"Basketball",
//                         @"Ski & snowboard",
//                         @"Water sports",
//                         @"Fishing",
//                         @"Rafting",
//                         @"Other sports",
//                         ],
//                 },
//             @{
//                 @"title": @"Workout",
//                 @"color" : [UIColor colorWithRed:0/255. green:128/255. blue:255/255. alpha:1.0],
//                 @"content" : @[
//                         @"Run / Jog",
//                         @"Walk / Hike",
//                         @"Health & Body building",
//                         @"Cylce",
//                         @"Rock climing",
//                         @"Swimming",
//                         @"Other workouts",
//                         ],
//                 },
//             @{
//                 @"title": @"Share",
//                 @"color" : [UIColor colorWithRed:0/255. green:128/255. blue:128/255. alpha:1.0],
//                 @"content" : @[
//                         @"Car pool",
//                         @"Taxi",
//                         @"Room",
//                         @"Other shares",
//                         ],
//                 },
//             @{
//                 @"title": @"Play/Games",
//                 @"color" : [UIColor colorWithRed:255/255. green:128/255. blue:0/255. alpha:1.0],
//                 @"content" : @[
//                         @"Poker",
//                         @"Go",
//                         @"Chess",
//                         @"Board games",
//                         @"Hwatu",
//                         @"Computer games",
//                         @"Other games",
//                         ],
//                 },
//             @{
//                 @"title": @"Trade/Buy/Sell",
//                 @"color" : [UIColor colorWithRed:255/255. green:204/255. blue:102/255. alpha:1.0],
//                 @"content" : @[
//                         @"Car",
//                         @"Motorcycle",
//                         @"Bicycle",
//                         @"Segway",
//                         @"Other machines",
//                         @"Errands",
//                         @"Cooking",
//                         @"Cleaning",
//                         @"Delivery",
//                         @"Other services",
//                         @"Apartment",
//                         @"Officetel",
//                         @"Office space",
//                         @"House",
//                         @"Other realestate",
//                         @"Electronics",
//                         @"Toys",
//                         @"Other goods",
//                         ],
//                 },
//             @{
//                 @"title": @"Other stuff",
//                 @"color" : [UIColor colorWithRed:102/255. green:102/255. blue:255/255. alpha:1.0],
//                 @"content" : @[
//                         @"etc",
//                         ],
//                 },
//             ];
//}
//
