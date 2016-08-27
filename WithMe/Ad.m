//
//  Ad.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Ad.h"

static NSString* const longStringOfWords = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";


@interface Ad()
@end

#pragma mark Ad

@implementation Ad
@dynamic user, title, activity, payment, intro, media, eventDate, location, adLocation, participants, joins;

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
        [self addUniqueObject:media forKey:kAdMedia];
    }
}

- (void) removeMedia:(UserMedia*)media
{
    if (media) {
        [self removeObject:media forKey:kAdMedia];
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
    
    [ad addObjectsFromArray:[Ad itemsFromArray:media count:10] forKey:kAdMedia];
    
    AdLocation *adLoc = [AdLocation object];
    CGFloat ranLat = 0.1*((arc4random()%1000)-500)/1000.0;
    CGFloat ranLng = 0.1*((arc4random()%1000)-500)/1000.0;
    adLoc.location = [PFGeoPoint geoPointWithLatitude:37.520884+ranLat longitude:127.028360+ranLng];
    
    getAddressForPFGeoPoint(adLoc.location, ^(NSString *address) {
        adLoc.address = address;
        [adLoc setSpanInMeters:1000 + arc4random()%2000];
        adLoc.comment = @"Simulated Location";
        ad.adLocation = adLoc;
        ad.participants = 1+arc4random()%10;
        ad.payment = arc4random()%4;
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

- (void)like
{
    [[User me] likesAd:self];
}

- (void)unlike
{
    [[User me] unlikesAd:self];
}

- (void)viewed
{
    [[User me] viewedAd:self];
}

- (void)countLikes:(CountBlock _Nonnull)handler
{
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFQuery *query = [User query];
        [query whereKey:@"likes" containsAllObjectsInArray:@[self]];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            handler(number);
        }];
    }];
}

- (void)countViewed:(CountBlock _Nonnull)handler
{
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFQuery *query = [User query];
        [query whereKey:@"viewed" containsAllObjectsInArray:@[self]];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            handler(number);
        }];
    }];
}

- (void)setAdLocationWithLocation:(AdLocation *)adLocation
{
    self.adLocation = adLocation;
    self.location = adLocation.location;
}

- (void) saved:(VoidBlock)handler
{
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded && !error) {
            if (handler) {
                handler();
            }
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

- (void)join:(AdJoin *)request
{
    [self addUniqueObject:request forKey:kAdJoins];
}

- (void)unjoin:(AdJoin *)request
{
    __block AdJoin *requestToRemove = nil;
    [self.joins enumerateObjectsUsingBlock:^(AdJoin* _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([request.objectId isEqualToString:request.objectId]) {
            *stop = YES;
            requestToRemove = request;
        }
    }];
    
    if (requestToRemove) {
        [self removeObject:requestToRemove forKey:kAdJoins];
    }
}


@end

@implementation AdJoin
@dynamic comment, media, user, ad;

+(NSString *)parseClassName
{
    return @"AdJoin";
}

- (void)fetched:(VoidBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        else {
            [self.user fetched:^{
                [UserMedia fetchAllIfNeededInBackground:self.media block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
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
    }];
}

- (void)loadAllMedia:(UserMediaArrayBlock)handler
{
    [self fetched:^{
        if (handler) {
            handler(self.media);
        }
    }];
}

- (void)loadFirstMedia:(UserMediaBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        UserMedia *first = self.media.firstObject;
        [first fetched:^{
            if (handler) {
                handler(first);
            }
        }];
    }];
}

@end
