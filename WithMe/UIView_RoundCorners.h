//
//  UIView_RoundCorners.h
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(RoundCorners)
@property (nonatomic) CGFloat radius;
- (void) makeCircle:(BOOL)makeCircle;
@end

