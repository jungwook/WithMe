//
//  ImagePanel.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePanel : UIView
@property (nonatomic, strong) NSArray *images;
- (void) clearAllContents;
@end
