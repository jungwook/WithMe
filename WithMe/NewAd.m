//
//  NewAd.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NewAd.h"
#import "IndentedLabel.h"
#import "MediaView.h"
#import "MediaPicker.h"
#import "LocationPicker.h"

@interface NewAdMediaCell : UICollectionViewCell
@property (assign, nonatomic) UserMedia* userMedia;
@end

@interface NewAdMediaCell()
@property (weak, nonatomic) IBOutlet MediaView *media;
@property (weak, nonatomic) IBOutlet UILabel *comment;

@end

@implementation NewAdMediaCell

- (void)setUserMedia:(UserMedia *)userMedia
{
    [self.media loadMediaFromUserMedia:userMedia];
    self.comment.text = userMedia.comment;
}

@end

@interface NewAd ()
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UITextField *adTitle;
@property (weak, nonatomic) IBOutlet UITextView *adIntro;
@property (weak, nonatomic) IBOutlet IndentedLabel *adCategory;
@property (weak, nonatomic) IBOutlet UILabel *adEndCategory;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *introPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *camera;
@property (weak, nonatomic) IBOutlet UIButton *location;
@property (weak, nonatomic) IBOutlet UILabel *address;

@property (strong, nonatomic)       Ad* ad;
@property (weak, nonatomic)         User *user;
@end

@implementation NewAd

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.user = [User me];
    self.ad = [Ad object];

    self.photo.radius = CGRectGetHeight(self.photo.bounds)/2.0f;
    self.nickname.textColor = self.user.genderColor;
    self.nickname.text = self.user.nickname;
    self.address.textColor = self.user.genderColor;
    self.address.text = @"NOT SET";
    
    [self.photo loadMediaFromUser:self.user];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.adIntro.delegate = self;
    
    [self.camera setTintColor:self.user.genderColor forState:UIControlStateNormal];
    [self.location setTintColor:self.user.genderColor forState:UIControlStateNormal];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelPost:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getLocation:(UIButton*)sender
{
    [LocationPicker pickerOnView:sender titled:@"Where are you?" picked:^(CLLocationCoordinate2D coordinate, NSString *address, UIImage* mapImage)
    {
        self.address.text = address;
        // LOCATION
//        self.ad.location = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        NSData *imageData = UIImageJPEGRepresentation(mapImage, kJPEGCompressionFull);
        NSData *thumbnailData = compressedImageData(imageData, kThumbnailWidth);

        UserMedia *media = [UserMedia object];
        media.isRealMedia = NO;
        media.mediaSize = mapImage.size;
        media.mediaFile = [S3File saveImageData:imageData];
        media.mediaType = kMediaTypePhoto;
        media.isProfileMedia = NO;
        media.comment = address;
        media.thumbailFile = [S3File saveImageData:thumbnailData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
            [self.ad addUniqueObject:media forKey:@"media"];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.ad.media indexOfObject:media] inSection:0]]];
            } completion:nil];
        }];
    }];
}

- (IBAction)tappedOutside:(id)sender
{
    [self.tableView endEditing:YES];
}

#pragma mark - Intro TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    BOOL empty = [textView.text isEqualToString:@""];
    [self showIntroPlaceholder:empty];
}

- (void) showIntroPlaceholder:(BOOL)show
{
    [UIView animateWithDuration:0.25 animations:^{
        self.introPlaceholder.alpha = show;
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Media Collection data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.ad.media.count+1;
}

- (CAAnimation*) shrinkAnimation
{
    
    CABasicAnimation *ta1 =[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    ta1.duration = 0.1;
    ta1.repeatCount = 1;
    ta1.autoreverses = YES;
    ta1.fromValue = @(1);
    ta1.toValue = @(0.99);
    ta1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    ta1.removedOnCompletion = YES;
    
    return ta1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.layer addAnimation:[self shrinkAnimation] forKey:nil];

    if (indexPath.row == self.ad.media.count) {
        [self addNewMedia:nil];
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat w = widthForNumberOfCells(collectionView, (UICollectionViewFlowLayout *) collectionViewLayout, 3);
    return CGSizeMake(w, w);
}

- (IBAction)addNewMedia:(id)sender
{
    [MediaPicker pickMediaOnViewController:self withUserMediaHandler:^(UserMedia *media, BOOL picked) {
        media.isProfileMedia = NO;
        [self.ad addUniqueObject:media forKey:@"media"];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.ad.media indexOfObject:media] inSection:0]]];
        } completion:nil];
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.ad.media.count) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"AddMediaCell" forIndexPath:indexPath];
    } else {
        NewAdMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AdMediaCell" forIndexPath:indexPath];
        cell.userMedia = [self.ad.media objectAtIndex:indexPath.row];
        return cell;
    }
}

@end
