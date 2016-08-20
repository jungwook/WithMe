//
//  PostAd.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PostAd.h"
#import "MediaPicker.h"
#import "LocationManagerController.h"
#import "CollectionRow.h"

typedef void(^DeleteMediaBlock)(UserMedia* media);
typedef void(^DeleteLocationBlock)(AdLocation* location);
typedef UIImage*(^ReturnImageBlock)(void);

@interface LocationCell : UICollectionViewCell
@property (nonatomic, weak) AdLocation *location;
@property (nonatomic, copy) DeleteLocationBlock deletionBlock;
@property (weak, nonatomic) IBOutlet UIButton *trash;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation LocationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.trash setImage:[[self.trash imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.trash.radius = 15;
    setShadowOnView(self.trash, 2, 0.5);
}

- (IBAction)deleteLocation:(id)sender {
    if (self.deletionBlock) {
        self.deletionBlock(self.location);
    }
}

- (void)setLocation:(AdLocation *)location withDeletionHandler:(DeleteLocationBlock)deletionBlock withImage:(ReturnImageBlock)imageBlock
{
    _location = location;
    _deletionBlock = deletionBlock;
    
    self.imageView.image = imageBlock();
}
@end

@interface MediaCell : UICollectionViewCell
@property (nonatomic, weak) UserMedia *media;
@property (nonatomic, copy) DeleteMediaBlock deletionBlock;
@property (weak, nonatomic) IBOutlet UIButton *trash;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void) setMedia:(UserMedia *)media withDeletionHandler:(DeleteMediaBlock)deletionBlock;
@end

