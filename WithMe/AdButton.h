//
//  AdButton.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdCollection.h"

@protocol AdButtonDelegate <NSObject>

@required
- (void) buttonSelected:(SectionObject*)section;

@end

@interface AdButton : UITableViewCell
@property (strong, nonatomic) SectionObject *section;
@property (weak, nonatomic) id<AdButtonDelegate> delegate;
@end
