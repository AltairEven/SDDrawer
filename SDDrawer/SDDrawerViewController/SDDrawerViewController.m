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

- (void)initialization;

- (void)buildHostWindow;

- (void)buildSubViews;

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
    if (!self.isClosed) {
        return;
    }
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat drawerShowingWidth = screenBounds.size.width * self.openPercent;
    CGPoint centerPoint = CGPointMake(screenBounds.size.width / 2 + drawerShowingWidth, screenBounds.size.height / 2);
    //root vc animate to right
    if (animated) {
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.contentViewController.view.window setCenter:centerPoint];
        } completion:^(BOOL finished) {
            _isClosed = NO;
        }];
    } else {
        [self.contentViewController.view.window setCenter:centerPoint];
        _isClosed = NO;
    }
}

- (void)close:(BOOL)animated {
    if (self.isClosed) {
        return;
    }
    if (animated) {
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.contentViewController.view.window setFrame:[UIScreen mainScreen].bounds];
        } completion:^(BOOL finished) {
            _isClosed = YES;
        }];
    } else {
        [self.contentViewController.view.window setFrame:[UIScreen mainScreen].bounds];
        _isClosed = YES;
    }
}


#pragma mark Private methods

- (void)initialization {
    self.openPercent = 0.8;
    self.contentScale = 1.0;
    _isClosed = YES;
    
    self.animationDuration = 0.5;
}

- (void)buildHostWindow {
    self.hostWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.hostWindow.windowLevel = self.contentViewController.view.window.windowLevel - 1;
    [self.hostWindow setRootViewController:self];
    [self.hostWindow makeKeyAndVisible];
    [self.contentViewController.view.window makeKeyAndVisible];
}

- (void)buildSubViews {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTappedOnContentViewController)];
    [self.contentViewController.view addGestureRecognizer:tap];
}

- (IBAction)didClickedHideButton:(id)sender {
    [self close:YES];
}

- (void)didTappedOnContentViewController {
    //root vc animate to right
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

@end