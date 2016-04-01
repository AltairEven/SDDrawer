//
//  ViewController.m
//  SDDrawer
//
//  Created by Qian Ye on 16/3/30.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "ViewController.h"
//#import "AppDelegate.h"
#import "SDDrawerViewController.h"

@interface ViewController () <SDDrawerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SDDrawerViewController *drawerVC;

- (IBAction)showDrawer:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//    delegate.drawerViewController = [[SDDrawerViewController alloc] initWithContentViewController:self];
//    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    UIImage *bgImage = [UIImage imageNamed:@"greateBG.png"];
//    [bgImageView setImage:bgImage];
//    [delegate.drawerViewController setBackgroundView:bgImageView];
    
    self.drawerVC = [[SDDrawerViewController alloc] initWithContentViewController:self];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIImage *bgImage = [UIImage imageNamed:@"greateBG.png"];
    [bgImageView setImage:bgImage];
    [self.drawerVC setBackgroundView:bgImageView];
    self.drawerVC.delegate = self;
    self.renderShadow = YES;
    self.drawerVC.contentScale = CGVectorMake(0.8, 0.8);
    self.drawerVC.drawerOffset = CGVectorMake(-200, 0);
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self activateSlideGesture:YES];
}

- (IBAction)showDrawer:(id)sender {
    [self.drawerViewController open:YES];
}



#pragma mark SDDrawerViewControllerDelegate

- (void)drawerViewController:(SDDrawerViewController *)controller openedWithOffsetRatio:(CGFloat)ratio {
    [self.showButton setAlpha:1 - ratio];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
