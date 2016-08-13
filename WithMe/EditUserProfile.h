//
//  EditUserProfile.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DeletableCellDelegate <NSObject>
@required
- (void) deleteUserMedia:(UserMedia*)media;
@end

@interface EditUserProfile : UITableViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DeletableCellDelegate, UITextFieldDelegate>

@end
