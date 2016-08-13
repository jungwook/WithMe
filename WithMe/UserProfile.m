//
//  UserProfile.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserProfile.h"
#import "BaseFunctions.h"
#import "LocationManager.h"
#import "MediaPicker.h"
#import "IndentedLabel.h"
#import "LocationPickerController.h"

@interface UserProfile ()
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *editLocationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editProfileButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) LocationManager *locationManager;
@end


void getAddressForPFGeoPoint(PFGeoPoint* location, void (^handler)(NSString* address));

@implementation UserProfile

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.locationManager = [LocationManager new];
}

- (void)setUser:(User *)user
{
    _user = user;
    
    [self setupButtonAppearance];
    [self.photoView setImage:nil];
    [self.user fetched:^{
        self.nicknameLabel.text = self.user.nickname;
        if (self.user.location) {
            if (self.user.address) {
                self.addressLabel.text = self.user.address;
            }
            else {
                getAddressForPFGeoPoint(self.user.location, ^(NSString *address) {
                    self.user.address = address;
                    self.addressLabel.text = address;
                    [self.user saveInBackground];
                });
            }
        }
        else {
            [self pickUserLocationWithTitle:@"Pick your new location"];
        }
        self.sinceLabel.text = [NSString stringWithFormat:@"Joined since %@", [NSDateFormatter localizedStringFromDate:self.user.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
        self.aboutLabel.text = [NSString stringWithFormat:@"About %@", self.user.nickname];
        
        BOOL introSet = (self.user.introduction && ![self.user.introduction isEqualToString:@""]);
        self.introLabel.text = introSet ? self.user.introduction : @"Introduction not set.\nPlease edit profile...";
        self.introLabel.textColor = introSet ? [UIColor blackColor] : self.editLocationButton.titleLabel.textColor;
        self.genderLabel.text = self.user.genderCode;
        self.genderLabel.backgroundColor = self.user.genderColor;
        [self setProfileMediaView:self.user.profileMedia];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUser:self.user];
}

- (void) setProfileMediaView:(UserMedia*)media
{
    [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
        self.photoView.image = [UIImage imageWithData:data];
    }];
}

- (void) setupButtonAppearance
{
    BOOL show = self.user.isMe;
    
    self.editPhotoButton.hidden = !show;
    self.editProfileButton.enabled = show;
    self.editLocationButton.hidden = !show;
    
    self.editPhotoButton.radius = self.editPhotoButton.bounds.size.height/2.0f;
    setShadowOnView(self.editPhotoButton, 1.5, 0.5);
    
    [self.editPhotoButton setImage:[[self.editPhotoButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.editPhotoButton setTintColor:colorWhite forState:UIControlStateNormal];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    if (self.user == nil) {
        self.user = [User me];
    }
}

- (IBAction)editUserLocation:(id)sender {
    [self pickUserLocationWithTitle:@"Pick your new location"];
}

- (IBAction)editProfileMedia:(id)sender
{
    [MediaPicker pickMediaOnViewController:self withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
        if (picked) {
            [self.user setProfileMedia:userMedia];
            [self.user saved:^{
                [self setProfileMediaView:self.user.profileMedia];
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }];
        }
    }];
}

- (void)pickUserLocationWithTitle:(NSString*)title
{
    id pick = [LocationPickerController pickerWithLocationPickedHandler:^(CLLocationCoordinate2D location, NSString *addressString) {
        self.user.location = [PFGeoPoint geoPointWithLatitude:location.latitude longitude:location.longitude];
        self.user.locationUdateAt = [NSDate date];
        self.user.address = addressString;
        [self.user saved:nil];
        self.addressLabel.text = addressString;
    } withInitialLocation:self.user.location presentFromViewController:self title:title];
    
    [self presentViewController:pick animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 100;
        }
        else if (indexPath.row == 1) {
            CGFloat w = CGRectGetWidth(self.introLabel.bounds);
            CGFloat y = CGRectGetMinY(self.introLabel.frame);
            
            CGRect rect = rectForString(self.user.introduction, self.introLabel.font, w);
            return y+CGRectGetHeight(rect)+20;
        }
        else {
            return 44;
        }
    }
    else {
        return 120;
//        CGFloat w = CGRectGetWidth(self.collectionView.bounds)-28-10;
//        return w*3/4;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat h = CGRectGetHeight(collectionView.bounds) - 20;
    return CGSizeMake(h*4/3, h);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.radius = 4.0f;
    cell.clipsToBounds = YES;
    cell.layer.borderColor = [self.user.genderColor colorWithAlphaComponent:0.4].CGColor;
    cell.layer.borderWidth = 2.0f;
    UserMedia *media = [self.user.media objectAtIndex:indexPath.row];
    
    [S3File getDataFromFile:media.thumbailFile dataBlock:^(NSData *data) {
        drawImage([UIImage imageWithData:data], cell);
    }];
    return cell;
}

@end
