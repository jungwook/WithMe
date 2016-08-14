//
//  SlideShow.m
//

#import "SlideShow.h"

#define kSwipeTransitionDuration 0.25 // default timing

typedef NS_ENUM(NSInteger, SlideShowSlideMode) {
    SlideShowSlideModeForward,
    SlideShowSlideModeBackward
};

@interface SlideShow()
@property (nonatomic) BOOL isAnimating;
@property (strong, nonatomic)   UIImageView * topImageView;
@property (strong, nonatomic)   UIImageView * bottomImageView;
@property (strong, nonatomic)   NSTimer *timer;
@end

@implementation SlideShow
@synthesize delay;
@synthesize transitionDuration;
@synthesize transitionType;

#pragma mark - Inits

- (void)awakeFromNib
{
    [self setDefaultValues];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    // Do not reposition the embedded imageViews.
    frame.origin.x = 0;
    frame.origin.y = 0;

    _topImageView.frame = frame;
    _bottomImageView.frame = frame;
}

- (void) setDefaultValues
{
    self.clipsToBounds = YES;
    _currentIndex = 0;
    delay = 3;

    transitionDuration = 1;
    transitionType = SlideShowTransitionFade;
    _isAnimating = NO;

    _topImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _bottomImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _topImageView.autoresizingMask = _bottomImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _topImageView.clipsToBounds = YES;
    _bottomImageView.clipsToBounds = YES;
    [self setImagesContentMode:UIViewContentModeScaleAspectFit];

    [_bottomImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_bottomImageView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":_bottomImageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":_bottomImageView}]];

    [_topImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_topImageView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":_topImageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":_topImageView}]];

    _topImageView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Get / Set

- (UIImage*) imageForPosition:(SlideShowPosition)position {
    return (position == SlideShowPositionTop) ? _topImageView.image : _bottomImageView.image;
}

- (void) setImagesContentMode:(UIViewContentMode)mode
{
    _topImageView.contentMode = mode;
    _bottomImageView.contentMode = mode;
}

- (UIViewContentMode) imagesContentMode
{
    return _topImageView.contentMode;
}

- (void) populateImageView:(UIImageView*)imageView andIndex:(NSUInteger)index
{
    imageView.image = [self.images objectAtIndex:index];
}

#pragma mark - Actions

- (void)setImages:(NSArray *)images
{
    _images = images;
    if (self.images.count > 0) {
        [self populateImageView:_topImageView andIndex:0];
        if (self.images.count > 1) {
            [self populateImageView:_bottomImageView andIndex:1];
        }
    }
}

- (void) start
{
    [self next];
}

- (void) stop
{
    self.timer = nil;
}

- (void)dealloc
{
    [self stop];
}

- (void) next
{
    NSInteger count = self.images.count;
    
    if(! _isAnimating && count>1) {

        // Next Image
        NSUInteger nextIndex = (_currentIndex+1)%count;
        [self populateImageView:_topImageView andIndex:_currentIndex];
        [self populateImageView:_bottomImageView andIndex:nextIndex];
        _currentIndex = nextIndex;

        // Animate
        switch (transitionType) {
            case SlideShowTransitionFade:
                [self animateFade];
                break;

            case SlideShowTransitionSlideHorizontal:
                [self animateSlideHorizontal:SlideShowSlideModeForward];
                break;

            case SlideShowTransitionSlideVertical:
                [self animateSlideVertical:SlideShowSlideModeForward];
                break;
        }
    }
}

- (void) previous
{
    NSInteger count = self.images.count;
    
    if(! _isAnimating && count>1)
    {
        NSUInteger prevIndex;
        if(_currentIndex == 0){
            prevIndex = count - 1;
        }else{
            prevIndex = (_currentIndex-1)%count;
        }
        [self populateImageView:_topImageView andIndex:_currentIndex];
        [self populateImageView:_bottomImageView andIndex:prevIndex];
        _currentIndex = prevIndex;

        // Animate
        switch (transitionType) {
            case SlideShowTransitionFade:
                [self animateFade];
                break;

            case SlideShowTransitionSlideHorizontal:
                [self animateSlideHorizontal:SlideShowSlideModeBackward];
                break;

            case SlideShowTransitionSlideVertical:
                [self animateSlideVertical:SlideShowSlideModeBackward];
                break;
        }
    }
}

#pragma mark - Animation logic

