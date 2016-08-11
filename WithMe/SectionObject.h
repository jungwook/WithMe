//
//  SectionObject.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kSectionRecent = 0,
    kSectionNewAds,
    kSectionPostNewAd,
    kSectionArea,
    kSectionCategory,
    kSectionTrending,
    kSectionInvite
} AdCollectionSections;

@interface SectionObject : NSObject
@property (nonatomic) AdCollectionSections section;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableArray *items;

+ (instancetype) sectionObjectWithIdentifier:(NSString*)identifier
                                     section:(AdCollectionSections)section
                                       title:(NSString*)title
                                    subTitle:(NSString*)subTitle
                                       image:(UIImage*)image
                                       items:(NSArray*)items;
@end
