//
//  HDBaseNavViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDBaseNavViewController.h"

@interface HDBaseNavViewController ()

@end

@implementation HDBaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBarHidden=YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;  //navigation的栈有值的时候，隐藏tarbar
    }
    [super pushViewController:viewController animated:animated];
}


@end
