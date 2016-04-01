//
//  SDDrawerViewController.m
//  SDDrawer
//
//  Created by Qian Ye on 16/3/30.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "SDDrawerViewController.h"
#import <objc/runtime.h>

#define DEFAULT_OPEN_RATIO (0.6)
#define DEFAULT_OPEN_SLIDETHRESHOLD (0.2)
#define DEFAULT_CLOSE_SLIDETHRESHOLD (0.1)
#define DEFAULT_CONTENT_SCALE (CGVectorMake(1, 1))
#define DEFAULT_DRAWER_CONTENTOFFSET (CGVectorMake(0, 0))

@interface SDDrawerViewController ()

@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, strong) UIWindow *hostWindow;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

- (void)initialization;

- (void)setupViews;

- (void)buildHostWindow;

- (IBAction)didClickedHideButton:(id)sender;

@end

@implementation SDDrawerViewController

- (instancetype)initWithContentViewController:(UIViewController *)controller {
    self= [self initWithNibName:@"SDDrawerViewController" bundle:nil];
    if (self) {
        self.contentViewController = controller;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //异步初始化，必须在viewDidAppear后，否则frame无法修改
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initialization];
    });
}

#pragma mark Setter & Getter

- (void)setContentViewController:(UIViewController *)contentViewController {
    if ([contentViewController isKindOfClass:[SDDrawerViewController class]]) {
        _contentViewController.drawerViewController = nil;
        _contentViewController = nil;
        return;
    }
    _contentViewController = contentViewController;
    _contentViewController.drawerViewController = self;
    [self setupViews];
}

- (void)setBackgroundView:(UIView *)backgroundView {
    _backgroundView = backgroundView;
    if (_backgroundView) {
        [self.hostWindow addSubview: _backgroundView];
        [self.hostWindow sendSubviewToBack:_backgroundView];
    }
}

#pragma mark Public methods


#pragma mark Private methods

- (void)initialization {
    [self setupViews];
    self.animationDuration = 0.2;
    self.openRatio = DEFAULT_OPEN_RATIO;
}


- (void)setupViews {
    [self buildHostWindow];
}


- (void)buildHostWindow {
    BOOL isKey = [self.navigationController.view.window isKeyWindow];
    BOOL isVisible = ![self.navigationController.view.window isHidden];
    //创建DrawerVC的载体Window
    if (!self.hostWindow) {
        self.hostWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.hostWindow setRootViewController:self];
        [self.hostWindow makeKeyAndVisible];
    }
    //设置该window处于被控制的window下一层，以便抽屉打开后显示
    self.hostWindow.windowLevel = self.contentViewController.view.window.windowLevel - 1;
    if (isKey) {
        [self.contentViewController.view.window makeKeyAndVisible];
    }
    if (!isVisible) {
        [self.contentViewController.view.window setHidden:YES];
    }
}

- (IBAction)didClickedHideButton:(id)sender {
    [self close:YES];
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


@implementation SDDrawerViewController (OpenClose)

static const void *SDDrawerOpenRatioKey = @"SDDrawerOpenRatioKey";
static const void *SDDrawerIsOpenedKey = @"SDDrawerIsOpenedKey";
static const void *SDDrawerOpenSlideKey = @"SDDrawerOpenSlideKey";
static const void *SDDrawerCloseSlideKey = @"SDDrawerCloseSlideKey";
static const void *SDDrawerContentScaleKey = @"SDDrawerContentScaleKey";
static const void *SDDrawerOffsetKey = @"SDDrawerOffsetKey";

#pragma mark Setter & Getter

- (void)setOpenRatio:(CGFloat)openRatio {
    if (openRatio < 0) {
        openRatio = 0;
    }
    if (openRatio > 1) {
        openRatio = 1;
    }
    objc_setAssociatedObject(self, SDDrawerOpenRatioKey, [NSNumber numberWithFloat:openRatio], OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.view) {
        //根据open ratio和scale来计算drawer内容的宽度
        CGFloat scaleOffset = (1 - self.contentScale.dx) * self.contentViewController.view.window.bounds.size.width / 2;
        CGFloat width = self.view.frame.size.width * openRatio + scaleOffset;
        CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width, [UIScreen mainScreen].bounds.size.height);
        [self.view setFrame:frame];
    }
}

- (CGFloat)openRatio {
    NSNumber *ratio = objc_getAssociatedObject(self, SDDrawerOpenRatioKey);
    if (!ratio) {
        return DEFAULT_OPEN_RATIO;
    }
    return [ratio floatValue];
}

