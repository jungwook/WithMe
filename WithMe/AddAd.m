//
//  AddAd.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AddAd.h"
#import "IndentedLabel.h"

@interface AddAd ()
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet IndentedLabel *category;
@property (weak, nonatomic) IBOutlet IndentedLabel *endCategory;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UIView *photo;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation AddAd

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (IBAction)tappedOutside:(id)sender {
    [self.view endEditing:YES];
}

- (void)setEndCategoryString:(NSString *)endCategoryString
{
    __LF
    NSLog(@"ENDCAT:%@", endCategoryString);
    UIColor *backgroundColor = [User categoryColorForEndCategory:endCategoryString];
    self.category.text = [User categoryForEndCategory:endCategoryString];
    self.category.backgroundColor = backgroundColor;
    
    self.endCategory.text = endCategoryString;
    self.endCategory.backgroundColor = backgroundColor.darkerColor;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    [self.view setBackgroundColor:kAppColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.blurView setFrame:self.view.bounds];
    [self.blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.blurView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.view insertSubview:self.blurView atIndex:0];
    
    self.photo.radius = MIN(self.photo.bounds.size.height, self.photo.bounds.size.width) / 2.0f;
    self.photo.layer.borderWidth = 3.0f;
    self.photo.layer.borderColor = colorWhite.CGColor;
    
}

- (IBAction)cancelAd:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.user = [User me];
    
    [self.user fetched:^{
        UserMedia *media = self.user.profileMedia;
        
        [S3File getDataFromFile:media.thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            self.photo.layer.contents = (id) [UIImage imageWithData:data].CGImage;
            self.photo.layer.contentsGravity = kCAGravityResizeAspectFill;
        }];
        self.photo.layer.masksToBounds = YES;
        self.photo.layer.borderColor = self.user.genderColor.CGColor;
        self.nickname.textColor = self.user.genderColor;
        
        [self.toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull bbi, NSUInteger idx, BOOL * _Nonnull stop) {
            [bbi setTintColor:self.user.genderColor];
        }];

    }];
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

@end
