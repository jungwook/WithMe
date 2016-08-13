//
//  BaseFunctions.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

#define __LF NSLog(@"%s", __FUNCTION__);

#define kJPEGCompressionLow 0.2f
#define kJPEGCompressionMedium 0.4f
#define kJPEGCompressionDefault 0.6f
#define kJPEGCompressionFull 1.0f
#define kThumbnailWidth 300
#define kVideoThumbnailWidth 600

#define     colorBlue [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1.0f]
#define     appFont(__X__) [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:__X__]
#define     colorWhite [UIColor whiteColor]

CALayer*    drawImageOnLayer(UIImage *image, CGSize size);
UIImage*    scaleImage(UIImage* image, CGSize size);
void        drawImage(UIImage *image, UIView* view);
void        circleizeView(UIView* view, CGFloat percent);
void        roundCorner(UIView* view);
float       heading(PFGeoPoint* fromLoc, PFGeoPoint* toLoc);
float       headingRadians(PFGeoPoint* fromLoc, PFGeoPoint* toLoc);
float       Heading(PFUser* from, PFUser* to);
CGRect      hiveToFrame(CGPoint hive, CGFloat radius, CGFloat inset, CGPoint center);
CGRect      rectForString(NSString *string, UIFont *font, CGFloat maxWidth);

/**
 Creates a compressedImageData of width and ratio'd height from the image represented by data
 
 @param data Data of the image to compress.
 
 @param width Width of the returned image data. Height will be proportionate to the orginal image data.
 
 @return A new image NSData* data.
 */
NSData*     compressedImageData(NSData* data, CGFloat width);
NSString*   randomObjectId();
NSString*   distanceString(double distance);
CGFloat     ampAtIndex(NSUInteger index, NSData* data);
void        setShadowOnView(UIView* view, CGFloat radius, CGFloat opacity);
CGFloat     widthForNumberOfCells(UICollectionView* cv, UICollectionViewFlowLayout *flowLayout, CGFloat cpr);
UIView*     viewWithTag(UIView *view, NSInteger tag);
void        addSubviewAndSetContrainstsOnView(UIView* view, UIView* superView, UIEdgeInsets inset);
void        registerTableViewCellNib(NSString* nibName, UITableView* tableView);
void        registerCollectionViewCellNib(NSString* nibName, UICollectionView* collectionView);
void        registerCollectionViewHeader(NSString* nibName, UICollectionView* collectionView);
void        registerCollectionViewFooter(NSString* nibName, UICollectionView* collectionView);
void        getAddressForPFGeoPoint(PFGeoPoint* location, void (^handler)(NSString* address));
void        getAddressForCLLocation(CLLocation* location, void (^handler)(NSString* address));
UIImage     *imageFromView(UIView * view);
void        setAnchorPoint(CGPoint anchorPoint, CALayer* layer);
void        setImageOnView(UIImage* image, UIView* view);
void        showView(UIView* view, BOOL show);