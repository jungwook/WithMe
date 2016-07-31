//
//  WithMeEngine.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "WithMeEngine.h"

@interface WithMeEngine()
@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) NSURL *systemPath;
@end

@implementation WithMeEngine

+ (instancetype) engine
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] initOnce];
    });
    return sharedFile;
}

#define SYSTEM_PATH_COMPONENT @"Engine"
#define SYSTEM_COMPONENT @"EngineParameters"

- (instancetype)initOnce
{
    self = [super init];
    if (self) {
        self.initialized = NO;
        
        self.systemPath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:SYSTEM_PATH_COMPONENT] URLByAppendingPathComponent:SYSTEM_COMPONENT];
        
        self.activities = [NSArray arrayWithContentsOfURL:self.systemPath];
        if (!self.activities.count || self.activities.count == 0) {
            self.activities = [User activities];
            BOOL ret = [self.activities writeToURL:self.systemPath atomically:YES];
            NSLog(@"Activities initialized once %ssuccessfully", ret ? "" : "UN");
        }
    }
    return self;
}

- (void) loadActivitiesFromRemote
{
    PFQuery *query = [PFQuery queryWithClassName:@"WithMeEngine"];
    [query whereKey:@"version" equalTo:[WithMeEngine version]];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        PFObject *latest = [objects firstObject];
        self.activities = [latest objectForKey:@"activities"];
        if (!self.activities.count || self.activities.count == 0) {
            self.activities = [User activities];
        }
        else {
            PFObject *latest = [objects firstObject];
            NSString* version = [latest objectForKey:@"version"];
            self.activities = [latest objectForKey:@"activities"];
            
            [self saveActivitiesLocallyForVersion:version];
        }
    }];
}

- (void) saveActivitiesLocallyForVersion:(NSString*) version;
{
    id dic = @{ @"version" : version, @"activities" : self.activities };
    
    BOOL ret = [dic writeToURL:self.systemPath atomically:YES];
    NSLog(@"Activities initialized once %ssuccessfully with default activities", ret ? "" : "UN");
}

+ (NSString*) version
{
    return @"0.1";
}

@end

