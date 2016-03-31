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
    if (ratio == 1) {
        [self.showButton setHidden:YES];
    } else if (ratio == 0) {
        [self.showButton setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
