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
{
    User *owner;
}
@end

#pragma mark Ad

@implementation Ad
@dynamic userId, title, activity, payment, intro, media, eventDate, location, adLocation; //, joins;

+ (NSString *)parseClassName
{
    return @"Ad";
}

- (BOOL)isMine
{
    return [self.userId isEqualToString:[User me].objectId];
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
            [self.user fetched:^{
                handler();
            }];
        }
    }];
}

- (User *)user
{
    if (self.isDataAvailable)
        return owner ? owner : [User objectWithoutDataWithObjectId:self.userId];
    else
        return nil;
}

- (void)setUser:(User *)user
{
    self.userId = user.objectId;
    owner = user;
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
                [S3File getDataFromFile:media.mediaType == kMediaTypeVideo ? media.thumbnailFile : media.mediaFile dataBlock:^(NSData *data) {
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
                    [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
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
    static NSArray <User *> *users;
    if (!users) {
        users = [Ad usersWithProfileMedia];
    }
    static NSArray <UserMedia *>*media;
    if (!media) {
        media = [Ad userMedia];
    }
    static NSArray <Activity*> *activities;
    if (!activities) {
        activities = [WithMe new].activities;
    }
    
    Ad *ad = [Ad object];
    ad.title = [Ad sentence:3+arc4random()%10];
    ad.intro = [Ad sentence:30+arc4random()%30];
    ad.userId = [users objectAtIndex:arc4random()%users.count].objectId;
    ad.activity = [activities objectAtIndex:arc4random()%activities.count];
    
    [ad addObjectsFromArray:[Ad itemsFromArray:media count:10] forKey:kAdMedia];
    
    AdLocation *adLoc = [AdLocation object];
    
    NSInteger ii = arc4random()%1000;
    NSInteger ij = arc4random()%1000;
    NSInteger iLat = ii-500, iLng = ij-500;
    
    CGFloat ranLat = 0.1*iLat/1000.0;
    CGFloat ranLng = 0.1*iLng/1000.0;
    adLoc.location = [PFGeoPoint geoPointWithLatitude:37.520884+ranLat longitude:127.028360+ranLng];
    
    getAddressForPFGeoPoint(adLoc.location, ^(NSString *address) {
        adLoc.address = address;
        [adLoc setSpanInMeters:1000 + arc4random()%2000];
        adLoc.comment = @"Simulated Location";
        ad.payment = arc4random()%4;
        [ad setAdLocationWithLocation:adLoc];
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

- (void)saveAndNotify:(VoidBlock)handler
{
    [self saved:^{
        NOTIFY(kNotifyAdSaved, self);
        if (handler)
            handler();
    }];
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

@end

#pragma mark AdJoin

@implementation AdJoin
@dynamic adId, userId, comment, media, accepted;

+(NSString *)parseClassName
{
    return @"AdJoin";
}

- (BOOL)isMine
{
    return [[User me].objectId isEqualToString:self.userId];
}

- (void)fetched:(VoidBlock)handler
{
    [self fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        else {
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

- (void)loadFirstMediaThumbnailImage:(ImageLoadedBlock)handler
{
    [self loadFirstMedia:^(UserMedia *media) {
        [S3File getImageFromFile:media.thumbnailFile imageBlock:^(UIImage *image) {
            if (handler) {
                handler(image);
            }
        }];
    }];
}

- (void)join:(Ad *)ad
{
    [self join:ad joinedHandler:nil];
}

- (void)join:(Ad *)ad joinedHandler:(VoidBlock)handler
{
    self.adId = ad.objectId;
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (handler) {
            handler();
        }
    }];
}

- (void)unjoin
{
    [self unjoined:nil];
}

- (void)unjoined:(VoidBlock)handler
{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (handler) {
            handler();
        }
    }];
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
    
    CGFloat mw = MIN(MIN(size.width, size.height) / 10, 20);
    
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

- (void)mapIconImageWithSize:(CGSize)size handler:(ImageLoadedBlock)block
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.coordinates, 10000, 10000);
    [self mapImageUsingRegion:region pinColor:[UIColor clearColor] size:size handler:block];
}

@end



