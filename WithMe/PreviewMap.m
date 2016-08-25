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

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 50, 65);
        self.opaque = NO;
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.imageView.image = [UIImage imageNamed:@"location"];
        self.backgroundColor = colorBlue;
        [self addSubview:self.imageView];
        self.centerOffset = CGPointMake(0, -65/2.f);
    }
    return self;
}
@end

@interface PreviewMap ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

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
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationView"];

        if (!pinView)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationView"];
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
