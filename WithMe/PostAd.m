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
#import "DatePicker.h"
#import "ActivityPicker.h"

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
@property (weak, nonatomic) IBOutlet PlaceholderTextView *introTextView;
@property (weak, nonatomic) IBOutlet DateField *dateField;
@property (weak, nonatomic) IBOutlet ActivityField *activityField;

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

- (IBAction)saveAndPostAd:(id)sender
{
    BOOL ret = (self.activityField.activity) && (![self.titleField.text isEqualToString:@""]) && (![self.introTextView.text isEqualToString:@""]);
    
    if (ret) {
        [self updateAdSaveAndDismiss];
    }
    else {
        NSLog(@"FIELDS NOT FILLED");
    }
}

- (void)updateAdSaveAndDismiss
{
    self.ad.title = self.titleField.text;
    self.ad.activity = self.activityField.activity;
    if (self.dateField.date) {
        self.ad.eventDate = self.dateField.date;
    }
    self.ad.intro = self.introTextView.text;
    self.ad.user = [User me];
    self.ad.ourParticipants = self.ourParticipants;
    self.ad.yourParticipants = self.yourParticipants;
    [self.ad addUniqueObjectsFromArray:self.media forKey:@"media"];
    [self.ad addUniqueObjectsFromArray:self.locations forKey:@"locations"];
    [self.ad saveInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Payment
    [self selectedPaymentType:[self.paymentBack viewWithTag:kTagPaymentNone]];
    
    self.dateField.parent = self.tableView;
    self.activityField.parent = self.tableView;
    
    //Ad
    self.ad.user = [User me];
    self.ourParticipants = 1;
    self.yourParticipants = 1;
    
    [self.collectionMedia addAddMoreButtonTitled:@"+ media"];
    [self.collectionMedia setViewController:self];
    [[User me] profileMediaLoaded:^(UserMedia *media) {
        media.comment = @"This is me!";
        [self.media addObject:media];
        [self.collectionMedia setItems:self.media];
    }];
    [self.collectionMedia setDeletionBlock:^(UserMedia* media) {
        [self.media removeObject:media];
        [self.collectionMedia refresh];
    }];
    [self.collectionMedia setAdditionBlock:^() {
        [MediaPicker pickMediaOnViewController:self withUserMediaHandler:^(UserMedia *userMedia, BOOL picked) {
            if (picked) {
                [self.media addObject:userMedia];
                [self.collectionMedia refresh];
            }
        }];
    }];
    
    [self.collectionMap addAddMoreButtonTitled:@"+ location"];
    [self.collectionMap setViewController:self];
    [self.collectionMap setDeletionBlock:^(id item) {
       __LF
        if (item) {
            [self.locations removeObject:item];
            [self.collectionMap refresh];
        }
    }];
    [self.collectionMap setSelectionBlock:^(AdLocation* item) {
       __LF
        [LocationManagerController controllerFromViewController:self
                                                    withHandler:^(AdLocation *adLoc)
        {
            [self.collectionMap refresh];
//            [self.collectionMap setItems:self.ad.locations];
        }
                                                       pinColor:self.collectionMap.buttonColor
                                                 fromAdLocation:item];
    }];
    [self.collectionMap setAdditionBlock:^() {
        __LF
        [LocationManagerController controllerFromViewController:self
                                                    withHandler:^(AdLocation *adLoc)
        {
            if (adLoc) {
                [self.locations addObject:adLoc];
                [self.collectionMap refresh];
            }
        }
                                                       pinColor:self.collectionMap.buttonColor
                                                newLocation:[User me].location];

    }];
    
    [AdLocation adLocationWithLocation:[User me].location
                          spanInMeters:1250
                              pinColor:self.collectionMap.buttonColor
                                  size:self.view.bounds.size
                            completion:^(AdLocation *adLoc)
    {
        adLoc.comment = @"I'm here!";
        [self.locations addObject:adLoc];
        [self.collectionMap setItems:self.locations];
    }];
}

- (IBAction)clearEventDate:(id)sender {
    self.dateField.date = nil;
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
