//
//  SlideShow.h
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SlideShowTransitionType) {
    SlideShowTransitionFade,
    SlideShowTransitionSlideVertical,
    SlideShowTransitionSlideHorizontal
};

typedef NS_ENUM(NSInteger, SlideShowGestureType) {
    SlideShowGestureTap,
    SlideShowGestureSwipe,
    SlideShowGestureAll
};

typedef NS_ENUM(NSUInteger, SlideShowPosition) {
    SlideShowPositionTop,
    SlideShowPositionBottom
};

typedef NS_ENUM(NSUInteger, SlideShowState) {
    SlideShowStateStopped,
    SlideShowStateStarted
};

typedef void(^SlideShowBlock)(NSInteger index);

@interface SlideShow : UIView
@property float delay;
@property float transitionDuration;
@property (nonatomic) SlideShowTransitionType transitionType;
@property (nonatomic) UIViewContentMode imagesContentMode;
@property (strong, nonatomic) NSArray *images;
@property (readonly, nonatomic) NSUInteger currentIndex;
@property (copy, nonatomic) SlideShowBlock showingHandler;

- (void) addGesture:(SlideShowGestureType)gestureType;
- (void) removeGestures;
- (void) start;
- (void) stop;
- (void) previous;
- (void) next;

@end

