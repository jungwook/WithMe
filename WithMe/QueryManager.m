//
//  QueryManager.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "QueryManager.h"


@implementation QueryManagerItem

+ (instancetype) queryManagerItemWithQuery:(PFQuery *)query items:(NSArray *)items index:(NSInteger)index
{
    QueryManagerItem *item = [QueryManagerItem new];
    if (item) {
        item.query = query;
        item.items = [NSMutableArray arrayWithArray:items];
        item.indexPathOfLastViewedItem = nil;
        item.index = index;
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

+ (QueryManagerItem*) queryItemNamed:(NSString*)name
{
    return [[QueryManager new].queries objectForKey:name];
}

+ (void) removeQueryItemNamed:(NSString*)name
{
    [[QueryManager new].queries removeObjectForKey:name];
}

- (BOOL) initializeQuery:(PFQuery* _Nonnull)query named:(NSString* _Nonnull)name index:(NSInteger)index;
{
    if ([self.queries objectForKey:name])
        return NO;
    else {
        [self.queries setObject:[QueryManagerItem queryManagerItemWithQuery:query
                                                                      items:[NSMutableArray array]
                                                                      index:index]
                         forKey:name];
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

- (NSInteger) indexNamed:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    return item.index;
}

- (CGRect) visibleRectNamed:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    return item.visibleRect;
}

- (void) setVisibleRect:(CGRect)visibleRect named:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    item.visibleRect = visibleRect;
}

- (NSIndexPath*) indexPathOfLastViewedItemNamed:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    return item.indexPathOfLastViewedItem;
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

- (void) setIndexPathOfLastViewedItem:(NSIndexPath*)indexPathOfLastViewedItem named:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    item.indexPathOfLastViewedItem = indexPathOfLastViewedItem;
}

+ (void) query:(PFQuery*)query objects:(nonnull QueryBlock)block
{
    [query cancel];
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