- (void)setIsOpened:(BOOL)isOpened {
    objc_setAssociatedObject(self, SDDrawerIsOpenedKey, [NSNumber numberWithBool:isOpened], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)isOpened {
    NSNumber *isOpen = objc_getAssociatedObject(self, SDDrawerIsOpenedKey);
    if (!isOpen) {
        return NO;
    }
    return [isOpen boolValue];
}

- (void)setAutoSlideToOpenThreshold:(CGFloat)autoSlideToOpenThreshold {
    if (autoSlideToOpenThreshold < 0) {
        autoSlideToOpenThreshold = 1;
    }
    if (autoSlideToOpenThreshold > 1) {
        autoSlideToOpenThreshold = 1;
    }
    objc_setAssociatedObject(self, SDDrawerOpenSlideKey, [NSNumber numberWithFloat:autoSlideToOpenThreshold], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)autoSlideToOpenThreshold {
    NSNumber *threshold = objc_getAssociatedObject(self, SDDrawerOpenSlideKey);
    if (!threshold) {
        return DEFAULT_OPEN_SLIDETHRESHOLD;
    }
    return [threshold floatValue];
}

- (void)setAutoSlideToCloseThreshold:(CGFloat)autoSlideToCloseThreshold {
    objc_setAssociatedObject(self, SDDrawerCloseSlideKey, [NSNumber numberWithFloat:autoSlideToCloseThreshold], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)autoSlideToCloseThreshold {
    NSNumber *threshold = objc_getAssociatedObject(self, SDDrawerCloseSlideKey);
    if (!threshold) {
        return DEFAULT_CLOSE_SLIDETHRESHOLD;
    }
    return [threshold floatValue];
}

- (void)setContentScale:(CGVector)contentScale {
    if (contentScale.dx <= 0) {
        contentScale.dx = 0.1;
    }
    if (contentScale.dy <= 0) {
        contentScale.dy = 0.1;
    }
    objc_setAssociatedObject(self, SDDrawerContentScaleKey, [NSValue valueWithCGVector:contentScale], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGVector)contentScale {
    NSValue *scale = objc_getAssociatedObject(self, SDDrawerContentScaleKey);
    if (!scale) {
        return DEFAULT_CONTENT_SCALE;
    }
    return [scale CGVectorValue];
}

- (void)setDrawerOffset:(CGVector)drawerOffset {
    objc_setAssociatedObject(self, SDDrawerOffsetKey, [NSValue valueWithCGVector:drawerOffset], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGVector)drawerOffset {
    NSValue *offset = objc_getAssociatedObject(self, SDDrawerOffsetKey);
    if (!offset) {
        return DEFAULT_DRAWER_CONTENTOFFSET;
    }
    return [offset CGVectorValue];
}

#pragma mark Open & Close

- (NSTimeInterval)currentAnimationDuration {
    CGFloat originalCenterX = CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2;
    CGFloat xOffset = self.contentViewController.view.window.center.x - originalCenterX;
    CGFloat totalOffset = CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
    CGFloat ratio = xOffset / totalOffset;
    if (ratio < 0) {
        ratio = 0;
    }
    if (ratio > 1) {
        ratio = 1;
    }
    
    //根据当前滑动的进度，计算动画执行时间
    CGFloat durantion = self.animationDuration;
    if ([self isOpened]) {
        durantion = durantion * ratio;
    } else {
        durantion = durantion * (1 - ratio);
    }
    return durantion;
}

- (void)resetDrawerOffset:(BOOL)open {
    if (open) {
        [self.view setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    } else {
        CGPoint centerPoint = CGPointMake(self.view.bounds.size.width / 2 + self.drawerOffset.dx, self.view.bounds.size.height / 2 + self.drawerOffset.dy);
        [self.view setCenter:centerPoint];
        self.view.transform = CGAffineTransformMakeScale(self.contentScale.dx, self.contentScale.dy);
    }
}

- (void)resetContent:(BOOL)open {
    if (open) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGFloat drawerShowingWidth = screenBounds.size.width * self.openRatio;
        CGPoint centerPoint = CGPointMake(screenBounds.size.width / 2 + drawerShowingWidth, screenBounds.size.height / 2);
        [self.contentViewController.view.window setCenter:centerPoint];
        self.contentViewController.view.window.transform = CGAffineTransformMakeScale(self.contentScale.dx, self.contentScale.dy);
    } else {
        [self.contentViewController.view.window setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2)];
        self.contentViewController.view.window.transform = CGAffineTransformMakeScale(1, 1);
    }
}

- (void)open:(BOOL)animated {
    if (animated) {
        //animated
        NSTimeInterval duration = [self currentAnimationDuration];
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self resetDrawerOffset:YES];
            [self resetContent:YES];
        } completion:^(BOOL finished) {
            [self openFinished];
        }];
    } else {
        //no animated
        [self resetDrawerOffset:YES];
        [self resetContent:YES];
        [self openFinished];
    }
}

- (void)close:(BOOL)animated {
    if (animated) {
        NSTimeInterval duration = [self currentAnimationDuration];
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self resetDrawerOffset:NO];
            [self resetContent:NO];
        } completion:^(BOOL finished) {
            [self closeFinished];
        }];
    } else {
        [self resetDrawerOffset:NO];
        [self resetContent:NO];
        [self closeFinished];
    }
}

