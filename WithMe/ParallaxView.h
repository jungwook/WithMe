//
//  ParallaxView.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParallaxView : UIView <UIScrollViewDelegate>
- (void)setNavigationBarProperties:(UINavigationBar *)bar;
- (void)setScrollOffset:(UIScrollView*)scrollView;
@end
