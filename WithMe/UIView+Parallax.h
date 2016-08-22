//
//  UIView(Parallax).h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Parallax)
@property (nonatomic, strong)  CADisplayLink *displayLink;
- (void) enableParallax;
- (void) disableParallax;
@end
