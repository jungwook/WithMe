//
//  BaseFunctions.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "BaseFunctions.h"

CALayer* drawImageOnLayer(UIImage *image, CGSize size)
{
    CALayer *layer = [CALayer layer];
    [layer setBounds:CGRectMake(0, 0, size.width, size.height)];
    [layer setContents:(id)image.CGImage];
    [layer setContentsGravity:kCAGravityResizeAspect];
    [layer setMasksToBounds:YES];
    return layer;
}

UIImage* scaleImage(UIImage* image, CGSize size) {
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
    [drawImageOnLayer(image,size) renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
}

void drawImage(UIImage *image, UIView* view)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [view.layer setContents:(id)image.CGImage];
        [view.layer setContentsGravity:kCAGravityResizeAspectFill];
        [view.layer setMasksToBounds:YES];
    });
}

void circleizeView(UIView* view, CGFloat percent)
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}

void roundCorner(UIView* view)
{
    view.layer.cornerRadius = 2.0f;
    view.layer.masksToBounds = YES;
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

float heading(PFGeoPoint* fromLoc, PFGeoPoint* toLoc)
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

float headingRadians(PFGeoPoint* fromLoc, PFGeoPoint* toLoc)
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    return atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng));
}

float Heading(User* from, User* to)
{
    PFGeoPoint *fromLoc = from.location;
    PFGeoPoint *toLoc = to.location;
    if (from != to && (fromLoc.latitude == toLoc.latitude && fromLoc.longitude == toLoc.longitude)) {
        printf("SAME LOCATION FOR:%s - %s\n", [from.nickname UTF8String], [to.nickname UTF8String]);
    }
    return heading(fromLoc, toLoc);
}

CGRect hiveToFrame(CGPoint hive, CGFloat radius, CGFloat inset, CGPoint center)
{
    const int offx[] = { 1, -1, -2, -1, 1, 2};
    const int offy[] = { 1, 1, 0, -1, -1, 0};
    
    int level = hive.x;
    int quad = hive.y;
    
    int sx = level, sy = -level;
    
    for (int i=0; i<quad; i++) {
        int side = (int) i / (level);
        int ox = offx[side];
        int oy = offy[side];
        
        sx += ox;
        sy += oy;
    }
    
    const CGFloat f = 2-inset/radius;
    const CGFloat f2 = f*1.154;
    
    CGFloat x = center.x+(sx-0.5f)*radius;
    CGFloat y = center.y+(sy-0.5f)*radius*1.5*1.154;
    
    return CGRectMake(x, y, f*radius, f2*radius);
}

/**
 Creates a compressedImageData of width and ratio'd height from the image represented by data
 
 @param data Data of the image to compress.
 
 @param width Width of the returned image data. Height will be proportionate to the orginal image data.
 
 @return A new image NSData* data.
 */
NSData* compressedImageData(NSData* data, CGFloat width)
{
    UIImage *image = [UIImage imageWithData:data];
    const CGFloat thumbnailWidth = width;
    CGFloat thumbnailHeight = image.size.width ? thumbnailWidth * image.size.height / image.size.width : 200;
    image = scaleImage(image, CGSizeMake(thumbnailWidth, thumbnailHeight));
    return UIImageJPEGRepresentation(image, kJPEGCompressionMedium);
}

CGRect rectForString(NSString *string, UIFont *font, CGFloat maxWidth)
{
//    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    CGRect rect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(maxWidth, 0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName: font,
                                                                } context:nil]);
    
    rect = CGRectMake(0, 0, floor(rect.size.width), floor(rect.size.height));
    return rect;
}

NSString* randomObjectId()
{
    int length = 8;
    char *base62chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    
    NSString *code = @"";
    
    for (int i=0; i<length; i++) {
        int rand = arc4random_uniform(36);
        code = [code stringByAppendingString:[NSString stringWithFormat:@"%c", base62chars[rand]]];
    }
    
    return code;
}

NSString* distanceString(double distance)
{
    if (distance > 500) {
        return [NSString stringWithFormat:@"FAR"];
    }
    else if (distance < 1.0f) {
        return [NSString stringWithFormat:@"%.0fm", distance*1000];
    }
    else {
        return [NSString stringWithFormat:@"%.0fkm", distance];
    }
}

