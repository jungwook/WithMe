//
//  AppDelegate.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse enableLocalDatastore];
    
    [self setupAWSCredentials];
    
    [User registerSubclass];
    [UserMedia registerSubclass];
    [Ad registerSubclass];

    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"WithMe";
        configuration.server = @"http://mondays.kr:1338/WithMe";
        configuration.clientKey = @"WithMe";
    }]];
    
//    [self setupAppearances];
    [self setupAWSDefaultACLs];
    
    return YES;
}

- (void)setupAppearances
{
    UIImage *blue = [UIImage imageNamed:@"blue"];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
//                                                            NSForegroundColorAttributeName: [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1.0f],
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSBackgroundColorAttributeName: [UIColor clearColor],
                                                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:24],
                                                            }];
    
    [[UINavigationBar appearance] setBackgroundImage:blue forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundColor:colorBlue];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTranslucent:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupAWSDefaultACLs
{
    PFACL *defaultACL = [PFACL ACL];
    defaultACL.publicReadAccess = YES;
    defaultACL.publicWriteAccess = YES;
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
}

- (void)setupAWSCredentials
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:cf811cfd-3215-4274-aec5-82040e033bfe"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast2 credentialsProvider:credentialsProvider];
    configuration.maxRetryCount = 3;
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelError;
}

@end

