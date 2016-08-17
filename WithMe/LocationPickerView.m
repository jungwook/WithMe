//
//  LocationPickerView.m
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "LocationPickerView.h"
#import "LocationManager.h"
#import "GradientView.h"
#import "UIImage+ImageWithColor.h"

@interface LocationPickerView() 
@property (weak, nonatomic)     IBOutlet UILabel *initializing;
@property (weak, nonatomic)     IBOutlet UIView *shadowBack;
@property (weak, nonatomic)     IBOutlet UIView *pickerView;
@property (weak, nonatomic)     IBOutlet MKMapView *mapView;
@property (weak, nonatomic)     IBOutlet UIView *menuView;
@property (weak, nonatomic)     IBOutlet UIView *bottomView;
@property (weak, nonatomic)     IBOutlet UIButton *centerPoint;
@property (weak, nonatomic)     IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)     IBOutlet UILabel *address;
@property (weak, nonatomic)     IBOutlet UIButton *saveButton;
@property (weak, nonatomic)     IBOutlet UIButton *closeButton;
@property (weak, nonatomic)     IBOutlet UISearchBar *searchBar;
@property (nonatomic)           PickerPosition position;
@property (nonatomic)           CGRect senderRect;
@property (nonatomic)           CGRect windowRect;
@property (nonatomic, strong)   CAShapeLayer *borderLayer;
@property (nonatomic, strong)   CAShapeLayer *maskLayer;
@property (weak, nonatomic)     IBOutlet NSLayoutConstraint *leadingInset;
@property (weak, nonatomic)     IBOutlet NSLayoutConstraint *topInset;
@property (strong, nonatomic)   LocationManager *locationManager;
@property (nonatomic)           BOOL dirty;
@end

@implementation LocationPickerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.locationManager = [LocationManager new];
    
    self.menuView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    self.menuView.layer.shadowOffset = CGSizeZero;
    self.menuView.layer.shadowRadius = 1.5f;
    self.menuView.layer.shadowOpacity = 0.3f;
    
    self.maskLayer = [CAShapeLayer new];
    self.borderLayer = [CAShapeLayer new];
    self.borderLayer.lineWidth = 2.0f;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;

    
    self.shadowBack.backgroundColor = [UIColor clearColor];
    [self.layer addSublayer:self.borderLayer];
    self.pickerView.layer.mask = self.maskLayer;
    
    self.mapView.delegate = self;
    self.mapView.alpha = 0.0f;
    self.centerPoint.alpha = 0.0f;
    
    self.searchBar.delegate = self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [[CLGeocoder new] geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        
        CLPlacemark *placemark = [placemarks firstObject];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 1500, 1500);
        [self.mapView setRegion:region animated:YES];
    }];
}

-(void)setTextColor:(UIColor *)textColor
{
    self.address.textColor = textColor;
    self.titleLabel.textColor = textColor;
    [self.saveButton setTitleColor:textColor forState:UIControlStateNormal];
    [self.closeButton setTitleColor:textColor forState:UIControlStateNormal];
}

-(void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.menuView.backgroundColor = self.tintColor;
    self.bottomView.backgroundColor = self.tintColor;
    self.borderLayer.strokeColor = self.tintColor.CGColor;
    [self.centerPoint setTintColor:self.tintColor forState:UIControlStateNormal];
    self.searchBar.barTintColor = self.tintColor;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (UIImage*) imageNamed:(NSString*)name colored:(UIColor*)color imageWidth:(CGFloat) width
{
    UIImage *newImage = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    CGSize size = CGSizeMake(width, width*newImage.size.height/newImage.size.width);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale); {
        [color set];
        [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)saveAndClose:(id)sender
{
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:self.defaultSnapshotOptions];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        [self.parent saveAndCloseWithLocation:self.mapView.centerCoordinate
                                      address:self.address.text
                                        image:[self mapImageUsingSnapshot:snapshot usingPinNamed:@"location"]];
    }];
    self.initializing.text = @"Saving location...";
    [self showMapAndCenter:NO];
}

- (IBAction)close:(id)sender {
    [self.parent closeAndKill];
}

