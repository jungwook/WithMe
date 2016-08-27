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
@property (retain) NSString*            comment;
@property (retain) NSArray<UserMedia*>  *media;
@property (retain) User*                user;
@property (retain) Ad*                  ad;

- (void) fetched:(VoidBlock)handler;
- (void) loadAllMedia:(UserMediaArrayBlock)handler;
- (void) loadFirstMedia:(UserMediaBlock)handler;
@end

@interface Ad : PFObject <PFSubclassing>
@property (retain)  User*       user;
@property (retain)  Activity    *activity;
@property (retain)  NSString    *title;
@property (retain)  PFGeoPoint  *location;
@property (retain)  NSString    *intro;
@property (retain)  AdLocation  *adLocation;
@property           PaymentType payment;
@property           NSDate      *eventDate;
@property           NSInteger   participants;
@property (retain)  NSArray <UserMedia*>    *media;
@property (retain)  NSArray <AdJoin*>       *joins;

+ (void)        randomlyCreateOneAd;

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
- (void)        addMedia:(UserMedia*)media;
- (void)        removeMedia:(UserMedia*)media;
- (BOOL)        isMine;
- (void)        like;
- (void)        unlike;
- (void)        viewed;
- (void)        countViewed:(CountBlock)handler;
- (void)        countLikes:(CountBlock)handler;
- (void)        setAdLocationWithLocation:(AdLocation *)adLocation;
- (void)        join:(AdJoin*) request;
- (void)        unjoin:(AdJoin*) request;
@end
