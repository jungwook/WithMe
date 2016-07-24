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
@property (retain) NSString*    age;
@property (retain) NSString*    withMe;
@property (retain) NSArray*     media;
@property (retain) NSArray*     likes;
@property (retain) NSArray*     posts;
@property GenderType            gender;

+ (instancetype) me;
+ (NSString*) uniqueUsername;
- (void) removeMe;
- (BOOL) isMe;

- (void) setGenderTypeFromString:(NSString*)gender;
- (NSString*) genderTypeString;

- (UIColor*) genderColor;

- (void) mediaReady:(VoidBlock)handler;
- (void) fetched:(VoidBlock)handler;
- (void) saved:(VoidBlock)handler;
+ (NSArray*) genders;
+ (NSArray*) withMes;
+ (NSArray*) ageGroups;
- (UserMedia*) profileMedia;
- (void) setProfileMedia:(UserMedia*)profileMedia ready:(VoidBlock)handler;
- (NSArray *)sortedMedia;
@end