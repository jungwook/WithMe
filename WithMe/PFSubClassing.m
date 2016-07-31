//
//  User.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PFSubClassing.h"

@implementation User
@dynamic nickname,location,locationUdateAt, gender, age, withMe, media, likes, posts;

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

+ (NSArray*) activities
{
    return @[
             @{
                 @"title": @"Eat & Drink",
                 @"content" : @[
                         @"Dinner",
                         @"Lunch",
                         @"Breakfast",
                         @"Brunch",
                         @"Coffee & tea",
                         @"Beer",
                         @"Light drinks",
                         @"Heavy drinks",
                         @"etc",
                         ],
                 },
             @{
                 @"title": @"Flirt & Date",
                 @"content" : @[
                         @"Blind Date",
                         @"Movies",
                         @"Drive",
                         @"Ride",
                         @"Holiday",
                         @"Chat",
                         @"Talk",
                         @"etc",
                         ],
                 },
             @{
                 @"title": @"Work",
                 @"content" : @[
                         @"Consult",
                         @"Design",
                         @"Code",
                         @"Mentor / Advise",
                         @"Legal advise",
                         @"etc",
                         ],
                 },
             @{
                 @"title": @"Learn",
                 @"content" : @[
                         @"Music & Instruments",
                         @"Arts",
                         @"School stuff",
                         @"Knitting",
                         @"Flowers",
                         @"etc",
                         ],
                 },
             @{
                 @"title": @"Sports",
                 @"content" : @[
                         @"Run / Jog",
                         @"Walk / Hike",
                         @"Golf",
                         @"Billiards",
                         @"Tennis",
                         @"Basketball",
                         @"Ski & snowboard",
                         @"Watersports",
                         @"Health & Body building",
                         @"Cylce",
                         @"Fishing",
                         @"Rock climing",
                         @"Rafting",
                         @"Swimming",
                         @"etc",
                         ],
                 },
             @{
                 @"title": @"Indoor Games",
                 @"content" : @[
                         @"Poker",
                         @"Go",
                         @"Chess",
                         @"Board games",
                         @"Hwatu",
                         @"etc",
                         ],
                 },
             @{
                 @"title": @"Trade & Sell",
                 @"content" : @[
                         @"Electronics",
                         @{
                             @"title": @"Real estate",
                             @"content" : @[
                                     @"Apartment",
                                     @"Officetel",
                                     @"Office space",
                                     @"House",
                                     @"etc",
                                     ],
                             },
                         @{
                             @"title": @"Cars & Bikes",
                             @"content" : @[
                                     @"Car",
                                     @"Motorcycle",
                                     @"Bicycle",
                                     @"Segway",
                                     @"etc",
                                     ],
                             },
                         @"Toys",
                         @{
                             @"title": @"Services",
                             @"content" : @[
                                     @"Errands",
                                     @"Cooking",
                                     @"Cleaning",
                                     @"Delivery",
                                     @"etc",
                                     ],
                             },
                         @"etc",
                         ],
                 },
             ];

//    return @[
//             @{
//                 @"title": @"Activities",
//                 @"content" : @[
//                         @{
//                             @"title": @"Eat & Drink",
//                             @"content" : @[
//                                        @"Dinner",
//                                        @"Lunch",
//                                        @"Breakfast",
//                                        @"Brunch",
//                                        @"Coffee & tea",
//                                        @"Beer",
//                                        @"Cocktail & Light drinks",
//                                        @"Heavy drinks",
//                                        @"etc",
//                                     ],
//                             },
//                         @"Flirt & Date",
//                         @"Watch a movie",
//                         @{
//                             @"title": @"Work",
//                             @"content" : @[
//                                     @"Consult",
//                                     @"Design",
//                                     @"Code",
//                                     @"Mentor / Advise",
//                                     @"Legal advise",
//                                     @"etc",
//                                     ],
//                             },
//                         @{
//                             @"title": @"Getaway",
//                             @"content" : @[
//                                     @"Drive",
//                                     @"Ride",
//                                     @"Holiday",
//                                     @"etc",
//                                     ],
//                             },
//                         @{
//                             @"title": @"Casual",
//                             @"content" : @[
//                                     @"Chat",
//                                     @"Talk",
//                                     @"etc",
//                                     ],
//                             },
//                         @{
//                             @"title": @"Learn",
//                             @"content" : @[
//                                     @"Music & Instruments",
//                                     @"Arts",
//                                     @"School stuff",
//                                     @"Knitting",
//                                     @"Flowers",
//                                     @"etc",
//                                     ],
//                             },
//                         @{
//                             @"title": @"Sports",
//                             @"content" : @[
//                                     @"Run / Jog",
//                                     @"Walk / Hike",
//                                     @"Golf",
//                                     @"Billiards",
//                                     @"Tennis",
//                                     @"Basketball",
//                                     @"Ski & snowboard",
//                                     @"Watersports",
//                                     @"Health & Body building",
//                                     @"Cylce",
//                                     @"Fishing",
//                                     @"Rock climing",
//                                     @"Rafting",
//                                     @"Swim",
//                                     @"etc",
//                                     ],
//                             },
//                         @{
//                             @"title": @"Indoor Games",
//                             @"content" : @[
//                                     @"Poker",
//                                     @"Go",
//                                     @"Chess",
//                                     @"Board games",
//                                     @"Hwatu",
//                                     @"etc",
//                                     ],
//                             },
//                         
//                         ],
//                 },
//             @{
//                 @"title": @"Trade & Sell",
//                 @"content" : @[
//                         @"Electronics",
//                         @{
//                             @"title": @"Cars & Bikes",
//                             @"content" : @[
//                                     @"Car",
//                                     @"Motorcycle",
//                                     @"Bicycle",
//                                     @"Segway",
//                                     @"etc",
//                                     ],
//                             },
//                         @"Toys",
//                         @{
//                             @"title": @"Services",
//                             @"content" : @[
//                                     @"Errands",
//                                     @"Cooking",
//                                     @"Cleaning",
//                                     @"Delivery",
//                                     @"etc",
//                                     ],
//                             },
//                         @"etc",
//                         ],
//                 },
//             ];
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
    __block UserMedia *profileMedia = nil;
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

@implementation Ad
@dynamic user, category, payment, location, intro, media;

+ (NSString *)parseClassName
{
    return @"Ad";
}

@end