@implementation MediaCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.trash setImage:[[self.trash imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.trash.radius = 15;
    setShadowOnView(self.trash, 2, 0.5);
}

- (void)setMedia:(UserMedia *)media withDeletionHandler:(DeleteMediaBlock)deletionBlock
{
    _media = media;
    _deletionBlock = deletionBlock;
    
    self.imageView.image = nil;
    [media thumbnailLoaded:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

- (IBAction)deleteMedia:(id)sender
{
    if (self.deletionBlock) {
        self.deletionBlock(self.media);
    }
}

@end

@interface PostAd ()
@property (weak, nonatomic) IBOutlet UIView *paymentBack;
@property (weak, nonatomic) IBOutlet UILabel *ourParticipantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yourParticipantsLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollection;
@property (weak, nonatomic) IBOutlet UICollectionView *mapCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s3;
@property (weak, nonatomic) IBOutlet CollectionRow *mapRow;


@property (strong, nonatomic) Ad *ad;
@property (nonatomic) NSUInteger ourParticipants;
@property (nonatomic) NSUInteger yourParticipants;
@property (strong, nonatomic) NSMutableArray <UserMedia*> *media;
@property (strong, nonatomic) NSMutableArray <AdLocation*> *locations;
@property (strong, nonatomic) NSMutableDictionary *locationImages;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@end

@implementation PostAd

enum {
    kTagPaymentNone = 1000,
    kTagPaymentMe,
    kTagPaymentYou,
    kTagPaymentDutch,
};

enum {
    kTagButtonOurParticipants = 0,
    kTagButtonYourParticipants,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Payment
    [self selectedPaymentType:[self.paymentBack viewWithTag:kTagPaymentNone]];
    
    //Ad
    self.ad.user = [User me];
    self.ourParticipants = 1;
    self.yourParticipants = 1;
    
    self.mediaCollection.delegate = self;
    self.mediaCollection.dataSource = self;
    
    self.mapCollection.delegate = self;
    self.mapCollection.dataSource = self;

    [[User me] profileMediaLoaded:^(UserMedia *media) {
        [self addMediaToCollection:media];
    }];
    
    [[User me].adLocation mapImageUsingSpanInMeters:1250
                                           pinColor:[UIColor blackColor]
                                               size:CGSizeMake(170, 170)
                                            handler:^(UIImage *image)
    {
//        [self addLocationToCollection:[User me].adLocation usingImage:image];
    }];
    
    [AdLocation adLocationWithLocation:[User me].location spanInMeters:1250 pinColor:kCollectionRowColor size:CGSizeMake(170, 170) completion:^(AdLocation *adLoc) {
        [self.ad addUniqueObject:adLoc forKey:@"locations"];
        NSLog(@"mapRow:%@", self.mapRow);
        [self.mapRow setItems:self.ad.locations];
    }];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.ad = [Ad object];
    self.ourParticipants = 1;
    self.yourParticipants = 1;
    self.media = [NSMutableArray array];
    self.locations = [NSMutableArray array];
    self.locationImages = [NSMutableDictionary dictionary];
}

- (void)setOurParticipants:(NSUInteger)ourParticipants
{
    _ourParticipants = ourParticipants;
    self.ourParticipantsLabel.text = [NSString stringWithFormat:@"WE'RE %ld", ourParticipants];
    self.ad.ourParticipants = ourParticipants;
}

- (void)setYourParticipants:(NSUInteger)yourParticipants
{
    _yourParticipants = yourParticipants;
    self.yourParticipantsLabel.text = [NSString stringWithFormat:@"WANT %ld MORE", yourParticipants];
    self.ad.yourParticipants = yourParticipants;
}

- (IBAction)increaseParticipants:(UIButton *)sender {
    if (sender.tag == kTagButtonOurParticipants) {
        self.ourParticipants++;
    }
    if (sender.tag == kTagButtonYourParticipants) {
        self.yourParticipants++;
    }
    [sender.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

- (IBAction)decreaseParticipants:(UIButton *)sender
{
    if (sender.tag == kTagButtonOurParticipants) {
        self.ourParticipants = MAX(self.ourParticipants-1, 1);
    }
    if (sender.tag == kTagButtonYourParticipants) {
        self.yourParticipants = MAX(self.yourParticipants-1, 1);
    }
    [sender.layer addAnimation:buttonPressedAnimation() forKey:nil];
}

- (IBAction)tappedOutside:(id)sender
{
    [self.tableView endEditing:YES];
}

- (IBAction)selectedPaymentType:(UIButton*)sender
{
    const NSInteger tagbase = 1000;
    
    [self.tableView endEditing:YES];
    
    UIView *su = sender.superview;
    
    for (int i=kTagPaymentNone; i<=kTagPaymentDutch; i++)
    {
        UIButton *v = [su viewWithTag:i];
        if (v.tag == sender.tag) {
            self.ad.payment = sender.tag - tagbase;
            [UIView animateWithDuration:0.2 animations:^{
                v.alpha = 1.0f;
                v.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(1.1, 1.1, 1), 0, -1, 0);
                v.backgroundColor = self.ad.paymentTypeColor;
                [self workSpaces:sender.tag];
            }];
        }
        else {
            [UIView animateWithDuration:0.2 animations:^{
                v.alpha = 0.8f;
                v.layer.transform = CATransform3DIdentity;
                v.backgroundColor = [UIColor lightGrayColor];
                [self workSpaces:sender.tag];
            }];
        }
    }
    
}
- (void)workSpaces:(NSInteger) tag
{
    switch (tag) {
        case kTagPaymentMe:
            self.s2.constant = 2;
            self.s3.constant = 2;
            self.s1.constant = 6;
            break;
        case kTagPaymentYou:
            self.s1.constant = 6;
            self.s2.constant = 6;
            self.s3.constant = 2;
            break;
        case kTagPaymentDutch:
            self.s1.constant = 2;
            self.s2.constant = 6;
            self.s3.constant = 6;
            break;
            
        case kTagPaymentNone:
            self.s1.constant = 2;
            self.s2.constant = 2;
            self.s3.constant = 6;
            break;
    }
}

- (IBAction)cancelAd:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addMediaToCollection:(UserMedia*)media
{
    [self.media addObject:media];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.media indexOfObject:media] inSection:0];
    [self.mediaCollection performBatchUpdates:^{
        [self.mediaCollection insertItemsAtIndexPaths:@[indexPath]];
    } completion:nil];
    [self.mediaCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (void)removeMediaFromCollection:(UserMedia*)media
{
    NSInteger index = [self.media indexOfObject:media];
    [self.mediaCollection performBatchUpdates:^{
        [self.media removeObjectAtIndex:index];
        [self.mediaCollection deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:nil];
}

- (void) addLocationToCollection:(AdLocation*)adLoc usingImage:(UIImage*)image
{
    [self.locations addObject:adLoc];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.locations indexOfObject:adLoc] inSection:0];
    [self.mapCollection performBatchUpdates:^{
        [self.locationImages setObject:image forKey:adLoc.location.description];
        [self.mapCollection insertItemsAtIndexPaths:@[indexPath]];
    } completion:nil];
    [self.mapCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (void) removeLocationFromCollection:(AdLocation*)location
{
    NSInteger index = [self.locations indexOfObject:location];
    [self.mapCollection performBatchUpdates:^{
        [self.locations removeObjectAtIndex:index];
        [self.mapCollection deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:nil];
}

- (IBAction)addMedia:(id)sender
{
    [MediaPicker pickMediaOnViewController:self withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
        if (picked && userMedia) {
            [self addMediaToCollection:userMedia];
        }
    }];
}

- (IBAction)addLocation:(id)sender
{
    __LF
//    [LocationManagerController controllerFromViewController:self
//                                                withHandler:^(AdLocation *adLoc, UIImage *image) {
//                                                    if (adLoc) {
//                                                        [self addLocationToCollection:adLoc usingImage:image];
//                                                    }
//                                                }
//                                                   pinColor:[UIColor blackColor]
//                                            initialLocation:(PFGeoPoint *)[User me].location];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
//    if (collectionView == self.mapCollection) {
//        AdLocation *adLoc = [self.locations objectAtIndex:indexPath.row];
//        [LocationManagerController controllerFromViewController:self
//                                                    withHandler:^(AdLocation *newLoc, UIImage *image)
//        {
//            if (newLoc) {
//                [self.locationImages removeObjectForKey:adLoc.location.description];
//                
//                adLoc.location = newLoc.location;
//                adLoc.address = newLoc.address;
//                adLoc.locationType = newLoc.locationType;
//                [adLoc saveInBackground];
//
//                if (image) {
//                    [self.locationImages setObject:image forKey:adLoc.location.description];
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.locations indexOfObject:adLoc] inSection:0];
//                    [collectionView performBatchUpdates:^{
//                        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//                    } completion:nil];
//                }
//            }
//        }
//                                                       pinColor:[UIColor blackColor]
//                                                initialLocation:adLoc.location];
//    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 44;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.mapCollection)
        return self.locations.count;
    else
        return self.media.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.mapCollection) {
        AdLocation* adLoc = [self.locations objectAtIndex:indexPath.row];
        
        LocationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LocationCell" forIndexPath:indexPath];
        [cell setLocation:adLoc withDeletionHandler:^(AdLocation *location) {
            [self removeLocationFromCollection:location];
        } withImage:^UIImage *{
            return [self.locationImages objectForKey:adLoc.location.description];
        }];
        return cell;
    }
    else {
        MediaCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
        [cell setMedia:[self.media objectAtIndex:indexPath.row] withDeletionHandler:^(UserMedia *media) {
            [self removeMediaFromCollection:media];
        }];
        return cell;
    }
}

@end
