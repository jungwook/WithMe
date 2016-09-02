//
//  Ad.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAdMedia    @"media"
#define kAdJoins    @"joins"
#define kAdJoinMedia @"media"

@interface AdJoin : PFObject <PFSubclassing>
@property (retain) NSString*            adId;
@property (retain) NSString*            userId;
@property (retain) NSString*            comment;
@property (retain) NSArray<UserMedia*>  *media;
@property (nonatomic) BOOL              accepted;

// User related
- (BOOL) isMine;

// load and save
- (void) fetched:(VoidBlock)handler;

// Media related
- (void) loadAllMedia:(UserMediaArrayBlock)handler;
- (void) loadFirstMedia:(UserMediaBlock)handler;
- (void) loadFirstMediaThumbnailImage:(ImageLoadedBlock)handler;


- (void) join:(Ad*)ad;
- (void) join:(Ad*)ad joinedHandler:(VoidBlock)handler;
- (void) unjoin;
- (void) unjoined:(VoidBlock)handler;
@end

@interface Ad : PFObject <PFSubclassing>
@property (retain)  NSString    *userId;
@property (retain)  Activity    *activity;
@property (retain)  NSString    *title;
@property (retain)  PFGeoPoint  *location;
@property (retain)  NSString    *intro;
@property (retain)  AdLocation  *adLocation;
@property           PaymentType payment;
@property           NSDate      *eventDate;
@property (retain)  NSArray <UserMedia*>    *media;

+ (void)        randomlyCreateOneAd;

// User related
- (User*)       user;
- (void)        setUser:(User *)user;
- (BOOL)        isMine;

// Payment related
- (NSString*)   paymentTypeString;
- (UIColor*)    paymentTypeColor;

// Media related
- (void)        userProfileMediaLoaded:(ImageLoadedBlock)handler;
- (void)        userProfileThumbnailLoaded:(ImageLoadedBlock)handler;
- (void)        mediaImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler;
- (void)        thumbnailImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler;
- (void)        mediaImagesLoaded:(ImageArrayBlock)handler;
- (void)        firstMediaImageLoaded:(ImageLoadedBlock)handler;
- (void)        firstThumbnailImageLoaded:(ImageLoadedBlock)handler;
- (void)        addMedia:(UserMedia*)media;
- (void)        removeMedia:(UserMedia*)media;

// Load & save
- (void)        fetched:(VoidBlock)handler;
- (void)        saved:(VoidBlock)handler;
- (void)        saveAndNotify:(VoidBlock)handler;

// Counts likes and viewed
- (void)        countViewed:(CountBlock)handler;
- (void)        countLikes:(CountBlock)handler;

// Location related
- (void)        setAdLocationWithLocation:(AdLocation *)adLocation;

@end

@interface AdLocation : PFObject <PFSubclassing>
@property (retain)  PFGeoPoint  *location;
@property (retain)  NSString    *address;
@property (retain)  NSString    *thumbnailFile;
@property (retain)  NSString    *comment;
@property           LocationType locationType;
@property           CGFloat     latitudeDelta;
@property           CGFloat     longitudeDelta;

+ (instancetype) adLocationWithLocation:(PFGeoPoint*)location
                                   span:(MKCoordinateSpan)span
                               pinColor:(UIColor *)pinColor
                                   size:(CGSize)size
                             completion:(AdLocationBlock)createdBlock;

+ (instancetype) adLocationWithLocation:(PFGeoPoint*)location
                           spanInMeters:(CGFloat)span
                               pinColor:(UIColor *)pinColor
                                   size:(CGSize)size
                             completion:(AdLocationBlock)createdBlock;

- (void) updateWithNewLocation:(PFGeoPoint*)location
                      pinColor:(UIColor *)pinColor
                          size:(CGSize)size
                    completion:(AdLocationBlock)createdBlock;

- (void) mapImageWithPinColor:(UIColor*)pinColor
                         size:(CGSize)size
                      handler:(ImageLoadedBlock)block;

- (void) mapIconImageWithSize:(CGSize)size
                      handler:(ImageLoadedBlock)block;

- (MKCoordinateSpan) span;
- (void)setSpan:(MKCoordinateSpan)span;
- (void)setSpanInMeters:(CGFloat)meters;
- (CLLocationCoordinate2D) coordinates;
- (void)setCoordinates:(CLLocationCoordinate2D)coordinates;
- (void)fetched:(VoidBlock)block;
@end

