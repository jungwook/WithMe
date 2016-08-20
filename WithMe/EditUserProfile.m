//
//  EditUserProfile.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "EditUserProfile.h"
#import "MediaPicker.h"
#import "ListField.h"

@interface DeletableCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, strong) UserMedia *media;
@property (nonatomic, weak) id<DeletableCellDelegate> delegate;
@end

@implementation DeletableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.radius = 4.0f;
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.4].CGColor;
    self.layer.borderWidth = 4.0f;
    
    self.activity.hidden = NO;
    [self.activity startAnimating];
    
}

- (void)setMedia:(UserMedia *)media
{
    drawImage(nil, self);
    _media = media;

    [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
        drawImage([UIImage imageWithData:data], self);
        [self.activity stopAnimating];
        self.activity.hidden = YES;
    }];
}

- (IBAction)deleteMedia:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteUserMedia:)]) {
        [self.delegate deleteUserMedia:self.media];
    }
}

@end

@interface EditUserProfile ()
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTF;
@property (weak, nonatomic) IBOutlet ListField *genderTF;
@property (weak, nonatomic) IBOutlet ListField *withMeTF;
@property (weak, nonatomic) IBOutlet ListField *ageTF;
@property (weak, nonatomic) IBOutlet UIButton *updateIntroductionButton;
@end

@implementation EditUserProfile

-(void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setUser:(User *)user
{
    __LF
    
    _user = user;
    
    [self.user fetched:^{
        self.introLabel.text = self.user.introduction;
        self.nicknameTF.text = self.user.nickname;
        self.genderTF.text = self.user.genderTypeString;
        self.withMeTF.text = self.user.withMe;
        self.ageTF.text = self.user.age;
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.user.nickname;
    
    [self.genderTF setPickerForGendersWithHandler:^(id item) {
        [self.user setGenderTypeFromString:item];
    }];
    [self.ageTF setPickerForAgeGroupsWithHandler:^(id item) {
        self.user.age = item;
    }];
    [self.withMeTF setPickerForWithMesWithHandler:^(id item) {
        self.user.withMe = item;
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.user = [User me];
    [self.tableView reloadData];
}

- (IBAction)addMoreMedia:(id)sender
{
    __LF
    [MediaPicker pickMediaOnViewController:self withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
        if (picked) {
            [self.user addUniqueObject:userMedia forKey:@"media"];
            NSInteger index = [self.user.media indexOfObject:userMedia];
            [self.user saved:^{
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                } completion:nil];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (IBAction)saveUserProfile:(id)sender
{
    if (![self.nicknameTF.text isEqualToString:@""]) {
        self.user.nickname = self.nicknameTF.text;
        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.user.media.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserMedia *media = [self.user.media objectAtIndex:indexPath.row];
    
    DeletableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    {
        cell.media = media;
        cell.delegate = self;
    }
    
    return cell;
}

- (IBAction)tappedOutside:(id)sender
{
    [self.tableView endEditing:YES];
}

- (void)deleteUserMedia:(UserMedia *)media
{
    __LF
    NSInteger index = [self.user.media indexOfObject:media];
    
    if (index != NSNotFound) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.user removeObject:media forKey:@"media"];
        [self.user saved:^{
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[path]];
            } completion:nil];
            
            if (media.isProfileMedia) {
                UserMedia *next = [self.user.media firstObject];
                next.isProfileMedia = YES;
                [next saveInBackground];
            }
        }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat h = CGRectGetHeight(collectionView.bounds);
    
    return CGSizeMake(4*h/3, h);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.updateIntroductionButton layoutIfNeeded];
    if (indexPath.section == 0) {
        CGFloat h = CGRectGetHeight(rectForString(self.user.introduction, self.introLabel.font, CGRectGetWidth(self.introLabel.bounds)));
        return h + 140;
    }
    else if (indexPath.section == 1) {
        return 44;
    }
    else {
        return 120;
    }
}

@end
