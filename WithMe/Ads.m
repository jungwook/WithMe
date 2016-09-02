//
//  Ads.m
//  WithMe
//
//  Created by 한정욱 on 2016. 9. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Ads.h"
#import "UserMediaView.h"
#import "AppDelegate.h"
#import "CategoryPicker.h"
#import "PageFormView.h"

@interface AdsCell : UICollectionViewCell <UserMediaViewDelegate>
@property (nonatomic, strong) Ad *ad;
@end

@interface AdsCell()
@property (weak, nonatomic) IBOutlet UserMediaView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *photoLoader;

@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (strong, nonatomic) NSArray <UIImage *> *mediaImages;
@end

@implementation AdsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *borderColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    
    self.genderLabel.layer.borderColor = borderColor.CGColor;
    self.genderLabel.layer.borderWidth = 1.f;
    
    self.photoView.layer.borderColor = borderColor.CGColor;
    self.photoView.layer.borderWidth = 1.f;

    self.mapImageView.layer.borderColor = borderColor.CGColor;
    self.mapImageView.layer.borderWidth = 1.f;

    self.loader.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    self.mapImageView.alpha = 0.0f;
}

- (void)setAd:(Ad *)ad
{
    _ad = ad;
    
    self.imageView.image = nil;
    self.mediaImages = nil;
    self.imageView.delegate = nil;
    self.photoView.image = [UIImage imageNamed:@"face"];
    
    self.mapImageView.alpha = 0;
    
    [self.loader startAnimating];
    [self.photoLoader startAnimating];
    
    self.categoryLabel.text = ad.activity.category.name.uppercaseString;
    self.activityLabel.text = ad.activity.name.uppercaseString;
    self.introLabel.text = ad.intro;
    self.titleLabel.text = ad.title;
    self.distanceLabel.text = @(@([ad.adLocation.location distanceInKilometersTo:[User me].location]).integerValue).stringValue;
    
    [ad.adLocation mapIconImageWithSize:self.mapImageView.bounds.size handler:^(UIImage *image) {
        self.mapImageView.image = image;
        showView(self.mapImageView, YES);
    }];
    
    [ad fetched:^{
        self.nicknameLabel.text = ad.user.nickname.uppercaseString;
        self.genderLabel.text = ad.user.genderCode.uppercaseString;
        self.genderLabel.backgroundColor = ad.user.genderColor;
        self.genderLabel.textInsets = UIEdgeInsetsZero;
        [ad.user profileMediaThumbnailLoaded:^(UIImage *image) {
            self.photoView.image = image;
            [self.photoLoader stopAnimating];
        }];
    }];
    
    [ad mediaImagesLoaded:^(NSArray *array) {
        self.mediaImages = array;
        self.imageView.delegate = self;
    }];
    [ad firstMediaImageLoaded:^(UIImage *image) {
        self.imageView.mainImage = image;
        [self.loader stopAnimating];
    }];
}

- (NSUInteger)numberOfImagesInImageView:(UserMediaView *)imageView
{
    return self.mediaImages.count;
}

- (UIImage *)imageView:(UserMediaView *)imageView imageForIndex:(NSUInteger)index
{
    return [self.mediaImages objectAtIndex:index];
}

@end

@interface Ads ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *byTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *byLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *categoriesButton;
@property (nonatomic, strong) NSMutableArray <Ad *> *ads;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic) BOOL byTime;
@property (nonatomic) NSInteger lastIndex;
@end

@implementation Ads

static NSInteger const kQueryLimit = 10;
static NSString * const reuseIdentifier = @"AdsCell";

- (UICollectionViewFlowLayout*) layout
{
    return (id) self.collectionView.collectionViewLayout;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (PFQuery *)byTimeQuery
{
    PFQuery *query = [Ad query];
    query.limit = kQueryLimit;
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"media"];
    [query includeKey:@"adLocation"];
    [query includeKey:@"activity"];
    return query;
}

- (PFQuery *)byLocationQuery
{
    PFQuery *query = [Ad query];
    query.limit = kQueryLimit;
    [query whereKey:@"location" nearGeoPoint:[User me].location];
    [query includeKey:@"media"];
    [query includeKey:@"adLocation"];
    [query includeKey:@"activity"];
    return query;
}

- (void)setByTime:(BOOL)byTime
{
    _byTime = byTime;
    
    self.byTimeButton.enabled = !self.byTime;
    self.byLocationButton.enabled = self.byTime;
    
    self.query = self.byTime ? self.byTimeQuery : self.byLocationQuery;
}

