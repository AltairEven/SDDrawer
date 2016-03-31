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

- (void)buildHostWindow;

- (void)buildSubViews;

- (IBAction)didClickedHideButton:(id)sender;

- (void)openFinished;

- (void)closeFinished;

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
    [self buildHostWindow];
    [self buildSubViews];
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
    [self buildHostWindow];
}

- (void)setBackgroundView:(UIView *)backgroundView {
    _backgroundView = backgroundView;
    if (_backgroundView) {
        [self.view addSubview: _backgroundView];
        [self.view sendSubviewToBack:_backgroundView];
    }
}

#pragma mark Public methods

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


#pragma mark Private methods

- (void)initialization {
    self.openRatio = 0.8;
    self.autoSlideToOpenThreshold = 0.2;
    self.autoSlideToCloseThreshold = 0.1;
    self.contentScale = 1.0;
    _isClosed = YES;
    
    self.animationDuration = 0.3;
}

- (void)buildHostWindow {
    BOOL isKey = [self.navigationController.view.window isKeyWindow];
    BOOL isVisible = ![self.navigationController.view.window isHidden];
    if (!self.hostWindow) {
        self.hostWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.hostWindow setRootViewController:self];
        [self.hostWindow makeKeyAndVisible];
    }
    self.hostWindow.windowLevel = self.contentViewController.view.window.windowLevel - 1;
    if (isKey) {
        [self.contentViewController.view.window makeKeyAndVisible];
    }
    if (!isVisible) {
        [self.contentViewController.view.window setHidden:YES];
    }
}

- (void)buildSubViews {
}

- (IBAction)didClickedHideButton:(id)sender {
    [self close:YES];
}

- (void)openFinished {
    _isClosed = NO;
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
    _isClosed = YES;
    if ([self.delegate respondsToSelector:@selector(drawerViewController:openedWithOffsetRatio:)]) {
        [self.delegate drawerViewController:self openedWithOffsetRatio:0];
    }
    //重置Cover
    [self.coverView setHidden:YES];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    //当前的位移
    CGPoint translation = [sender translationInView:self.view];
    //最大最小区间
    CGFloat minOffset = 0;
    CGFloat maxOffset = 0;
    CGFloat centerX = 0;
    if ([self isClosed]) {
        //最大偏移量
        maxOffset = CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
        //新的中心位置X值
        centerX =  CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2 + translation.x;
    } else {
        //最小偏移量
        minOffset = 0 - CGRectGetMaxX(self.view.window.bounds) * self.openRatio;
        //新的中心位置X值
        centerX = CGRectGetMaxX(self.contentViewController.view.window.bounds) / 2 - minOffset + translation.x;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat thresholdX = 0;
        if ([self isClosed]) {
            thresholdX = self.autoSlideToOpenThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        } else {
            thresholdX = self.autoSlideToCloseThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
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
    [self slideDrawerWithXOffset:translation.x];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    if (![self isClosed]) {
        [self close:YES];
    }
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


@implementation SDDrawerViewController (GestureControl)

static const void *SDDrawerOpenSlideKey = @"SDDrawerOpenSlideKey";
static const void *SDDrawerCloseSlideKey = @"SDDrawerCloseSlideKey";

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

- (void)slideDrawerWithXOffset:(CGFloat)xOffset {
    
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
    if ([self.drawerViewController isClosed]) {
        //最大偏移量
        maxOffset = CGRectGetMaxX(self.drawerViewController.view.window.bounds) * self.drawerViewController.openRatio;
        //新的中心位置X值
        centerX =  CGRectGetMaxX(self.view.window.bounds) / 2 + translation.x;
    } else {
        //最小偏移量
        minOffset = 0 - CGRectGetMaxX(self.drawerViewController.view.window.bounds) * self.drawerViewController.openRatio;
        //新的中心位置X值
        centerX = CGRectGetMaxX(self.view.window.bounds) / 2 - minOffset + translation.x;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat thresholdX = 0;
        if ([self.drawerViewController isClosed]) {
            thresholdX = self.drawerViewController.autoSlideToOpenThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
        } else {
            thresholdX = self.drawerViewController.autoSlideToCloseThreshold * CGRectGetWidth([UIScreen mainScreen].bounds);
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
    [self.drawerViewController slideDrawerWithXOffset:translation.x];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    if (![self.drawerViewController isClosed]) {
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