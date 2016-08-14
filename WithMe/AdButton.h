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
- (void) buttonSelected:(NSInteger)index;

@end

@interface AdButton : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buttonImageView;
@property (weak, nonatomic) id<AdButtonDelegate> buttonDelegate;
@property (nonatomic) NSInteger index;
@end
