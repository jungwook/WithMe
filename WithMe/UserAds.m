//
//  UserAds.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserAds.h"

@interface UserAds ()

@end

@implementation UserAds

static NSString * const kAdCell = @"AdCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    registerCollectionViewCellNib(kAdCell, self.collectionView);
    [self initializeMultiColumnLayout];
    [self initializeBackground];
    [self initializeActions];
}

- (void) initializeActions
{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAd:)];
    
    [addButton setTintColor:[UIColor blackColor]];
    
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)initializeBackground
{
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.backgroundView.frame = self.collectionView.bounds;
    self.collectionView.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)initializeMultiColumnLayout
{
    MultiColumnLayout* layout = (MultiColumnLayout*) self.collectionView.collectionViewLayout;
    layout.columnCount = 2;
    layout.minimumColumnSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
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
    CGFloat width = widthForNumberOfCells(collectionView, (UICollectionViewFlowLayout*)collectionViewLayout, collectionViewLayout.columnCount);
    CGFloat height = 150;
    
    return CGSizeMake(width, height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addAd:(id)sender {
    __LF
    
    Ad *ad = [Ad object];
    ad.user = [User me];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdCell forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