- (IBAction)queryByTime:(id)sender
{
    [self.collectionView performBatchUpdates:^{
        [self.ads removeAllObjects];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        self.byTime = YES;
        [self.categoriesButton setTitle:@"ALL CATEGORIES" forState:UIControlStateNormal];
    }];
}

- (IBAction)queryByLocation:(id)sender
{
    [self.collectionView performBatchUpdates:^{
        [self.ads removeAllObjects];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        self.byTime = NO;
        [self.categoriesButton setTitle:@"ALL CATEGORIES" forState:UIControlStateNormal];
    }];
}

- (void)setQuery:(PFQuery *)query
{
    _query = query;
    
    self.lastIndex = 0;
    [self.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable ads, NSError * _Nullable error) {
        self.ads = [NSMutableArray arrayWithArray:ads];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
}

- (PFQuery *) currentQuery
{
    return self.byTime ? self.byTimeQuery : self.byLocationQuery;
}

- (IBAction)selectCategory:(UIButton*) sender
{
    CategoryPickerView *pv = [CategoryPickerView categoryPickerWithFrame:sender.frame];
    [pv setAllCategoryHandler:^(Category* category) {
        [sender setTitle:category.name.uppercaseString forState:UIControlStateNormal];
        self.query = self.currentQuery;
    }];
    [pv setCategoryHandler:^(Category *category) {
        [sender setTitle:category.name.uppercaseString forState:UIControlStateNormal];
        
        PFQuery *newQuery = self.currentQuery;
        [newQuery whereKey:@"activity" containedIn:category.activities];
        self.query = newQuery;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.byTime = YES;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.layout.itemSize = self.collectionView.bounds.size;
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    
    [self.collectionView reloadData];
    
    self.joinButton.layer.borderColor = colorWhite.CGColor;
    self.joinButton.layer.borderWidth = 1.F;
    
    self.chatButton.layer.borderColor = colorWhite.CGColor;
    self.chatButton.layer.borderWidth = 1.F;
}

- (IBAction)doJoinRequest:(id)sender
{
    [PageFormView new];
}

- (IBAction)toggleMenu:(id)sender
{
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]).menuController toggleMenu];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static BOOL passed = NO;
    
    CGFloat x = scrollView.contentOffset.x;
    if (x < -60 && passed == NO) {
        passed = YES;
        [self loadRecentAds];
    }
    if (passed && x > -60) {
        passed = NO;
    }
}

- (void) loadRecentAds
{
    __LF
    NSDate *firstCreatedAt = self.ads.firstObject.createdAt;
    [self.query cancel];
    [self.query setSkip:0];
    [self.query orderByDescending:@"createdAt"];
    if (firstCreatedAt) {
        [self.query whereKey:@"createdAt" greaterThan:firstCreatedAt];
    }
    [self.query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (number > 0) {
            [self.query setLimit:number];
            NSMutableArray *newAds = [NSMutableArray array];
            [self.query findObjectsInBackgroundWithBlock:^(NSArray <Ad *> * _Nullable ads, NSError * _Nullable error) {
                [ads enumerateObjectsUsingBlock:^(Ad * _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (!alreadyLoaded(ad, self.ads)) {
                        [newAds addObject:ad];
                    }
                }];
                [self.collectionView performBatchUpdates:^{
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newAds.count)];
                    [self.ads insertObjects:newAds atIndexes:indexSet];
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                } completion:nil];
            }];
        }
    }];
}

- (void) loadMoreAds
{
    __LF
    [self.query cancel];
    [self.query setSkip:self.ads.count];
    [self.query setLimit:kQueryLimit];
    
    [self.query findObjectsInBackgroundWithBlock:^(NSArray <Ad *>* _Nullable ads, NSError * _Nullable error) {
        if (ads.count > 0) {
            NSMutableArray *indexPaths = [NSMutableArray array];
            [ads enumerateObjectsUsingBlock:^(Ad * _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!alreadyLoaded(ad, self.ads)) {
                    [self.ads addObject:ad];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:[self.ads indexOfObject:ad] inSection:0]];
                }
            }];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            } completion:nil];
        }
    }];
}

BOOL alreadyLoaded(Ad* ad, NSArray <Ad *> *ads)
{
    __block BOOL inside = NO;
    
    [ads enumerateObjectsUsingBlock:^(Ad * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.objectId isEqualToString:ad.objectId]) {
            *stop = YES;
            inside = YES;
        }
    }];
    return inside;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    __LF
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.ads.count -1) {
        if (self.lastIndex < indexPath.row) {
            self.lastIndex = indexPath.row;
            [self loadMoreAds];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    __LF
    return self.ads.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AdsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.ad = [self.ads objectAtIndex:indexPath.row];
    return cell;
}

@end
