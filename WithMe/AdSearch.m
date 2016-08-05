//
//  AdSearch.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdSearch.h"
#import "AdCell.h"
#import "UserAds.h"
#import "MultiColumnLayout.h"

@interface AdSearch ()
@end

@implementation AdSearch

static NSString * const kAdCell = @"AdCell";

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.ads = [User categories];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    registerCollectionViewCellNib(kAdCell, self.collectionView);
    [self initializeLayout];
    [self initializeBackgroundAndControls];
}

- (void)initializeBackgroundAndControls
{
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.backgroundView.frame = self.collectionView.bounds;
    self.collectionView.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
}

- (void)initializeLayout
{
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    AdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdCell forIndexPath:indexPath];
    [cell setActivity:[self.ads objectAtIndex:indexPath.row] forRow:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size = widthForNumberOfCells(collectionView, (UICollectionViewFlowLayout *)collectionViewLayout, 3);
    return CGSizeMake(size, size);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdSearch *pushedAdSearch = [[AdSearch alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    id ad = [self.ads objectAtIndex:indexPath.row];
    
    if ([ad isKindOfClass:[NSString class]]) {
        UserAds *userAds = [[UserAds alloc] initWithCollectionViewLayout:[MultiColumnLayout new]];
        userAds.navigationItem.title = ad;
        userAds.endCategory = ad;
        [self.navigationController pushViewController:userAds animated:YES];
    }
    else {
        pushedAdSearch.ads = [ad objectForKey:@"content"];
        pushedAdSearch.navigationItem.title = [ad objectForKey:@"title"];
        [self.navigationController pushViewController:pushedAdSearch animated:YES];
    }
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
