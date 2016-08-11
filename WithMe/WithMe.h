//
//  WithMe.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^CategorieReadyBlock)(void);
typedef void(^ActivitiesReadyBlock)(void);

@interface WithMe : NSObject
- (NSArray*) categories;
- (NSArray*) activities;
- (UIImage*) imageForCategory:(Category*)category;
@end
