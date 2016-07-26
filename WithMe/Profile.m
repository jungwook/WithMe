//
//  Profile.m
//  WithMe
//
//  Created by 한정욱 on 2016. 7. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Profile.h"
#import "UserProfileHeader.h"
#import "AddMoreCell.h"
#import "ProfileMediaCell.h"
#import "ProfileMapCell.h"
#import "MediaPicker.h"

@interface Profile ()
@property (nonatomic) BOOL editable;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) Notifications *notif;
@end

@implementation Profile

static NSString * const reuseIdentifier = @"Cell";
static NSString * const kTitledHeader = @"TitledHeader";
static NSString * const kUserProfileHeader = @"UserProfileHeader";
static NSString * const kProfileMediaCell = @"ProfileMediaCell";
static NSString * const kAddMoreCell = @"AddMoreCell";
static NSString * const kProfileMapCell = @"ProfileMapCell";


- (void) registerCellNib:(NSString*)nibName
{
    [self.collectionView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:nibName];
}

- (void) registerHeaderNib:(NSString*)nibName
{
    [self.collectionView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:nibName];
}

- (void)setUser:(User *)user
{
    _user = user;
    self.editable = self.user.isMe;
    self.navigationItem.title = self.user.nickname;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.notif = [Notifications new];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self registerCellNib:kProfileMediaCell];
    [self registerCellNib:kAddMoreCell];
    [self registerCellNib:kProfileMapCell];
    [self registerHeaderNib:kUserProfileHeader];
    [self registerHeaderNib:kTitledHeader];

    self.user = [User me];

    __weak __typeof(self) welf = self;

    [self.notif setNotification:@"NotifyProfileMediaChanged" forAction:^(id actionParams) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf.collectionView performBatchUpdates:^{
                [welf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kSectionProfileMedia]];
            } completion:nil];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView reloadData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)deleteUserMedia:(UserMedia *)media
{
    __LF
    NSUInteger index = [self.user.sortedMedia indexOfObject:media];
    
    if (media.isProfileMedia) {
        [Notifications notify:@"NotifyProfileMediaDeleted" object:media];
    }
    
    if (index != NSNotFound) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:kSectionProfileMedia];
        [self.user removeObject:media forKey:@"media"];
        [self.user saved:^{
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[path]];
            } completion:nil];
            if (media.isProfileMedia) {
                UserMedia *next = [self.user.sortedMedia firstObject];
                [self.user setProfileMedia:next];
                [Notifications notify:@"NotifyProfileMediaDeleted" object:next];
            }
        }];
    }
}


- (void)addUserMedia:(UserMedia*)userMedia
{
    userMedia.isProfileMedia = NO;
    [self.user addUniqueObject:userMedia forKey:@"media"];
    [self.user saved:^{
        NSUInteger index = [self.user.sortedMedia indexOfObject:userMedia];
        if (index != NSNotFound) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:kSectionProfileMedia];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[path]];
            } completion:nil];
        }
    }];
}

#pragma mark <UICollectionViewDataSource>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionProfileMedia && indexPath.row == self.user.sortedMedia.count) {
        // ADD MORe CELL
        __LF
        [MediaPicker pickMediaOnViewController:nil withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
            [self addUserMedia:userMedia];
        }];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch ((Sections) section) {
        case kSectionProfileMedia:
            return self.user.media.count + self.editable;
        case kSectionUserLocation:
            return 1;
        case kSectionUserLikes:
            return self.user.likes.count;
        case kSectionUserLiked:
            return self.user.likes.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    NSUInteger section = indexPath.section;
    
    switch ((Sections) section) {
        case kSectionProfileMedia:
        {
            if (index == self.user.media.count) {
                AddMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddMoreCell forIndexPath:indexPath];
                cell.radius = 5.0f;
                cell.backgroundColor = colorBlue;
                return cell;
            }
            else {
                ProfileMediaCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProfileMediaCell forIndexPath:indexPath];
                cell.radius = 5.0f;
                cell.backgroundColor = [UIColor blueColor];
                cell.parent = self;
                [cell setMedia:[self.user.sortedMedia objectAtIndex:index]];
                return cell;
            }
        }
        case kSectionUserLocation:
        {
            ProfileMapCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProfileMapCell forIndexPath:indexPath];
            cell.backgroundColor = [UIColor blueColor];
            cell.radius = 5.0f;
            return cell;
        }
        case kSectionUserLikes:
        case kSectionUserLiked: {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
            
            // Configure the cell
            cell.backgroundColor = [UIColor blueColor];
            cell.radius = 5.0f;
            return cell;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch ((Sections) section) {
        case kSectionProfileMedia:
            return CGSizeMake(self.collectionView.bounds.size.width, 300);
        case kSectionUserLocation:
        case kSectionUserLikes:
        case kSectionUserLiked:
            return CGSizeMake(self.collectionView.bounds.size.width, 50);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    __LF
    if (kind != UICollectionElementKindSectionHeader) {
        return nil;
    }
    
    switch ((Sections) indexPath.section) {
        case kSectionProfileMedia: {
            UserProfileHeader* rv = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUserProfileHeader forIndexPath:indexPath];
            [rv setUser:self.user];
            return rv;
        }
        case kSectionUserLikes:
        case kSectionUserLiked:
        case kSectionUserLocation: {
            UICollectionReusableView* rv = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kTitledHeader forIndexPath:indexPath];
            rv.backgroundColor = [UIColor redColor];
            return rv;
        }
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    Sections section = indexPath.section;
    switch (section) {
        case kSectionProfileMedia: {
            layout.minimumLineSpacing = 2;
            layout.minimumInteritemSpacing = 2;
            layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 3);
            return CGSizeMake(w, w);
        }
        case kSectionUserLocation: {
            layout.minimumLineSpacing = 2;
            layout.minimumInteritemSpacing = 2;
            layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 1);
            return CGSizeMake(w, 200);
        }
        case kSectionUserLikes:{
            layout.minimumLineSpacing = 4;
            layout.minimumInteritemSpacing = 4;
            layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 6);
            return CGSizeMake(w, w);
        }
        case kSectionUserLiked:{
            layout.minimumLineSpacing = 4;
            layout.minimumInteritemSpacing = 4;
            layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 6);
            return CGSizeMake(w, w);
        }
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
