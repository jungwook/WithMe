//
//  User.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Parse/Parse.h>
#import "S3File.h"

typedef void(^VoidBlock)(void);

typedef NS_OPTIONS(NSUInteger, GenderType)
{
    kGenderTypeMale = 0,
    kGenderTypeFemale,
    kGenderTypeMaleGay,
    kGenderTypeMaleBi,
    kGenderTypeFemaleLesbian,
    kGenderTypeFemaleBi,
    kGenderTypeUnknown
};

typedef NS_OPTIONS(BOOL, MediaType)
{
    kMediaTypePhoto = 0,
    kMediaTypeVideo
};

@interface UserMedia : PFObject <PFSubclassing>
@property (retain) NSString* userId;
@property (retain) NSString* comment;
@property (retain) NSString* thumbailFile;
@property (retain) NSString* mediaFile;
@property MediaType mediaType;
@property CGSize mediaSize;
@property BOOL isRealMedia;
@property BOOL isProfileMedia;

- (void) ready:(VoidBlock)handler;
- (void) fetched:(VoidBlock)handler;
- (void) saved:(VoidBlock)handler;
@end


@interface User : PFUser <PFSubclassing>
@property (retain) NSString*    nickname;
@property (retain) PFGeoPoint*  location;
@property (retain) NSDate*      locationUdateAt;
@property (retain) NSString*    address;
@property (retain) NSString*    age;
@property (retain) NSString*    withMe;
@property (retain) NSString*    introduction;
@property (retain) NSArray*     media;
@property (retain) NSArray*     likes;
@property (retain) NSArray*     posts;
@property GenderType            gender;

+ (instancetype)me;
+ (NSString*)   uniqueUsername;
- (void)        removeMe;
- (BOOL)        isMe;

- (void)        setGenderTypeFromString:(NSString*)gender;
- (NSString*)   genderTypeString;
- (NSString*)   genderCode;
- (UIColor*)    genderColor;

- (void)        mediaReady:(VoidBlock)handler;
- (void)        fetched:(VoidBlock)handler;
- (void)        saved:(VoidBlock)handler;
+ (NSArray*)    categories;
+ (NSArray*)    genders;
+ (NSArray*)    withMes;
+ (NSArray*)    ageGroups;
- (UserMedia*)  profileMedia;
- (void)        setProfileMedia:(UserMedia*)profileMedia;
- (NSArray *)   sortedMedia;
+ (NSArray *)   endCategories;
+ (NSString*)   categoryForEndCategory:(NSString*)endCategory;
+ (UIColor*)    categoryColorForEndCategory:(NSString*)endCategory;
@end

@interface Category : PFObject <PFSubclassing>
@property (retain) NSString *name;
@property (retain) NSString *intro;
@property (retain) NSString *imageFile;
@property (retain) NSArray *activities;
@end

@interface Activity : PFObject <PFSubclassing>
@property (retain) NSString *name;
@property (retain) NSString *intro;
@property (retain) NSString *imageFile;
@property (retain) Category *category;
@end

typedef NS_OPTIONS(NSUInteger, PaymentType)
{
    kPaymentTypeNone = 0,
    kPaymentTypeIBuy,
    kPaymentTypeYouBuy,
    kPaymentTypeDutch
};

typedef void(^ImageLoadedBlock)(UIImage* image);

@interface Ad : PFObject <PFSubclassing>
@property (retain)  User*       user;
@property (retain)  Activity    *activity;
@property (retain)  NSString    *title;
@property           PaymentType payment;
@property (retain)  PFGeoPoint  *location;
@property (retain)  NSString    *address;
@property (retain)  NSString    *intro;
@property (retain)  NSArray     *media;
@property           NSInteger   likesCount;

+ (void)        randomnizeAdAndSaveInBackgroundOfCount:(NSUInteger)count;
- (void)        mediaAndUserReady:(VoidBlock)handler;
+ (void)        resetTitles;
- (NSString*)   paymentTypeString;
- (UIColor*)    paymentTypeColor;
- (void)        likedByUser:(User *)user handler:(VoidBlock)handler;
- (void)        unlikedByUser:(User *)user handler:(VoidBlock)handler;
- (void)        loadUserProfileMediaLoaded:(ImageLoadedBlock)handler;
- (void)        loadUserProfileThumbnailLoaded:(ImageLoadedBlock)handler;

@end

