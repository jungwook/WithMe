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
#import "ParallaxView.h"

@interface UserProfile ()
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *editLocationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editProfileMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *withMeLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet ParallaxView *parallax;

@property (strong, nonatomic) LocationManager *locationManager;
@property (nonatomic) BOOL profileChanged;
@end

void getAddressForPFGeoPoint(PFGeoPoint* location, void (^handler)(NSString* address));

@implementation UserProfile

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.locationManager = [LocationManager new];
    self.profileChanged = NO;
}

- (void)setUser:(User *)user
{
    _user = user;
    
    [self setupButtonAppearance];
    [self.photoView setImage:nil];
    [self.user fetched:^{
        self.nicknameLabel.text = self.user.nickname;
        self.ageLabel.text = [NSString stringWithFormat:@"(%@)", self.user.age];
        self.withMeLabel.text = [NSString stringWithFormat:@"Here for: %@", self.user.withMe];
        self.sinceLabel.text = [NSString stringWithFormat:@"Joined since %@", [NSDateFormatter localizedStringFromDate:self.user.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
        self.aboutLabel.text = [NSString stringWithFormat:@"About %@", self.user.nickname];
        
        BOOL introSet = (self.user.introduction && ![self.user.introduction isEqualToString:@""]);
        self.introLabel.text = introSet ? self.user.introduction : @"No introductions...";
        self.introLabel.textColor = introSet ? [UIColor blackColor] : self.editLocationButton.titleLabel.textColor;
        self.genderLabel.text = self.user.genderTypeString;
        self.genderLabel.backgroundColor = self.user.genderColor;
        [self showView:self.photoView show:NO];
        [self.user profileMediaThumbnailLoaded:^(UIImage *image) {
            self.photoView.image = image;
            showView(self.photoView, YES);
        }];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
}

- (void) setupUserLocation
{
    BOOL isMe = self.user.isMe;
    
    if (isMe) {
    }
    if ( (isMe && self.user.location) || (!isMe && self.user.location)) {
        if (self.user.address) {
            self.addressLabel.text = self.user.address;
        }
        else {
            getAddressForPFGeoPoint(self.user.location, ^(NSString *address) {
                self.user.address = address;
                self.addressLabel.text = address;
                [self.user saved:nil];
            });
        }
    }
    else if (!self.user.location) {
        if (isMe) {
            [self pickUserLocationWithTitle:@"Pick your new location"];
        }
        else {
            self.addressLabel.text = @"Location unknown";
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUser:self.user];
    
    [self.tableView reloadData];
}


typedef void(^UserProfileImageLoadedBlock)(UIImage* image);

- (void) showProfileMedia:(UserMedia*)media handler:(UserProfileImageLoadedBlock)handler
{
    [S3File getDataFromFile:media.mediaFile dataBlock:^(NSData *data) {
        if (handler) {
            handler([UIImage imageWithData:data]);
        }
    }];
}

- (void) setupButtonAppearance
{
    BOOL show = self.user.isMe;
    
    self.editPhotoButton.hidden = !show;
    self.editProfileButton.hidden = !show;
    self.editLocationButton.hidden = !show;
    self.editProfileMenuButton.enabled = show;
    
    self.editPhotoButton.radius = self.editPhotoButton.bounds.size.height/2.0f;
    setShadowOnView(self.editPhotoButton, 1.5, 0.5);
    
    [self.editPhotoButton setImage:[[self.editPhotoButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.editPhotoButton setTintColor:colorWhite forState:UIControlStateNormal];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.parallax setScrollOffset:scrollView];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.parallax setNavigationBarProperties:self.navigationController.navigationBar];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    if (self.user == nil) {
        self.user = [User me];
    }
}

- (IBAction)editUserLocation:(id)sender
{
    [self pickUserLocationWithTitle:@"Pick your new location"];
}

- (IBAction)editProfileMedia:(id)sender
{
    [self showView:self.photoView show:NO];
    
    [MediaPicker pickMediaOnViewController:self withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
        __LF
        
        if (picked) {
            [self.user setProfileMedia:userMedia];
            [self.user saved:^{
                [self.user profileMediaThumbnailLoaded:^(UIImage *image) {
                    self.photoView.image = image;
                    showView(self.photoView, YES);
                }];
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }];
        }
        else {
            [self showView:self.photoView show:YES];
        }
    }];
}

- (void) showView:(UIView*)view show:(BOOL)show
{
    view.alpha = !show;
    [UIView animateWithDuration:0.25f animations:^{
        view.alpha = show;
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

- (IBAction)editUserProfile:(id)sender
{
    [self performSegueWithIdentifier:@"EditUser" sender:sender];
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
            return 130;
        }
        else if (indexPath.row == 1) {
            CGFloat w = CGRectGetWidth(self.introLabel.bounds);
            CGFloat y = CGRectGetMinY(self.introLabel.frame);
            
            CGRect rect = rectForString(self.user.introduction, self.introLabel.font, w);
            BOOL introductionNotSet = (!self.user.introduction || [self.user.introduction isEqualToString:@""]);
            return y+CGRectGetHeight(rect)+ (introductionNotSet ? 60 : 20);
        }
        else {
            return 44;
        }
    }
    else {
        return 160;
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
    CGFloat h = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]-8;
    return CGSizeMake(h*4/3, h);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.clipsToBounds = YES;
    UserMedia *media = [self.user.media objectAtIndex:indexPath.row];
    
    [S3File getDataFromFile:media.thumbnailFile dataBlock:^(NSData *data) {
        drawImage([UIImage imageWithData:data], cell);
    }];
    return cell;
}

@end
