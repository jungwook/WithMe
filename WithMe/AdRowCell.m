//
//  AdRowCell.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 16..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AdRowCell.h"
#import "QueryManager.h"

@interface AdRowCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) PFQuery *query;
@property (weak, nonatomic) id params;
@end

@implementation AdRowCell

+ (instancetype)new
{
    return [[[NSBundle mainBundle] loadNibNamed:@"AdRowCell" owner:self options:nil] firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupCollectionView];
}

- (void)setupCollectionView
{
    registerCollectionViewCellNib(@"AdCell", self.collectionView);
    registerCollectionViewCellNib(@"AdMiniCell", self.collectionView);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = colorWhite;
}

- (void)viewUserProfile:(User *)user
{
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(viewUserProfile:)]) {
        [self.adDelegate viewUserProfile:user];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Ad *ad = [self.items objectAtIndex:indexPath.row];
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(viewAdDetail:)]) {
        [self.adDelegate viewAdDetail:ad];
    }
}

- (void)setParams:(id)params forRow:(NSInteger)row
{
    _params = params;
    
    PFQuery *query = params[@"query"];
    
    if (!params[@"queryInitiated"]) {
        [params setObject:@(NO) forKey:@"queryInitiated"];
    }
    if (!params[@"visibleRect"]) {
        [params setObject:[NSValue valueWithCGRect:CGRectZero] forKey:@"visibleRect"];
    }
    
    CGRect visibleRect = [params[@"visibleRect"] CGRectValue];
    BOOL queryInitiated = [params[@"queryInitiated"] boolValue];
    
    self.query = query;
    if (!queryInitiated) {
        [self.params setObject:@(YES) forKey:@"queryInitiated"];
        [self.query setLimit:5];
        [QueryManager query:self.query objects:^(NSArray *objects) {
            if (objects.count > 0) {
                [(NSMutableArray*)[self.params objectForKey:@"items"] addObjectsFromArray:objects];
                [self.collectionView reloadData];
            }
        }];
    }
    
    self.titleLabel.text = [self.params objectForKey:@"title"];
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView scrollRectToVisible:visibleRect animated:NO];
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect rect = CGRectMake(scrollView.contentOffset.x,
                             scrollView.contentOffset.y,
                             scrollView.bounds.size.width-1,
                             scrollView.bounds.size.height-1);
    
    [self.params setObject:[NSValue valueWithCGRect:rect] forKey:@"visibleRect"];
}

- (NSArray*)items
{
    return (NSArray*)[self.params objectForKey:@"items"];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.items.count-1) {
        [self.query setSkip:self.items.count];
        [self.query setLimit:5];
        
        [QueryManager query:self.query objects:^(NSArray *objects) {
            if (objects.count>0) {
                [(NSMutableArray*)[self.params objectForKey:@"items"] addObjectsFromArray:objects];
                [self.collectionView reloadData];
            }
        }];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = self.params[@"cellIdentifier"];
    AdBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.ad = [self.items objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [self.params[@"cellSize"] CGSizeValue];
    return size;
    
//    return CGSizeMake(w*ratio.width, h*ratio.height);
}

@end
