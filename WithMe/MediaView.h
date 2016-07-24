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
@property (nonatomic, copy) MediaViewEditBlock editBlock;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UserMedia *media;
@property (nonatomic, readonly) BOOL isReal;
@property (nonatomic, readonly) MediaType mediaType;
@property (nonatomic, weak) UIImage *image;

- (void)setEditable:(BOOL)editable handler:(MediaViewEditBlock)block;
- (void) loadMediaFromUser:(User *)user;
- (void) loadMediaFromUserMedia:(UserMedia *)media;
@end