- (void)setPosition:(PickerPosition)position fromSenderRect:(CGRect)senderRect windowRect:(CGRect)windowRect
{
    _position = position;
    _senderRect = senderRect;
    _windowRect = windowRect;
    
    self.initializing.text = @"Initializing...";
    
    [self layoutIfNeeded];
    
    UIBezierPath *maskPath = [self pathWithPosition:self.position];
    self.maskLayer.path = maskPath.CGPath;
    self.borderLayer.frame = self.shadowBack.frame;
    self.borderLayer.path = maskPath.CGPath;
    
    // set shadow for the view
    
    self.shadowBack.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    self.shadowBack.layer.shadowOffset = CGSizeZero;
    self.shadowBack.layer.shadowRadius = 2.5f;
    self.shadowBack.layer.shadowOpacity = 0.5f;
    self.shadowBack.layer.shadowPath = maskPath.CGPath;

    // set shadow underneath the menubar.
    self.menuView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.menuView.bounds].CGPath;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.locationManager.currentLocation.coordinate, 500, 500)];
    
    self.centerPoint.layer.shadowColor = [UIColor blackColor].CGColor;
    self.centerPoint.layer.shadowOffset = CGSizeZero;
    self.centerPoint.layer.shadowRadius = 1.5f;
    self.centerPoint.layer.shadowOpacity = 0.4f;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
//    MKPointAnnotation *anno = [MKPointAnnotation new];
//    anno.coordinate = self.locationManager.currentLocation.coordinate;
//    [self.mapView addAnnotation:anno];
}

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
//{
//    if ([annotation isKindOfClass:[MKPointAnnotation class]])
//    {
//        
//        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"UserAnnotationView"];
//        
//        if (!pinView)
//        {
//            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"UserAnnotationView"];
//            //            MKPointAnnotation *anno = (MKPointAnnotation*) annotation;
//            //            [pinView.photoView setImage:anno.image];
//        }
//        else {
//            pinView.annotation = annotation;
//        }
//        return pinView;
//    }
//    return nil;
//}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    __LF
    if (self.dirty) {
        [self showMapAndCenter:YES];
    }
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    getAddressForCLLocation([[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude], ^(NSString *address) {
        self.address.text = address;
    });
}

- (void)showMapAndCenter:(BOOL)show
{
    [UIView animateWithDuration:0.3 animations:^{
        self.mapView.alpha = show;
        self.centerPoint.alpha = show;
    }];
}

