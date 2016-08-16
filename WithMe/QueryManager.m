//
//  QueryManager.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "QueryManager.h"


@implementation QueryManagerItem

+ (instancetype) queryManagerItemWithQuery:(PFQuery *)query items:(NSArray *)items index:(NSInteger)index cellIndentifier:(NSString*)cellIdentifier
{
    QueryManagerItem *item = [QueryManagerItem new];
    if (item) {
        item.query = query;
        item.items = [NSMutableArray arrayWithArray:items];
        item.indexPathOfLastViewedItem = nil;
        item.index = index;
        item.cellIdentifier = cellIdentifier;
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

- (BOOL) initializeQuery:(PFQuery*) query
                   named:(NSString*)name
                   index:(NSInteger)index
         cellIndentifier:(NSString*)cellIndentifier
{
    if ([self.queries objectForKey:name])
        return NO;
    else {
        QueryManagerItem *item = [QueryManagerItem queryManagerItemWithQuery:query
                                                                       items:[NSMutableArray array]
                                                                       index:index
                                                             cellIndentifier:cellIndentifier];
        
        [self.queries setObject:item forKey:name];
        return YES;
    }
}

- (NSString*) cellIndentifierNamed:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    return item.cellIdentifier;
}

- (void) setCellIdentifier:(NSString*)cellIdentifier named:(NSString*)name
{
    QueryManagerItem *item = [self.queries objectForKey:name];
    item.cellIdentifier = cellIdentifier;
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
//            [QueryManager recursiveFetchAllIfNeededInBackground:objects handler:block objects:objects];
//            [PFObject fetchAllIfNeededInBackground:objects block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//                [objects enumerateObjectsUsingBlock:^(PFObject * _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
//                    [[object allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
//                    }];
//                }];
//                block(objects);
//            }];
        }
    }];
}

+ (void)recursiveFetchAllIfNeededInBackground:(NSArray <PFObject*> *)array handler:(QueryBlock)block objects:(NSArray <PFObject*> *)orig
{
    NSAssert(block != nil, @"%s must provide a hander block", __FUNCTION__);
    static NSUInteger totalCount;
    totalCount+= array.count;
    
    [PFObject fetchAllIfNeededInBackground:array block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(PFObject * _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
            [[object allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                id attribute = [object objectForKey:key];
                
                if ([attribute isKindOfClass:[NSArray class]]) {
                    [QueryManager recursiveFetchAllIfNeededInBackground:attribute handler:block objects:orig];
                }
            }];
            totalCount--;
            if (totalCount==0) {
                block(orig);
            }
        }];
    }];
}

@end
