//
//  SectionObject.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SectionObject.h"

@implementation SectionObject

+ (instancetype) sectionObjectWithIdentifier:(NSString*)identifier
                                     section:(NSInteger)section
                                       title:(NSString*)title
                                    subTitle:(NSString*)subTitle
                                  emptyTitle:(NSString*)emptyTitle
                                       image:(UIImage *)image
                                       items:(NSArray *)items
{
    SectionObject *o = [SectionObject new];
    if (o) {
        o.identifier = identifier;
        o.section = section;
        o.title = title;
        o.subTitle = subTitle;
        o.emptyTitle = emptyTitle;
        o.image = image;
        o.items = [NSMutableArray arrayWithArray:items];
    }
    return o;
}

@end
