//
//  PlaceholderTextView.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceholderTextView : UITextView <UITextViewDelegate>
@property (nonatomic, strong) NSString *placeholder;
@end