- (void)openFinished {
    [self setIsOpened:YES];
    if ([self.delegate respondsToSelector:@selector(drawerViewController:openedWithOffsetRatio:)]) {
        [self.delegate drawerViewController:self openedWithOffsetRatio:1];
    }
    //创建或设置Cover，覆盖住contentView
    if (!self.coverView) {
        self.coverView = [[UIView alloc] initWithFrame:self.contentViewController.view.window.bounds];
        [self.contentViewController.view.window addSubview:self.coverView];
        [self.coverView setBackgroundColor:[UIColor clearColor]];
    }
    [self.contentViewController.view.window bringSubviewToFront:self.coverView];
    [self.coverView setHidden:NO];
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [self.coverView addGestureRecognizer:self.panGesture];
    }
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [self.coverView addGestureRecognizer:self.tapGesture];
    }
}

- (void)closeFinished {
    [self setIsOpened:NO];
    if ([self.delegate respondsToSelector:@selector(drawerViewController:openedWithOffsetRatio:)]) {
        [self.delegate drawerViewController:self openedWithOffsetRatio:0];
    }
    //重置Cover
    [self.coverView setHidden:YES];
}

#pragma mark Gesture

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    //当前的位移
    CGPoint translation = [sender translationInView:self.view];
    //最大最小区间
    CGFloat minOffset = 0;
    CGFloat maxOffset = 0;
    CGFloat revisedOffset = translation.x;
    CGFloat centerX = 0;
    if ([self isOpened]) {
        //最小偏移量
        minOffset = 0 - CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
        if (revisedOffset < minOffset) {
            revisedOffset = minOffset;
        } else if (revisedOffset > maxOffset) {
            revisedOffset = maxOffset;
        }
        //新的中心位置X值
        centerX = CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2 - minOffset + revisedOffset;
    } else {
        //最大偏移量
        maxOffset = CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
        if (revisedOffset < minOffset) {
            revisedOffset = minOffset;
        } else if (revisedOffset > maxOffset) {
            revisedOffset = maxOffset;
        }
        //新的中心位置X值
        centerX =  CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2 + revisedOffset;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        //手势结束
        CGFloat thresholdX = 0;
        if ([self isOpened]) {
            thresholdX = self.autoSlideToCloseThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        } else {
            thresholdX = self.autoSlideToOpenThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        }
        if (revisedOffset >= thresholdX) {
            [self open:YES];
        } else {
            [self close:YES];
        }
        //手势完成，直接返回
        return;
    }
    //调用抽屉视图控制器的位移方法
    CGFloat originalCenterX = CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2;
    [self slideDrawerWithXOffset:centerX - originalCenterX];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    if ([self isOpened]) {
        [self close:YES];
    }
}


- (void)slideDrawerWithXOffset:(CGFloat)xOffset {
    CGFloat totalOffset = CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
    CGFloat ratio = xOffset / totalOffset;
    if (ratio < 0) {
        ratio = 0;
    }
    if (ratio > 1) {
        ratio = 1;
    }
    //位移
    //drawer
    CGVector realDrawerOffset = CGVectorMake(self.drawerOffset.dx * (1 - ratio), self.drawerOffset.dy * (1 - ratio));
    CGPoint centerPoint = CGPointMake(self.view.bounds.size.width / 2 + realDrawerOffset.dx, self.view.bounds.size.height / 2 + realDrawerOffset.dy);
    [self.view setCenter:centerPoint];
    //content
    [self.contentViewController.view.window setCenter:CGPointMake(CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2 + xOffset, self.contentViewController.view.window.center.y)];
    
    //形变
    //drawer
    CGVector realDrawerInterval = CGVectorMake(1 - self.contentScale.dx, 1 - self.contentScale.dy);
    CGVector realDrawerScale = CGVectorMake(realDrawerInterval.dx * ratio + self.contentScale.dx, realDrawerInterval.dy * ratio + self.contentScale.dy);
    self.view.transform = CGAffineTransformMakeScale(realDrawerScale.dx, realDrawerScale.dy);
    //content
    CGVector interval = CGVectorMake(1 - self.contentScale.dx, 1 - self.contentScale.dy);
    CGVector refreshScale = CGVectorMake(interval.dx * (1 - ratio) + self.contentScale.dx, interval.dy * (1 - ratio) + self.contentScale.dy);
    self.contentViewController.view.window.transform = CGAffineTransformMakeScale(refreshScale.dx, refreshScale.dy);
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawerViewController:openedWithOffsetRatio:)]) {
        [self.delegate drawerViewController:self openedWithOffsetRatio:ratio];
    }
}

