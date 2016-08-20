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
#import "CollectionView.h"
#import "PlaceholderTextView.h"
#import "CategoryPicker.h"

@interface PostAd ()
@property (weak, nonatomic) IBOutlet UIView *paymentBack;
@property (weak, nonatomic) IBOutlet UILabel *ourParticipantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yourParticipantsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s3;
@property (weak, nonatomic) IBOutlet CollectionView *collectionMap;
@property (weak, nonatomic) IBOutlet CollectionView *collectionMedia;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *introTextView;
@property (weak, nonatomic) IBOutlet CategoryPicker *category;

@property (strong, nonatomic) Ad *ad;
@property (nonatomic) NSUInteger ourParticipants;
@property (nonatomic) NSUInteger yourParticipants;
@property (strong, nonatomic) NSMutableArray <UserMedia*> *media;
@property (strong, nonatomic) NSMutableArray <AdLocation*> *locations;
@property (strong, nonatomic) NSMutableDictionary *locationImages;
@property (strong, nonatomic) IBOutlet UIView *headerView;
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

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.category setActivityHandler:^(Activity* activity) {
        NSLog(@"SELECTED:%@", activity);
    }];
    
    //Payment
    [self selectedPaymentType:[self.paymentBack viewWithTag:kTagPaymentNone]];
    
    //Ad
    self.ad.user = [User me];
    self.ourParticipants = 1;
    self.yourParticipants = 1;
    
    [self.collectionMedia addAddMoreButtonTitled:@"+ media"];
    [[User me] profileMediaLoaded:^(UserMedia *media) {
        [self.ad addUniqueObject:media forKey:@"media"];
        [self.ad saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self.collectionMedia setItems:self.ad.media];
        }];
    }];
    
    [self.collectionMap addAddMoreButtonTitled:@"+ location"];
    [self.collectionMap setDeletionBlock:^(id item) {
       __LF
        if (item) {
            [self.ad removeLocation:item];
            [self.ad saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self.collectionMap setItems:self.ad.locations];
            }];
        }
    }];
    [self.collectionMap setSelectionBlock:^(AdLocation* item) {
       __LF
        [LocationManagerController controllerFromViewController:self
                                                    withHandler:^(AdLocation *adLoc) {
                                                        [self.collectionMap setItems:self.ad.locations];
                                                    } pinColor:self.collectionMap.buttonColor
                                                 fromAdLocation:item];
    }];
    
    [self.collectionMap setAditionBlock:^() {
       __LF
        [LocationManagerController controllerFromViewController:self
                                                    withHandler:^(AdLocation *adLoc) {
                                                        if (adLoc) {
                                                            [self.ad addLocation:adLoc];
                                                            [self.ad saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                                [self.collectionMap setItems:self.ad.locations];
                                                            }];
                                                        }
                                                    }
                                                       pinColor:self.collectionMedia.buttonColor
                                                newLocation:[User me].location];

    }];
    
    [AdLocation adLocationWithLocation:[User me].location spanInMeters:1250 pinColor:kCollectionRowColor size:CGSizeMake(170, 170) completion:^(AdLocation *adLoc) {
        [self.ad addLocation:adLoc];
        [self.collectionMap setItems:self.ad.locations];
    }];
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
        
        v.radius = 5.0f;
        v.clipsToBounds = YES;
        
        if (v.tag == sender.tag) {
            self.ad.payment = sender.tag - tagbase;
            [UIView animateWithDuration:0.2 animations:^{
                v.alpha = 1.0f;
                v.backgroundColor = self.ad.paymentTypeColor;
                [self workSpaces:sender.tag layer:v.layer];
            }];
        }
        else {
            [UIView animateWithDuration:0.2 animations:^{
                v.alpha = 0.8f;
                v.layer.transform = CATransform3DIdentity;
                v.backgroundColor = [UIColor lightGrayColor];
            }];
        }
    }
}

- (void)workSpaces:(NSInteger)tag layer:(CALayer *)layer
{
    switch (tag) {
        case kTagPaymentMe:
            self.s2.constant = 2;
            self.s3.constant = 2;
            self.s1.constant = 12;
            layer.transform = CATransform3DTranslate(CATransform3DMakeScale(1.1, 1.1, 1), 2, -1, 0);
            break;
        case kTagPaymentYou:
            self.s1.constant = 10;
            self.s2.constant = 10;
            self.s3.constant = 2;
            layer.transform = CATransform3DTranslate(CATransform3DMakeScale(1.1, 1.1, 1), 0, -1, 0);
            break;
        case kTagPaymentDutch:
            self.s1.constant = 2;
            self.s2.constant = 10;
            self.s3.constant = 10;
            layer.transform = CATransform3DTranslate(CATransform3DMakeScale(1.1, 1.1, 1), 0, -1, 0);
            break;
        case kTagPaymentNone:
            self.s1.constant = 2;
            self.s2.constant = 2;
            self.s3.constant = 12;
            layer.transform = CATransform3DTranslate(CATransform3DMakeScale(1.1, 1.1, 1), -2, -1, 0);
            break;
    }
}

- (IBAction)cancelAd:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
