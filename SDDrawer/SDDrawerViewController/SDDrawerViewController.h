//
//  SDDrawerViewController.h
//  SDDrawer
//
//  Created by Qian Ye on 16/3/30.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDDrawerViewController;

@protocol SDDrawerViewControllerDelegate <NSObject>

@optional
/**
 *  当前打开偏移量的回调
 *
 *  @param controller SDDrawerViewController
 *  @param percent    当前打开的偏移量占比0~1，0表示未打开，1表示全部打开
 */
- (void)drawerViewController:(SDDrawerViewController *)controller openedWithOffsetRatio:(CGFloat)ratio;

@end

@interface SDDrawerViewController : UIViewController
/**
 *  背景视图，默认nil
 */
@property (nonatomic, strong) UIView *backgroundView;
/**
*  抽屉管理的内容视图控制器，一般通过initWithContentViewController:方法来赋值，也可以直接调用setter方法设置
*/
@property (nonatomic, strong) UIViewController *contentViewController;
/**
 *  SDDrawerViewControllerDelegate
 */
@property (nonatomic, weak) id<SDDrawerViewControllerDelegate> delegate;

/**
 *  通过内容试图控制器初始化的方法
 *
 *  @param controller 要管理的内容试图控制器
 *
 *  @return SDDrawerViewController实例
 */
- (instancetype)initWithContentViewController:(UIViewController *)controller;

@end


/**
 *  提供抽屉开启或者关闭
 */
@interface SDDrawerViewController (OpenClose)
/**
 *  抽屉打开后显示的百分比，默认0.8
 */
@property (nonatomic, assign) CGFloat openRatio;
/**
 *  当前抽屉打开状态
 */
@property (nonatomic, readonly) BOOL isOpened;
/**
 *  滑动手势触发后，自动展开全部的临界值，按照屏幕宽度的百分比，默认0.2
 */
@property (nonatomic, assign) CGFloat autoSlideToOpenThreshold;
/**
 *  滑动手势触发后，自动关闭的临界值，按照屏幕宽度的百分比，默认0.1
 */
@property (nonatomic, assign) CGFloat autoSlideToCloseThreshold;

/**
 *  打开抽屉（只支持内容视图向右）
 *
 *  @param animated 是否需要动画
 */
- (void)open:(BOOL)animated;
/**
 *  关闭抽屉
 *
 *  @param animated 是否需要动画
 */
- (void)close:(BOOL)animated;

@end

/**
 *  提供缩放和位移
 */
@interface SDDrawerViewController (OffsetAndShape)
/**
 *  抽屉打开后，内容视图显示比例，默认1
 */
@property (nonatomic, assign) CGFloat contentScale;

@end



@interface UIViewController (SDDrawer) <UIGestureRecognizerDelegate>
/**
 *  是否渲染阴影，在viewDidLoad后调用
 */
@property (nonatomic, assign) BOOL renderShadow;
/**
 *  管理该UIViewController的DrawerViewController
 */
@property (nonatomic, weak) SDDrawerViewController *drawerViewController;
/**
 *  激活或关闭抽屉滑动的手势，在viewDidAppear后调用
 *
 *  @param activated 激活或关闭
 */
- (void)activateSlideGesture:(BOOL)activated;

@end