@end



@implementation UIViewController (SDDrawer)

static const void *SDDrawerKey = @"SDDrawerViewController";
static const void *SDDrawerRenderShadowKey = @"SDDrawerRenderShadowKey";

#pragma mark Setter & Getter

- (void)setDrawerViewController:(SDDrawerViewController *)drawerViewController {
    if (!drawerViewController) {
        objc_setAssociatedObject(self, SDDrawerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    } else {
        objc_setAssociatedObject(self, SDDrawerKey, drawerViewController, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (SDDrawerViewController *)drawerViewController {
    return objc_getAssociatedObject(self, SDDrawerKey);
}

- (void)setRenderShadow:(BOOL)renderShadow {
    objc_setAssociatedObject(self, SDDrawerRenderShadowKey, [NSNumber numberWithBool:renderShadow], OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.view) {
        if (renderShadow) {
            self.view.layer.shadowOffset = CGSizeMake(-5, 0);
            self.view.layer.shadowColor = [UIColor blackColor].CGColor;
            self.view.layer.shadowRadius = 10;
            self.view.layer.shadowOpacity = 0.5;
            self.view.clipsToBounds = NO;
        } else {
            self.view.layer.shadowOpacity = 0;
            self.view.clipsToBounds = YES;
        }
    }
}

- (BOOL)renderShadow {
    NSNumber *isRender = objc_getAssociatedObject(self, SDDrawerRenderShadowKey);
    if (!isRender) {
        return NO;
    }
    return [isRender boolValue];
}


#pragma mark Gesture

- (void)activateSlideGesture:(BOOL)activated {
    BOOL hasCreatedPan = NO;
    BOOL hasCreatedTap = NO;
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            //已存在pan手势，先设置disable
            [gesture setEnabled:NO];
            hasCreatedPan = YES;
        } else if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
            //已存在swipe手势，先设置disable
            [gesture setEnabled:NO];
            hasCreatedTap = YES;
        }
    }
    if (activated) {
        //需要激活，并且还未创建手势
        if (!hasCreatedPan) {
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
            [self.view addGestureRecognizer:pan];
        }
        if (!hasCreatedTap) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
            [self.view addGestureRecognizer:tap];
        }
    }
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    //当前的位移
    CGPoint translation = [sender translationInView:self.view];
    //最大最小区间
    CGFloat minOffset = 0;
    CGFloat maxOffset = 0;
    CGFloat revisedOffset = translation.x;
    CGFloat centerX = 0;
    if ([self.drawerViewController isOpened]) {
        //最小偏移量
        minOffset = 0 - CGRectGetMaxX(self.drawerViewController.view.window.bounds) * self.drawerViewController.openRatio;
        if (revisedOffset < minOffset) {
            revisedOffset = minOffset;
        } else if (revisedOffset > maxOffset) {
            revisedOffset = maxOffset;
        }
        //新的中心位置X值
        centerX = CGRectGetMaxX(self.view.window.bounds) / 2 - minOffset + revisedOffset;
    } else {
        //最大偏移量
        maxOffset = CGRectGetMaxX(self.drawerViewController.view.window.bounds) * self.drawerViewController.openRatio;
        if (revisedOffset < minOffset) {
            revisedOffset = minOffset;
        } else if (revisedOffset > maxOffset) {
            revisedOffset = maxOffset;
        }
        //新的中心位置X值
        centerX =  CGRectGetMaxX(self.view.window.bounds) / 2 + revisedOffset;
    }
    //位移
    [self.view.window setCenter:CGPointMake(centerX, self.view.window.center.y)];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        //手势结束
        CGFloat thresholdX = 0;
        if ([self.drawerViewController isOpened]) {
            thresholdX = self.drawerViewController.autoSlideToCloseThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        } else {
            thresholdX = self.drawerViewController.autoSlideToOpenThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        }
        if (revisedOffset >= thresholdX) {
            [self.drawerViewController open:YES];
        } else {
            [self.drawerViewController close:YES];
        }
        //手势完成，直接返回
        return;
    }
    //调用抽屉视图控制器的位移方法
    CGFloat originalCenterX = CGRectGetMaxX(self.view.window.bounds) / 2;
    [self.drawerViewController slideDrawerWithXOffset:centerX - originalCenterX];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    if ([self.drawerViewController isOpened]) {
        [self.drawerViewController close:YES];
    }
}

#pragma mark UIGestureRecognizerDelegate


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}

@end