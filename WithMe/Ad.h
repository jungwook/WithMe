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

- (BOOL) isMine;
- (void) fetched:(VoidBlock)handler;
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
- (User*)       user;
- (void)        setUser:(User *)user;
- (NSString*)   paymentTypeString;
- (UIColor*)    paymentTypeColor;
- (void)        userProfileMediaLoaded:(ImageLoadedBlock)handler;
- (void)        userProfileThumbnailLoaded:(ImageLoadedBlock)handler;
- (void)        mediaImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler;
- (void)        thumbnailImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler;
- (void)        mediaImagesLoaded:(ImageArrayBlock)handler;
- (void)        firstMediaImageLoaded:(ImageLoadedBlock)handler;
- (void)        firstThumbnailImageLoaded:(ImageLoadedBlock)handler;
- (void)        fetched:(VoidBlock)handler;
- (void)        saved:(VoidBlock)handler;
- (void)        saveAndNotify:(VoidBlock)handler;
- (void)        addMedia:(UserMedia*)media;
- (void)        removeMedia:(UserMedia*)media;
- (void)        like;
- (void)        unlike;
- (void)        viewed;
- (void)        countViewed:(CountBlock)handler;
- (void)        countLikes:(CountBlock)handler;
- (void)        setAdLocationWithLocation:(AdLocation *)adLocation;
- (BOOL)        isMine;
@end
