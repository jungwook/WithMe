//
//  AdDetail.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdDelegateProtocol.h"
#import "SlideShow.h"
#import "AdDetailCell.h"
#import "AdRowCell.h"

typedef enum : NSUInteger {
    kAdDetailSectionByUser = 0,
    kAdDetailSectionSimilar,
} AdDetailSections;

@interface AdDetail : UITableViewController <UITableViewDelegate, UITableViewDataSource, UsersCollectionDelegate, AdDelegate>
@property (nonatomic, strong) Ad* ad;
@end
