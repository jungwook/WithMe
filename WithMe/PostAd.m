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
#import "PlaceholderTextView.h"
#import "CategoryPicker.h"
#import "DatePicker.h"
#import "ActivityPicker.h"
#import "AdMediaCollection.h"

@interface PostAd ()
@property (weak, nonatomic) IBOutlet UIView *paymentBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *s3;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *introTextView;
@property (weak, nonatomic) IBOutlet DateField *dateField;
@property (weak, nonatomic) IBOutlet ActivityField *activityField;
@property (weak, nonatomic) IBOutlet UIImageView *locationView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *commentBack;
@property (weak, nonatomic) IBOutlet UIView *addressBack;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet AdMediaCollection *adMediaCollection;
@property (strong, nonatomic) AdLocation *adLocation;
@property (strong, nonatomic) NSMutableDictionary *locationImages;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@end

@implementation PostAd

const NSInteger tagbase = 1000;

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
    
//    self.media = [NSMutableArray array];
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
    else {
        [self.ad removeObjectForKey:@"eventDate"];
    }
    
    self.ad.intro = self.introTextView.text;
    [self.ad setAdLocationWithLocation:self.adLocation];

    if (self.ad.media.count > 0) {
        [self.ad removeObjectsInArray:self.ad.media forKey:@"media"];
    }
    [self.ad saved:^{
        self.ad.media = self.adMediaCollection.media;
        [self.ad saveAndNotify:^{
            NSLog(@"AD SAVED AND NOTIFIED");
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (UIButton*) paymentButtonWithPayment:(PaymentType)payment
{
    __block UIButton *retButton = nil;
    [self.paymentBack.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            if (obj.tag == payment+tagbase) {
                *stop = YES;
                retButton = obj;
            }
        }
    }];
    return retButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.ad) {
        self.ad = [Ad object];
        self.ad.user = [User me];
    }
    
    //Payment
    [self selectedPaymentType:[self paymentButtonWithPayment:self.ad.payment]];
    
    self.dateField.parent = self.tableView;
    self.activityField.parent = self.tableView;
    
    // Collection Media
    self.adMediaCollection.parentController = self;
    self.adMediaCollection.editable = self.ad.isMine;
    self.adMediaCollection.ad = self.ad;
    
    [self.commentButton setImage:[[self.commentButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.commentButton setTintColor:colorWhite forState:UIControlStateNormal];
    

    [AdLocation adLocationWithLocation:self.ad.adLocation ? self.ad.adLocation.location : [User me].location
                          spanInMeters:1250
                              pinColor:colorBlue
                                  size:self.locationView.bounds.size
                            completion:^(AdLocation *adLoc)
     {
         adLoc.comment = self.ad.adLocation ? self.ad.adLocation.comment : @"I'm here!";
         self.adLocation = adLoc;
     }];
    
    self.titleField.text = self.ad.title;
    self.activityField.activity = self.ad.activity;
    self.dateField.date = self.ad.eventDate;
    self.introTextView.text = self.ad.intro;
}

- (IBAction)updateComment:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter a comment!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.commentLabel.text;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *comment = [[alert.textFields firstObject].text uppercaseString];
        self.adLocation.comment = comment;
        self.commentLabel.text = comment;
        showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)updateLocation:(id)sender
{
    [self.locationView.layer addAnimation:buttonPressedAnimation() forKey:nil];
    [LocationManagerController controllerFromViewController:self withHandler:^(AdLocation *adLoc) {
        if (adLoc) {
            self.adLocation = adLoc;
        }
    } pinColor:colorBlue fromAdLocation:self.adLocation];
}

- (void)setAdLocation:(AdLocation *)adLocation
{
    _adLocation = adLocation;
    [S3File getImageFromFile:adLocation.thumbnailFile imageBlock:^(UIImage *image) {
        self.locationView.image = image;
    }];
    self.addressLabel.text = adLocation.address;
    self.commentLabel.text = adLocation.comment ? [adLocation.comment uppercaseString] : @"";
    showView(self.commentBack, ![self.commentLabel.text isEqualToString:@""]);
}

- (IBAction)clearEventDate:(id)sender {
    self.dateField.date = nil;
}

- (IBAction)tappedOutside:(id)sender
{
    [self.tableView endEditing:YES];
}

- (IBAction)selectedPaymentType:(UIButton*)sender
{
    if (!sender)
        return;
    
    [self.tableView endEditing:YES];
    
    for (int i=kTagPaymentNone; i<=kTagPaymentDutch; i++)
    {
        UIButton *v = [sender.superview viewWithTag:i];
        
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
                v.backgroundColor = [colorBlue.lighterColor.lighterColor colorWithAlphaComponent:0.5];
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