- (void) animateFade
{
    _isAnimating = YES;

    [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _topImageView.alpha = 0;
    } completion:^(BOOL finished) {
        _topImageView.image = _bottomImageView.image;
        _topImageView.alpha = 1;
        _isAnimating = NO;
        if (self.showingHandler) {
            self.showingHandler(self.currentIndex);
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.delay target:self selector:@selector(next) userInfo:nil repeats:NO];
    }];
}

- (void) animateSlideHorizontal:(SlideShowSlideMode) mode
{
    _isAnimating = YES;

    if(mode == SlideShowSlideModeBackward){
        _bottomImageView.transform = CGAffineTransformMakeTranslation(- _bottomImageView.frame.size.width, 0);
    }else if(mode == SlideShowSlideModeForward){
        _bottomImageView.transform = CGAffineTransformMakeTranslation(_bottomImageView.frame.size.width, 0);
    }

    [UIView animateWithDuration:self.transitionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if(mode == SlideShowSlideModeBackward){
            _topImageView.transform = CGAffineTransformMakeTranslation( _topImageView.frame.size.width, 0);
            _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
        }else if(mode == SlideShowSlideModeForward){
            _topImageView.transform = CGAffineTransformMakeTranslation(- _topImageView.frame.size.width, 0);
            _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
        }
    } completion:^(BOOL finished) {
        _topImageView.image = _bottomImageView.image;
        _topImageView.transform = CGAffineTransformMakeTranslation(0, 0);
        _isAnimating = NO;
        if (self.showingHandler) {
            self.showingHandler(self.currentIndex);
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.delay target:self selector:@selector(next) userInfo:nil repeats:NO];
    }];
}

- (void) animateSlideVertical:(SlideShowSlideMode) mode
{
    _isAnimating = YES;

    if(mode == SlideShowSlideModeBackward){
        _bottomImageView.transform = CGAffineTransformMakeTranslation(0,- _bottomImageView.frame.size.height);
    }else if(mode == SlideShowSlideModeForward){
        _bottomImageView.transform = CGAffineTransformMakeTranslation(0,_bottomImageView.frame.size.height);
    }

    [UIView animateWithDuration:self.transitionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if(mode == SlideShowSlideModeBackward){
            _topImageView.transform = CGAffineTransformMakeTranslation(0, _topImageView.frame.size.height);
            _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
        }else if(mode == SlideShowSlideModeForward){
            _topImageView.transform = CGAffineTransformMakeTranslation(0, - _topImageView.frame.size.height);
            _bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
        }
    } completion:^(BOOL finished){
        _topImageView.image = _bottomImageView.image;
        _topImageView.transform = CGAffineTransformMakeTranslation(0, 0);
        _isAnimating = NO;
        if (self.showingHandler) {
            self.showingHandler(self.currentIndex);
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.delay target:self selector:@selector(next) userInfo:nil repeats:NO];
    }];
}

#pragma mark - Gesture Recognizers initializers

- (void) addGesture:(SlideShowGestureType)gestureType
{
    [self removeGestures];

    switch (gestureType)
    {
        case SlideShowGestureTap:
            [self addGestureTap];
            break;
        case SlideShowGestureSwipe:
            [self addGestureSwipe];
            break;
        case SlideShowGestureAll:
            [self addGestureTap];
            [self addGestureSwipe];
            break;
        default:
            break;
    }
}

- (void) removeGestures
{
    self.gestureRecognizers = nil;
}

- (void) addGestureTap
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGestureRecognizer];
}

- (void) addGestureSwipe
{
    if(self.transitionType == SlideShowTransitionSlideHorizontal){
        UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer* swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;

        [self addGestureRecognizer:swipeLeftGestureRecognizer];
        [self addGestureRecognizer:swipeRightGestureRecognizer];
    }else{
        UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        UISwipeGestureRecognizer* swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;

        [self addGestureRecognizer:swipeUpGestureRecognizer];
        [self addGestureRecognizer:swipeDownGestureRecognizer];
    }

}

#pragma mark - Gesture Recognizers handling

- (void)handleSingleTap:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    CGPoint pointTouched = [gesture locationInView:self.topImageView];

    if (pointTouched.x <= self.topImageView.center.x){
        [self previous];
    }else {
        [self next];
    }
}

- (void) handleSwipe:(id)sender
{
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;

    float oldTransitionDuration = self.transitionDuration;

    self.transitionDuration = kSwipeTransitionDuration;
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft ||
        gesture.direction == UISwipeGestureRecognizerDirectionUp)
    {
        [self next];
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionRight ||
             gesture.direction == UISwipeGestureRecognizerDirectionDown)
    {
        [self previous];
    }

    self.transitionDuration = oldTransitionDuration;
}

@end