CGFloat ampAtIndex(NSUInteger index, NSData* data)
{
    static int c = 0;
    
    if (index >= data.length)
        return 0;
    
    NSData *d = [data subdataWithRange:NSMakeRange(index, 1)];
    [d getBytes:&c length:1];
    CGFloat ret = ((CGFloat)c) / 256.0f;
    return ret;
}

void setShadowOnView(UIView* view, CGFloat radius, CGFloat opacity)
{
    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.radius].CGPath;
    view.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = opacity;
}


CGFloat widthForNumberOfCells(UICollectionView* cv, UICollectionViewFlowLayout *flowLayout, CGFloat cpr)
{
    CGFloat width = (CGRectGetWidth(cv.bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (cpr - 1))/cpr;
    
    return floor(width);
}

UIView* viewWithTag(UIView *view, NSInteger tag)
{
    __block UIView *retView = nil;
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == tag) {
            retView = obj;
            *stop = YES;
        }
    }];
    return retView;
}

void addSubviewAndSetContrainstsOnView(UIView* view, UIView* superView, UIEdgeInsets inset)
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addSubview:view];
    [superView layoutIfNeeded];
    [[view.topAnchor constraintEqualToAnchor:superView.topAnchor constant:inset.top] setActive:YES];
    [[view.bottomAnchor constraintEqualToAnchor:superView.bottomAnchor constant:-inset.bottom] setActive:YES];
    [[view.leadingAnchor constraintEqualToAnchor:superView.leadingAnchor constant:inset.left] setActive:YES];
    [[view.trailingAnchor constraintEqualToAnchor:superView.trailingAnchor constant:-inset.right] setActive:YES];
    
    [view layoutIfNeeded];
}

void registerCollectionViewCellNib(NSString* nibName, UICollectionView* collectionView)
{
    [collectionView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:nibName];
}

void registerCollectionViewHeader(NSString* nibName, UICollectionView* collectionView)
{
    [collectionView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:nibName];
}

UIImage *imageFromView(UIView * view)
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

void registerCollectionViewFooter(NSString* nibName, UICollectionView* collectionView)
{
    [collectionView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:nibName];
}

void registerTableViewCellNib(NSString* nibName, UITableView* tableView)
{
    [tableView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forCellReuseIdentifier:nibName];
}

void getAddressForPFGeoPoint(PFGeoPoint* location, void (^handler)(NSString* address))
{
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    getAddressForCLLocation(currentLocation, handler);
}

void getAddressForCLLocation(CLLocation* location, void (^handler)(NSString* address))
{
    __LF
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"COMP HANDLER");
        if (error) {
            NSLog(@"ERROR:%@", error.localizedDescription);
            if (handler) {
                handler(nil);
            }
        }
        else {
            NSString *address = @"Address Not Found";
            if (error) {
                NSLog(@"failed with error: %@", error);
                if (handler) {
                    handler(address);
                }
                return;
            }
            
            if (placemarks.count > 0) {
                CLPlacemark* placemark = [placemarks firstObject];
                id dic = placemark.addressDictionary;
                id state = dic[@"State"];
                id city = dic[@"City"];
                id street = dic[@"Street"];
                
                NSMutableArray *addressDic = [NSMutableArray array];
                if (state) {
                    [addressDic addObject:state];
                }
                if (city) {
                    [addressDic addObject:city];
                }
                if (street) {
                    [addressDic addObject:street];
                }
                address = [addressDic componentsJoinedByString:@" "];
            }
            if (handler) {
                handler(address);
            }
        }
    }];
}

void setAnchorPoint(CGPoint anchorPoint, CALayer* layer)
{
    CGPoint newPoint = CGPointMake(layer.bounds.size.width * anchorPoint.x,
                                   layer.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(layer.bounds.size.width * layer.anchorPoint.x,
                                   layer.bounds.size.height * layer.anchorPoint.y);
    
    CGPoint position = layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    layer.position = position;
    layer.anchorPoint = anchorPoint;
}

void setImageOnView(UIImage* image, UIView* view)
{
    view.layer.contents = (id) image.CGImage;
    view.layer.contentsGravity = kCAGravityResizeAspectFill;
}

void showView(UIView* view, BOOL show)
{
    view.alpha = !show;
    [UIView animateWithDuration:0.25f animations:^{
        view.alpha = show;
    }];
}


