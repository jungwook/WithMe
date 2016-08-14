//
//  QueryManager.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "QueryManager.h"

@interface QueryManagerItem : NSObject
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation QueryManagerItem

+ (instancetype) queryManagerItemWithQuery:(PFQuery *)query items:(NSArray *)items
{
    QueryManagerItem *item = [QueryManagerItem new];
    if (item) {
        item.query = query;
        item.items = [NSMutableArray arrayWithArray:items];
    }
    return item;
}

@end


@interface QueryManager()
@property (nonatomic, strong) NSMutableDictionary *queries;
@end

@implementation QueryManager

+ (instancetype) new
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] initOnce];
    });
    return sharedFile;
}

- (instancetype) initOnce
{
    self = [super init];
    if (self) {
        self.queries = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL) query:(PFQuery* _Nonnull)query named:(NSString* _Nonnull)name;
{
    if ([self.queries objectForKey:name])
        return NO;
    else {
        [self.queries setObject:[QueryManagerItem queryManagerItemWithQuery:query items:[NSMutableArray array]] forKey:name];
        return YES;
    }
}

- (PFQuery*) queryNamed:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    return item.query;
}

- (NSArray*) itemsNamed:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    return item.items;
}

- (void) setItems:(NSArray*)items named:(NSString*)name
{
        QueryManagerItem *item = [self.queries objectForKey:name];
    item.items = [NSMutableArray arrayWithArray:items];
}

- (void) addItems:(NSArray*)items named:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    [item.items addObjectsFromArray:items];
}

+ (void) query:(PFQuery*)query objects:(nonnull QueryBlock)block
{
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
            block(nil);
        }
        else {
            block(objects);
        }
    }];
}

@end
