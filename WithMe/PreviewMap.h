//
//  PreviewMap.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ModalViewController.h"

@interface PreviewMap : ModalViewController <MKMapViewDelegate>
@property (nonatomic, strong) AdLocation *adLocation;
@end
