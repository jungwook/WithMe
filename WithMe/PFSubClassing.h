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
typedef void(^ImageLoadedBlock)(UIImage* image);
typedef void(^ImageArrayBlock)(NSArray* array);
typedef void(^QueryBlock)(NSArray* objects);
typedef void(^LocationBlock)(PFGeoPoint* location);
typedef void(^AddressBlock)(NSString* address);

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

- (void) fetched:(VoidBlock)handler;
- (void) saved:(VoidBlock)handler;
- (void) imageLoaded:(ImageLoadedBlock)block;
- (void) thumbnailLoaded:(ImageLoadedBlock)block;
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

- (void)        profileMediaImageLoaded:(ImageLoadedBlock)block;
- (void)        profileMediaThumbnailLoaded:(ImageLoadedBlock)block;
- (void)        mediaImagesLoaded:(ImageArrayBlock)block;

- (void)        setGenderTypeFromString:(NSString*)gender;
- (NSString*)   genderTypeString;
- (NSString*)   genderCode;
- (UIColor*)    genderColor;
- (CLLocationCoordinate2D) locationCoordinates;
- (CLLocation*) locationCLLocation;

- (void)        fetched:(VoidBlock)handler;
- (void)        saved:(VoidBlock)handler;
+ (NSArray*)    categories;
+ (NSArray*)    genders;
+ (NSArray*)    withMes;
+ (NSArray*)    ageGroups;
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

typedef NS_OPTIONS(NSUInteger, LocationType)
{
    kLocationTypeAdhoc = 0,
    kLocationTypeStart,
    kLocationTypeEnd,
    kLocationTypeMiddle,
};

@interface AdLocation : PFObject <PFSubclassing>
@property (retain)  PFGeoPoint  *location;
@property (retain)  NSString    *address;
@property LocationType locationType;
@end

@interface Ad : PFObject <PFSubclassing>
@property (retain)  User*       user;
@property (retain)  Activity    *activity;
@property (retain)  NSString    *title;
@property           PaymentType payment;
@property (retain)  NSString    *intro;
@property           NSInteger   likesCount;
@property           NSInteger   viewedByCount;
@property (retain)  NSArray     *viewedBy;
@property (retain)  NSArray     *media;
@property (retain)  NSArray     *likes;
@property (retain)  NSArray     *locations;
@property           NSInteger   ourParticipants;
@property           NSInteger   yourParticipants;

- (NSString*)   paymentTypeString;
- (UIColor*)    paymentTypeColor;
- (void)        likedByUser:(User *)user handler:(VoidBlock)handler;
- (void)        unlikedByUser:(User *)user handler:(VoidBlock)handler;
- (void)        viewedByUser:(User *)user handler:(VoidBlock)handler;
- (void)        userProfileMediaLoaded:(ImageLoadedBlock)handler;
- (void)        userProfileThumbnailLoaded:(ImageLoadedBlock)handler;
- (void)        mediaImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler;
- (void)        thumbnailImageAtIndex:(NSInteger)index loaded:(ImageLoadedBlock)handler;
- (void)        mediaImagesLoaded:(ImageArrayBlock)handler;
- (void)        firstMediaImageLoaded:(ImageLoadedBlock)handler;
- (void)        firstThumbnailImageLoaded:(ImageLoadedBlock)handler;
- (void)        fetched:(VoidBlock)handler;
- (void)        location:(LocationBlock)handler;
- (void)        address:(AddressBlock)handler;
@end


