//
//  MainController.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MenuController.h"
#import "FloatingDrawerSpringAnimator.h"
#import "AppDelegate.h"
#import "Menu.h"
#import "SignUp.h"
#import "ListField.h"

@interface MenuController ()
@property (nonatomic) BOOL systemInitialized;
@end

@implementation MenuController

- (void)awakeFromNib
{
    [super awakeFromNib];
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.menuController = self;
    self.systemInitialized = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.backgroundImage = [UIImage imageNamed:@"bg"];
    self.view.backgroundColor = kAppColor;
}

- (void)checkLoginStatusAndProceed
{
//    [User logOut];
    User *user = [User me];
    
    VoidBlock initializationHandler = ^(void) {
//        [[FileSystem new] initializeSystem];
        [self initializeMainViewControllerToScreenId:@"Ads"];
    };
    
    if (user) {
        [user fetched:^{
            initializationHandler();
        }];
    }
    else {
        SignUp *signup = [[[NSBundle mainBundle] loadNibNamed:@"SignUp" owner:self options:nil] firstObject];
        signup.modalPresentationStyle = UIModalPresentationOverFullScreen;
        signup.completionBlock = ^(SignUp* signup, id nickname, id intro, id age, id gender)
        {
            User *user = [User object];
            id usernameAndPassword = [ObjectIdStore newObjectId];
            user.username = usernameAndPassword;
            user.password = usernameAndPassword;
            user.nickname = nickname;
            user.age = age;
            user.withMe = intro;
            [user setGenderTypeFromString:gender];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                        if (!error) {
                            [signup dismissViewControllerAnimated:YES completion:nil];
                            [self subscribeToChannelCurrentUser];
                            initializationHandler();
                        }
                        else {
                            [signup setInfo:[NSString stringWithFormat:@"Some error occured:%@", error.localizedDescription]];
                        }
                    }];
                }
                else {
                    [signup setInfo:[NSString stringWithFormat:@"Some error occured:%@", error.localizedDescription]];
                }
            }];
        };
        [self presentViewController:signup animated:YES completion:nil];
    }
}

- (void) initializeMainViewControllerToScreenId:(id)screenId
{
    if ([self initializeViewControllers]) {
        NSLog(@"All systems go...");
        
        UIViewController *center = self.screens[screenId][@"screen"];
        NSString* title = self.screens[screenId][@"title"];
        Menu *menu = [[[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self options:nil] firstObject];
        menu.menuController = self;
        
        self.leftViewController = menu;
        self.centerViewController = center ? center : [self.storyboard instantiateViewControllerWithIdentifier:screenId];
        [self.centerViewController setTitle:title ? title : @"No title"];
        self.animator = [[FloatingDrawerSpringAnimator alloc] init];
        self.systemInitialized = YES;
    }
}

- (id) menuItemWithViewController:(UIViewController*)viewController title:(id)title iconName:(id)iconName badge:(NSUInteger)count
{
    return @{
             @"screen"  : viewController,
             @"title"   : title,
             @"menu"    : title,
             @"icon"    : iconName,
             @"badge"   : @(count)
             };
}

#define menuStoryBoardItem(__X__,__icon__) __X__ : [self menuItemWithViewController:[self.storyboard instantiateViewControllerWithIdentifier:__X__] title:__X__ iconName:__icon__ badge:0]
#define menuNibItem(__X__,__icon__) __X__ : [self menuItemWithViewController:[[[NSBundle mainBundle] loadNibNamed:__X__ owner:self options:nil] firstObject] title:__X__ iconName:__icon__ badge:0]

- (BOOL)initializeViewControllers
{
    self.screens = @{
                     menuStoryBoardItem(@"Ads", @"settings"),
                     menuStoryBoardItem(@"User", @"settings"),
                     };
  
    static BOOL init = true;
    [self.screens enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (!obj) {
            init = false;
        }
    }];
    
    return init;
}

- (void) subscribeToChannelCurrentUser
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (!currentInstallation[@"user"]) {
        currentInstallation[@"user"] = [User me];
        [currentInstallation saveInBackground];
        NSLog(@"CURRENT INSTALLATION: saving user to Installation");
    }
    else {
        NSLog(@"CURRENT INSTALLATION: Installation already has user. No need to set");
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    if (self.systemInitialized == NO) {
        [self checkLoginStatusAndProceed];
    }
}

- (void) selectScreenWithID:(NSString *)screen
{
    UINavigationController *nav = self.screens[screen][@"screen"];
    NSString* title = self.screens[screen][@"title"];
    if (nav) {
        self.centerViewController = nav;
        [self.centerViewController setTitle:title];
        [self toggleMenu];
    }
}

- (void) toggleMenu
{
    [self toggleDrawerWithSide:FloatingDrawerSideLeft animated:YES completion:nil];
}

- (void) toggleMenuWithScreenID:(NSString *)screen
{
    [self selectScreenWithID:screen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
