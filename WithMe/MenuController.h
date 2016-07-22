//
//  MainController.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "FloatingDrawerViewController.h"

@interface MenuController : FloatingDrawerViewController
@property (nonatomic, strong) NSDictionary* screens;
- (void) selectScreenWithID:(NSString*) screen;
- (void) toggleMenuWithScreenID:(NSString *)screen;
- (void) toggleMenu;
@end
