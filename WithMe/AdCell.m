//
//  AdCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdCell.h"
@interface AdCell()
@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *categoryOrWithMe;
@property (weak, nonatomic) IBOutlet UILabel *count;
@property (nonatomic, strong) id activity;
@end

@implementation AdCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.layer.cornerRadius = 5.0f;
    self.backgroundView.clipsToBounds = YES;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = YES;
    self.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.backgroundView.backgroundColor = [UIColor redColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
}

-(void) clearCanvas
{
    [self.canvas.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

- (CAAnimation*) labelAnimation
{

    CABasicAnimation *ta1 =[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    ta1.duration = 1;
    ta1.beginTime = arc4random()%100;
    ta1.repeatCount = INFINITY;
    ta1.autoreverses = NO;
    ta1.fromValue = @(0);
    ta1.toValue = @(10);
    ta1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    return ta1;
}

- (void) fillCanvasWith:(NSArray*)subCategories
{
    [self clearCanvas];
    [subCategories enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
        label.text = obj;
        label.font = appFont(14);
        label.frame = rectForString(obj, label.font, INFINITY);
        
        CGFloat w = label.bounds.size.width, h = label.bounds.size.height, W = self.bounds.size.width, H = self.bounds.size.height;
        CGFloat x = arc4random() % MAX((NSInteger) (W-w),1);
        CGFloat y = arc4random() % MAX((NSInteger) (H-h),1);
        
        label.frame = CGRectMake(x, y, w, h);
        [label.layer addAnimation:[self labelAnimation] forKey:nil];
        [self.canvas addSubview:label];
    }];
}

- (UIColor *)darkerColor:(UIColor*)color depth:(NSInteger)depth
{
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * pow(0.9f, depth)
                               alpha:a];
    return nil;
}


- (void)setActivity:(id)activity forRow:(NSInteger)row
{
    _activity = activity;
    UIColor *canvasColor = [self darkerColor:[User categoryColorForEndCategory:activity] depth:row];

    if ([activity isKindOfClass:[NSString class]])
    {
        self.title.attributedText = [self tightLineString:activity font:self.title.font color:colorWhite];
        self.categoryOrWithMe.text = [User categoryForEndCategory:activity];
        self.canvas.backgroundColor = canvasColor;
        self.title.textColor = colorWhite;
        [self countForEndCategory:activity];
    }
    else if ([activity isKindOfClass:[NSDictionary class]]){
        self.title.attributedText = [self tightLineString:activity[@"title"] font:self.title.font color:colorWhite];
        self.categoryOrWithMe.text = @"WITHME";
        self.canvas.backgroundColor = activity[@"color"];
        self.count.text = @(((NSArray*)activity[@"content"]).count).stringValue;
        self.count.attributedText = [self countString:((NSArray*)activity[@"content"]).count postFix:@"\nsub-categories"];
    }
    else {
        self.title.text = @"UNKNOWN";
    }
}

- (NSAttributedString*) tightLineString:(NSString*)title font:(UIFont *)font color:(UIColor *)color
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineHeightMultiple:0.7];
    
    [style setAlignment:NSTextAlignmentCenter];
    
    return [[NSAttributedString alloc] initWithString : [@"\n" stringByAppendingString:[title uppercaseString]]
                                           attributes : @{
                                                          NSKernAttributeName : @2.0,
                                                          NSFontAttributeName : font,
                                                          NSForegroundColorAttributeName : color,
                                                          NSParagraphStyleAttributeName : style,
                                                          }];
}

- (NSAttributedString*) countString:(NSInteger)count postFix:(NSString*)postFix
{
    UIFont *countFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:24];
    UIFont *postFixFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:8];
    
    UIColor *countColor = colorWhite;
    UIColor *postFixColor = countColor.darkerColor;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineHeightMultiple:0.5];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString : @(count).stringValue
                                                                                  attributes : @{
                                                                                                 NSKernAttributeName : @2.0,
                                                                                                 NSFontAttributeName : countFont,
                                                                                                 NSForegroundColorAttributeName : countColor,
                                                                                                 }];
    NSAttributedString *postFixString = [[NSAttributedString alloc] initWithString : postFix
                                                                    attributes : @{
                                                                                   NSKernAttributeName : @2.0,
                                                                                   NSFontAttributeName : postFixFont,
                                                                                   NSForegroundColorAttributeName : postFixColor,
                                                                                   NSParagraphStyleAttributeName : style,
                                                                                   }];
    
    [string appendAttributedString:postFixString];
    return string;
}

- (void) countForEndCategory:(NSString*)endCategory
{
    PFQuery *query = [Ad query];
    [query whereKey:@"category" equalTo:endCategory];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (number>0) {
            self.count.attributedText = [self countString:number postFix:@"\nAds"];
        }
        else {
            self.count.text = nil;
        }
    }];
}

- (NSArray*) subCategories:(NSArray*)ad
{
    NSMutableArray *ret = [NSMutableArray array];
    [ad enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [ret addObject:obj];
        }
        else {
            id title = [obj objectForKey:@"title"];
            [ret addObject:title];
        }
    }];
    return ret;
}

@end
