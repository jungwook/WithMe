//
//  CategoryPicker.m
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CategoryPicker.h"

@interface CategoryCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) Category* category;
@end

@implementation CategoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [colorWhite colorWithAlphaComponent:1.F];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [self addSubview:self.titleLabel];
        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds), h = CGRectGetHeight(self.bounds), o = 8;
    self.titleLabel.frame = CGRectMake(o, 0, w-o, h);
}

- (void)setCategory:(Category *)category
{
    self.titleLabel.text = category.name.uppercaseString;
}

@end

@interface CategoryPicker()
{
    NSMutableArray <Category *> *categories;
}
@end

@implementation CategoryPicker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        
        [self setupCategories];
        
        [self registerClass:[CategoryCell class] forCellReuseIdentifier:@"CategoryCell"];
        self.rowHeight = 20;
        self.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundView = nil;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void) setupCategories
{
    categories = [NSMutableArray array];
    [categories addObjectsFromArray:[WithMe new].categories];
    Category *allCategory = [Category new];
    allCategory.name = @"ALL CATEGORIES";
    [categories insertObject:allCategory atIndex:0];
    [self reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (self.allCategoryHandler) {
            self.allCategoryHandler(categories.firstObject);
        }
    }
    else {
        if (self.categoryHandler) {
            self.categoryHandler([categories objectAtIndex:indexPath.row]);
        }
    }
    self.selectedHandler();
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    cell.category = [categories objectAtIndex:indexPath.row];
    cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:indexPath.row % 2 ? 0.05 : 0];
    return  cell;
}

@end

@implementation CategoryPickerView

+ (instancetype) categoryPickerWithFrame:(CGRect)frame
{
    CategoryPickerView *picker = [CategoryPickerView new];
    picker.parentFrame = frame;
    picker.frame = [UIApplication sharedApplication].keyWindow.bounds;
    
    [[UIApplication sharedApplication].keyWindow addSubview:picker];
    return picker;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOutside:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UITableView *tableView = self.picker;
    CGPoint touchPoint = [touch locationInView:tableView];
    return ![tableView hitTest:touchPoint withEvent:nil];
}

- (void) tappedOutside:(id)sender
{
    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.picker.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setParentFrame:(CGRect)parentFrame
{
    _parentFrame = parentFrame;
    
    CGFloat x = CGRectGetMinX(parentFrame), y = CGRectGetMaxY(parentFrame)+4, w = CGRectGetWidth(parentFrame), h = 140;
    self.picker = [CategoryPicker new];
    self.picker.frame = CGRectMake(x, y, w, h);
    self.picker.radius = 4.0f;
    
    VoidBlock selectionHandler = ^{
        [self tappedOutside:nil];
    };
    self.picker.selectedHandler = selectionHandler;
    [self addSubview:self.picker];
}

- (void)setCategoryHandler:(CategoryBlock)categoryHandler
{
    self.picker.categoryHandler = categoryHandler;
}

- (void)setAllCategoryHandler:(CategoryBlock)allCategoryHandler
{
    self.picker.allCategoryHandler = allCategoryHandler;
}

@end
