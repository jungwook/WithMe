//
//  MediaView.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MediaViewEditBlock)(UserMedia* media);

@interface MediaView : UIView
- (void) setEditableAndUserProfileMediaHandler:(MediaViewEditBlock)block;
- (void) loadMediaFromUser:(User *)user;
- (void) loadMediaFromUserMedia:(UserMedia *)media;
- (void) makeCircle:(BOOL)makeCircle;
@end
