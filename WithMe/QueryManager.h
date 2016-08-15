//
//  QueryManager.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QueryBlock)(NSArray* objects);

@interface QueryManagerItem : NSObject
@property (nonatomic, strong) PFQuery           *query;
@property (nonatomic, strong) NSMutableArray    *items;
@property (nonatomic)         CGRect            visibleRect;
@property (nonatomic, strong) NSIndexPath       *indexPathOfLastViewedItem;
@property (nonatomic)         NSInteger         index;
@property (nonatomic, strong) NSString          *cellIdentifier;
@end

@interface QueryManager : NSObject
+ (void) query:(PFQuery* )query objects:(QueryBlock)block;
+ (QueryManagerItem* ) queryItemNamed:(NSString* )name;
+ (void) removeQueryItemNamed:(NSString*)name;
- (BOOL) initializeQuery:(PFQuery*) query
                   named:(NSString*)name
                   index:(NSInteger)index
         cellIndentifier:(NSString*)cellIndentifier;

- (PFQuery* ) queryNamed:(NSString* )name;
- (NSArray* ) itemsNamed:(NSString* )name;
- (NSInteger) indexNamed:(NSString*)name;
- (CGRect) visibleRectNamed:(NSString* )name;
- (NSString*) cellIndentifierNamed:(NSString*)name;

- (void) setCellIdentifier:(NSString*)cellIdentifier named:(NSString*)name;
- (void) setItems:(NSArray* )items named:(NSString* )name;
- (void) addItems:(NSArray* )items named:(NSString* )name;
- (void) setVisibleRect:(CGRect)visibleRect named:(NSString* )name;
@end
