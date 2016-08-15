//
//  UserAds.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserAds.h"
#import "AdPostCellV2.h"
#import "RefreshControl.h"
#import "AddAd.h"
#import "NewAd.h"

#define kQueryLimit 20
#define kUpdatedAt @"updatedAt"

@interface UserAds ()
@property (nonatomic, strong) NSMutableArray *ads;
@property (nonatomic, strong) RefreshControl *refresh;
@property (nonatomic, strong) NSDate *lastUpdateAt;
@property (nonatomic)         NSUInteger page;
@property (nonatomic, strong) NSCache *cellHeights;
@end

@implementation UserAds

static NSString * const kAdPostCell = @"AdPostCellV2";

- (void)viewDidLoad {
    [super viewDidLoad];

    registerCollectionViewCellNib(kAdPostCell, self.collectionView);
    
    [self initializePageParameters];
    [self initializeMultiColumnLayout];
    [self initializeBackgroundAndControls];
    [self initializeActions];
 
    self.refresh = [RefreshControl refreshControlWithCompletionBlock:^(RefreshControl *refreshControl) {
        [self loadNewAdsSinceLastPulledDate];
    }];
    
    [self.collectionView addSubview:self.refresh];
    [self loadMoreAds];
}

- (void) initializePageParameters
{
    self.page = 0;
    self.ads = [NSMutableArray array];
    self.cellHeights = [NSCache new];
}

- (PFQuery *) adQuery
{
    NSLog(@"QUERY CATEGORY:%@", self.endCategory);

    PFQuery *query = [Ad query];
    if (self.endCategory && ![self.endCategory isEqualToString:@""]) {
        [query whereKey:@"category" equalTo:self.endCategory];
    }
    return query;
}

- (void) insertLoadedAd:(Ad*)ad
{
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[[self addObject:ad intoSortedArray:self.ads]]];
        self.lastUpdateAt = ((Ad*)[self.ads firstObject]).updatedAt;
    } completion:nil];
}

- (NSIndexPath*) addObject:(id)object intoSortedArray:(NSMutableArray*)array
{
    [array addObject:object];
    [array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:kUpdatedAt ascending:NO]]];
    
    return [NSIndexPath indexPathForRow:[array indexOfObject:object] inSection:0];
}

- (void) loadNewAdsSinceLastPulledDate
{
    __LF
    if (self.lastUpdateAt == nil) {
        self.lastUpdateAt = [NSDate date];
    }
    PFQuery *query = [self adQuery];
    [query whereKey:kUpdatedAt greaterThan:self.lastUpdateAt];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad fetched:^{
                [self insertLoadedAd:ad];
                self.page = self.ads.count / kQueryLimit;
            }];
        }];
        [self.refresh endRefreshing];
    }];
    
    self.lastUpdateAt = [NSDate date];
}

- (void) loadMoreAds
{
    PFQuery *query = [self adQuery];
    [query orderByDescending:kUpdatedAt];
    [query setLimit:kQueryLimit];
    [query setSkip:kQueryLimit*self.page];
    
    [self.refresh beginRefreshing];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(Ad* _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [ad fetched:^{
                [self insertLoadedAd:ad];
            }];
        }];
        self.page++;
        [self.refresh endRefreshing];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == (self.page*kQueryLimit - 1)) {
        [self loadMoreAds];
    }
}

- (void) initializeActions
{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAd:)];
    
    [addButton setTintColor:[UIColor blackColor]];
    
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)initializeBackgroundAndControls
{
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.backgroundView.frame = self.collectionView.bounds;
    self.collectionView.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)initializeMultiColumnLayout
{
    MultiColumnLayout* layout = (MultiColumnLayout*) self.collectionView.collectionViewLayout;
    layout.columnCount = 2;
    layout.minimumColumnSpacing = 8;
    layout.minimumInteritemSpacing = 8;
    
    layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
    //    layout.headerHeight = 10;
    //    layout.footerHeight = 10;
    
    layout.headerInset = UIEdgeInsetsZero;
    layout.footerInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(MultiColumnLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static CGFloat width = 0;
    if (width==0) {
        width = widthForNumberOfCells(collectionView, (UICollectionViewFlowLayout*)collectionViewLayout, collectionViewLayout.columnCount);
    }
    Ad *ad = [self adAtIndexPath:indexPath];
    
    id heightObject = [self.cellHeights objectForKey:ad.objectId];
    if (heightObject) {
        return CGSizeMake(width, [heightObject floatValue]);
    }
    else {
        const CGFloat inset = 8, nInsets = 3, vPhoto = 30, vLabels = 17 + 12 + 12;
        __block CGFloat mediaHeight = 0;
        [ad.media enumerateObjectsUsingBlock:^(UserMedia* _Nonnull media, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat h = floor(width * media.mediaSize.height / media.mediaSize.width);
            mediaHeight += h;
        }];
        return CGSizeMake(width, inset*nInsets+vPhoto+vLabels+mediaHeight);
    }
}

- (Ad*) adAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.ads objectAtIndex:indexPath.row];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addAd:(id)sender
{
    __LF
//    [Ad randomnizeAdAndSaveInBackgroundOfCount:10];
    NSLog(@"END CATEGORY:%@", self.endCategory);

    NewAd *newAd = [self.storyboard instantiateViewControllerWithIdentifier:@"NewAd"];
    newAd.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:newAd animated:YES completion:nil];
    
//    AddAd *addAd = [[[NSBundle mainBundle] loadNibNamed:@"AddAd" owner:self options:nil] firstObject];
//    addAd.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    addAd.endCategoryString = self.endCategory;
//    [self presentViewController:addAd animated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.ads.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdPostCellV2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdPostCell forIndexPath:indexPath];
    Ad *ad = [self.ads objectAtIndex:indexPath.row];
    cell.ad = ad;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