- (UIBezierPath*) pathWithPosition:(PickerPosition)position
{
    const CGFloat radius = 8; //round radius
    const CGFloat arrowIndent = 7; //triangle indent
    
    CGFloat l = (position == kPickerPositionRight) ? 8 : 0;
    CGFloat r = (position == kPickerPositionLeft) ? 8 : 0;
    CGFloat t = (position == kPickerPositionBottom || position == kPickerPositionTop) ? 8 : 0;
    CGFloat b = (position == kPickerPositionTop || position == kPickerPositionBottom) ? 8 : 0;
    
    CGFloat w = CGRectGetWidth(self.pickerView.frame);
    CGFloat h = CGRectGetHeight(self.pickerView.frame);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(l, t+radius)];
    [maskPath addQuadCurveToPoint:CGPointMake(l+radius, t) controlPoint:CGPointMake(l, t)];
    
    // TOP INDENT
    if (self.position == kPickerPositionBottom) {
        CGFloat cx = CGRectGetMidX(self.senderRect);
        CGFloat x = CGRectGetMinX(self.frame)+self.leadingInset.constant;
        CGFloat f = (cx-x)/w;
        
        CGPoint anchor = CGPointMake(w*f, MAX(t-arrowIndent,0));
        CGPoint anchorPoint = CGPointMake(f, MAX(t-arrowIndent,0)/h);
        [maskPath addLineToPoint:CGPointMake(w*f-arrowIndent, t)];
        [maskPath addLineToPoint:anchor];
        [maskPath addLineToPoint:CGPointMake(w*f+arrowIndent, t)];
        setAnchorPoint(anchorPoint, self.layer);
    }
    
    [maskPath addLineToPoint:CGPointMake(w-r-radius, t)];
    [maskPath addQuadCurveToPoint:CGPointMake(w-r, t+radius) controlPoint:CGPointMake(w-r, t)];
    
    // RIGHT INDENT
    if (self.position == kPickerPositionLeft) {
        CGFloat cy = CGRectGetMidY(self.senderRect);
        CGFloat y = CGRectGetMinY(self.frame)+self.topInset.constant;
        CGFloat f = (cy-y)/w;
        
        CGPoint anchor = CGPointMake(MIN(w-r+arrowIndent,w), h*f);
        CGPoint anchorPoint = CGPointMake(MIN(w-r+arrowIndent,w)/w, f);
        [maskPath addLineToPoint:CGPointMake(w-r, h*f-arrowIndent)];
        [maskPath addLineToPoint:anchor];
        [maskPath addLineToPoint:CGPointMake(w-r, h*f+arrowIndent)];
        setAnchorPoint(anchorPoint, self.layer);
    }
    
    [maskPath addLineToPoint:CGPointMake(w-r, h-b-radius)];
    [maskPath addQuadCurveToPoint:CGPointMake(w-radius-r, h-b) controlPoint:CGPointMake(w-r, h-b)];
    
    // BOTTOM INDENT
    if (self.position == kPickerPositionTop) {
        CGFloat cx = CGRectGetMidX(self.senderRect);
        CGFloat x = CGRectGetMinX(self.frame)+self.leadingInset.constant;
        CGFloat f = (cx-x)/w;

        CGPoint anchor = CGPointMake(w*f, MIN(h-(b-arrowIndent), h));
        CGPoint anchorPoint = CGPointMake(f, MIN(h-(b-arrowIndent), h)/h);
        [maskPath addLineToPoint:CGPointMake(w*f+arrowIndent, h-b)];
        [maskPath addLineToPoint:anchor];
        [maskPath addLineToPoint:CGPointMake(w*f-arrowIndent, h-b)];
        setAnchorPoint(anchorPoint, self.layer);
    }
    
    [maskPath addLineToPoint:CGPointMake(l+radius, h-b)];
    [maskPath addQuadCurveToPoint:CGPointMake(l, h-b-radius) controlPoint:CGPointMake(l, h-b)];
    
    // LEFT INDENT
    if (self.position == kPickerPositionRight) {
        CGFloat cy = CGRectGetMidY(self.senderRect);
        CGFloat y = CGRectGetMinY(self.frame)+self.topInset.constant;
        CGFloat f = (cy-y)/w;
        
        CGPoint anchor = CGPointMake(MAX(l-arrowIndent,0), h*f);
        CGPoint anchorPoint = CGPointMake(MAX(l-arrowIndent,0)/w, f);
        [maskPath addLineToPoint:CGPointMake(l, h*f+arrowIndent)];
        [maskPath addLineToPoint:anchor];
        [maskPath addLineToPoint:CGPointMake(l, h*f-arrowIndent)];
        setAnchorPoint(anchorPoint, self.layer);
    }
    
    [maskPath addLineToPoint:CGPointMake(l, t+radius)];
    
    return maskPath;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    [UIView animateWithDuration:0.25 animations:^{
        self.mapView.alpha = fullyRendered;
        self.centerPoint.alpha = fullyRendered;
        self.dirty = YES;
    }];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    __LF;
}

- (MKMapSnapshotOptions*) defaultSnapshotOptions
{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.mapView.frame.size;
    return options;
}

- (UIImage*)mapImageUsingSnapshot:(MKMapSnapshot*)snapshot usingPinNamed:(NSString*)name
{
    UIImage *image = snapshot.image;
    CGPoint point = [snapshot pointForCoordinate:self.mapView.centerCoordinate];
    
    UIImage *pinImage = [self imageNamed:name colored:self.tintColor imageWidth:30];
    UIImage *compositeImage = nil;
    UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
    {
        [image drawAtPoint:CGPointZero];
        
        CGRect visibleRect = CGRectMake(0, 0, image.size.width, image.size.height);
        if (CGRectContainsPoint(visibleRect, point)) {
            point.x = point.x - (pinImage.size.width / 2.0f);
            point.y = point.y - (pinImage.size.height);
            [pinImage drawAtPoint:point];
        }
        compositeImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return compositeImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
