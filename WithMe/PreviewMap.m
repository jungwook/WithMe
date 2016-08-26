//
//  PreviewMap.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PreviewMap.h"

@interface PointAnnotationView : MKAnnotationView
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PointAnnotationView

- (id)initWithAnnotation:(MKPointAnnotation <MKAnnotation>*)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        const CGFloat factor = 2.0f;
        self.frame = CGRectMake(0, 0, 50/factor, 65/factor);
        self.opaque = NO;
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.imageView.image = [[UIImage imageNamed:@"location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.tintColor = colorBlue;
        [self addSubview:self.imageView];
        self.centerOffset = CGPointMake(0, (-65/2.f)/factor);
        
        getAddressForCoordinates(annotation.coordinate, ^(NSString *address) {
            UILabel *addressLabel = [UILabel new];
            addressLabel.text = address;
            addressLabel.textAlignment = NSTextAlignmentCenter;
            addressLabel.textColor = [UIColor whiteColor];
            addressLabel.font = [UIFont boldSystemFontOfSize:12];
            CGRect rect = rectForString(address, addressLabel.font, 400);
            rect.size.width += 20;
            rect.size.height += 20;
            
            CGRect finalRect = rect;
            finalRect.origin.x -= (CGRectGetWidth(rect)/2.0f-50/factor/2.0f);
            finalRect.origin.y += 40;

            UIVisualEffectView *vev = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            UIVisualEffectView *vib = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
            [vev addSubview:vib];
            vib.frame = rect;
            addressLabel.frame = rect;
            vev.frame = finalRect;
            vev.radius = 4.0f;
            vev.clipsToBounds = YES;
            [vev addSubview:addressLabel];
            [self addSubview:vev];
        });
        
    }
    return self;
}
@end

@interface PreviewMap ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *commentBack;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end

@implementation PreviewMap


- (void)awakeFromNib
{
    [super awakeFromNib];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.adLocation fetched:^{
        self.mapView.delegate = self;
        MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
        anno.coordinate = self.adLocation.coordinates;
        [self.mapView addAnnotation:anno];
        [self.mapView setRegion:MKCoordinateRegionMake(self.adLocation.coordinates, self.adLocation.span) animated:NO];
        self.commentLabel.text = self.adLocation.comment;
        self.commentBack.hidden = !(self.adLocation.comment && ![self.adLocation.comment isEqualToString:@""]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        PointAnnotationView* pinView = (PointAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationView"];

        if (!pinView)
        {
            pinView = [[PointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationView"];
        }
        else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)setAdLocation:(AdLocation *)adLocation
{
    _adLocation = adLocation;
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
