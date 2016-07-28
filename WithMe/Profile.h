//
//  Profile.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kSectionProfileMedia = 0,
    kSectionUserLikes,
    kSectionUserLiked
} Sections;

@interface Profile : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end
