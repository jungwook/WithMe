//
//  PreviewAd.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PreviewAd.h"
#import "IndentedLabel.h"
#import "CollectionView.h"

@interface PreviewAd ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *categoryLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *activityLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *paymentLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *participantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet IndentedLabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet CollectionView *mediaCollection;
@property (weak, nonatomic) IBOutlet UIImageView *mapView;
@end

@implementation PreviewAd

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)setAd:(Ad *)ad
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


@end
