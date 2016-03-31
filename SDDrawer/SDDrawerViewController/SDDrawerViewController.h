//
//  SDDrawerViewController.h
//  SDDrawer
//
//  Created by Qian Ye on 16/3/30.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <UIKit/UIKit.h>

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
 *  抽屉打开后显示的百分比，默认0.8
 */
@property (nonatomic, assign) CGFloat openPercent;
/**
 *  抽屉打开后，内容视图显示比例，默认1
 */
@property (nonatomic, assign) CGFloat contentScale;
/**
 *  当前抽屉打开状态
 */
@property (nonatomic, readonly) BOOL isClosed;

/**
 *  通过内容试图控制器初始化的方法
 *
 *  @param controller 要管理的内容试图控制器
 *
 *  @return SDDrawerViewController实例
 */
- (instancetype)initWithContentViewController:(UIViewController *)controller;
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
 *  UIViewController针对SDDrawerViewController的扩展
 */
@interface UIViewController (SDDrawer)
/**
 *  管理该UIViewController的DrawerViewController
 */
@property (nonatomic, weak) SDDrawerViewController *drawerViewController;

@end