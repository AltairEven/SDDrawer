//
//  SDDrawerViewController.m
//  SDDrawer
//
//  Created by Qian Ye on 16/3/30.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "SDDrawerViewController.h"
#import <objc/runtime.h>

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
    [self initialization];
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
        [self.view addSubview: _backgroundView];
        [self.view sendSubviewToBack:_backgroundView];
    }
}

#pragma mark Public methods


#pragma mark Private methods

- (void)initialization {
    self.openRatio = 0.8;
    self.autoSlideToOpenThreshold = 0.2;
    self.autoSlideToCloseThreshold = 0.1;
    self.contentScale = 1.0;
    
    self.animationDuration = 0.3;
    
    [self setupViews];;
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

#pragma mark Setter & Getter

- (void)setOpenRatio:(CGFloat)openRatio {
    objc_setAssociatedObject(self, SDDrawerOpenRatioKey, [NSNumber numberWithFloat:openRatio], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)openRatio {
    NSNumber *ratio = objc_getAssociatedObject(self, SDDrawerOpenRatioKey);
    if (!ratio) {
        return 0;
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
    objc_setAssociatedObject(self, SDDrawerOpenSlideKey, [NSNumber numberWithFloat:autoSlideToOpenThreshold], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)autoSlideToOpenThreshold {
    NSNumber *threshold = objc_getAssociatedObject(self, SDDrawerOpenSlideKey);
    if (!threshold) {
        return 0;
    }
    return [threshold floatValue];
}

- (void)setAutoSlideToCloseThreshold:(CGFloat)autoSlideToCloseThreshold {
    objc_setAssociatedObject(self, SDDrawerCloseSlideKey, [NSNumber numberWithFloat:autoSlideToCloseThreshold], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)autoSlideToCloseThreshold {
    NSNumber *threshold = objc_getAssociatedObject(self, SDDrawerCloseSlideKey);
    if (!threshold) {
        return 0;
    }
    return [threshold floatValue];
}

#pragma mark Open & Close

- (void)open:(BOOL)animated {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat drawerShowingWidth = screenBounds.size.width * self.openRatio;
    CGPoint centerPoint = CGPointMake(screenBounds.size.width / 2 + drawerShowingWidth, screenBounds.size.height / 2);
    //root vc animate to right
    if (animated) {
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.contentViewController.view.window setCenter:centerPoint];
        } completion:^(BOOL finished) {
            [self openFinished];
        }];
    } else {
        [self.contentViewController.view.window setCenter:centerPoint];
        [self openFinished];
    }
}

- (void)close:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.contentViewController.view.window setFrame:[UIScreen mainScreen].bounds];
        } completion:^(BOOL finished) {
            [self closeFinished];
        }];
    } else {
        [self.contentViewController.view.window setFrame:[UIScreen mainScreen].bounds];
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
    CGFloat centerX = 0;
    if ([self isOpened]) {
        //最小偏移量
        minOffset = 0 - CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
        //新的中心位置X值
        centerX = CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2 - minOffset + translation.x;
    } else {
        //最大偏移量
        maxOffset = CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
        //新的中心位置X值
        centerX =  CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2 + translation.x;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat thresholdX = 0;
        if ([self isOpened]) {
            thresholdX = self.autoSlideToCloseThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        } else {
            thresholdX = self.autoSlideToOpenThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        }
        if (translation.x >= thresholdX) {
            [self open:YES];
        } else {
            [self close:YES];
        }
        //手势完成，直接返回
        return;
    }
    if (translation.x < minOffset || translation.x > maxOffset) {
        //超出识别区间，直接返回
        return;
    }
    //在识别区间内
    [self.contentViewController.view.window setCenter:CGPointMake(centerX, self.contentViewController.view.window.center.y)];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawerViewController:openedWithOffsetRatio:)]) {
        [self.delegate drawerViewController:self openedWithOffsetRatio:ratio];
    }
}

@end


@implementation SDDrawerViewController (OffsetAndShape)

static const void *SDDrawerContentScaleKey = @"SDDrawerContentScaleKey";

- (void)setContentScale:(CGFloat)contentScale {
    objc_setAssociatedObject(self, SDDrawerContentScaleKey, [NSNumber numberWithFloat:contentScale], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)contentScale {
    NSNumber *threshold = objc_getAssociatedObject(self, SDDrawerContentScaleKey);
    if (!threshold) {
        return 0;
    }
    return [threshold floatValue];
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
        self.view.layer.shadowOffset = CGSizeMake(-5, 0);
        self.view.layer.shadowColor = [UIColor blackColor].CGColor;
        self.view.layer.shadowRadius = 10;
        self.view.layer.shadowOpacity = 0.5;
        self.view.clipsToBounds = NO;
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
    CGFloat centerX = 0;
    if ([self.drawerViewController isOpened]) {
        //最小偏移量
        minOffset = 0 - CGRectGetMaxX(self.drawerViewController.view.window.bounds) * self.drawerViewController.openRatio;
        //新的中心位置X值
        centerX = CGRectGetMaxX(self.view.window.bounds) / 2 - minOffset + translation.x;
    } else {
        //最大偏移量
        maxOffset = CGRectGetMaxX(self.drawerViewController.view.window.bounds) * self.drawerViewController.openRatio;
        //新的中心位置X值
        centerX =  CGRectGetMaxX(self.view.window.bounds) / 2 + translation.x;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat thresholdX = 0;
        if ([self.drawerViewController isOpened]) {
            thresholdX = self.drawerViewController.autoSlideToCloseThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        } else {
            thresholdX = self.drawerViewController.autoSlideToOpenThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        }
        if (translation.x >= thresholdX) {
            [self.drawerViewController open:YES];
        } else {
            [self.drawerViewController close:YES];
        }
        //手势完成，直接返回
        return;
    }
    if (translation.x < minOffset || translation.x > maxOffset) {
        //超出识别区间，直接返回
        return;
    }
    //在识别区间内
    [self.view.window setCenter:CGPointMake(centerX, self.view.window.center.y)];
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