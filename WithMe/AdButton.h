//
//  AdButton.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdButtonDelegate <NSObject>

@required
- (void) buttonSelected:(NSInteger)index;

@end

@interface AdButton : UITableViewCell

- (void)setButtonIndex:(NSInteger)index
                 title:(NSString*)title
              subTitle:(NSString*)subTitle
            coverImage:(UIImage*)image
        buttonDelegate:(id<AdButtonDelegate>)delegate;
@end
