//
//  ViewController.m
//  SDDrawer
//
//  Created by Qian Ye on 16/3/30.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

- (IBAction)showDrawer:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.drawerViewController = [[SDDrawerViewController alloc] initWithContentViewController:self];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIImage *bgImage = [UIImage imageNamed:@"greateBG.png"];
    [bgImageView setImage:bgImage];
    [delegate.drawerViewController setBackgroundView:bgImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showDrawer:(id)sender {
    [self.drawerViewController open:YES];
}

@end
