//
//  HMMainTabBarController.m
//  浩渺管家
//
//  Created by Apple on 2018/8/27.
//  Copyright © 2018年 HTHM. All rights reserved.
//


#import "HDBaseTabBarViewController.h"

#import "HDBaseNavViewController.h"
#import "HDCutHomeViewController.h"
#import "HDNewTaskViewController.h"
#import "HDTaoMallViewController.h"
#import "HDPersonalViewController.h"
#import "HDNewPersonalViewController.h"

@interface HDBaseTabBarViewController ()<UITabBarControllerDelegate>

@end

@implementation HDBaseTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setTranslucent:NO];
    
    // 添加子控制器
    [self addAllChildController];
    
    // 修改tabbar背景颜色
    UIView *bgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:bgView atIndex:0];

    //去掉标签栏顶部线
    if (@available(iOS 13, *)) {
        [UITabBar appearance].layer.borderWidth = 0.0f;
        [UITabBar appearance].clipsToBounds = YES;
    } else {
        [[UITabBar appearance] setShadowImage:[UIImage new]];
        [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    }
    self.tabBar.tintColor = RGBMAIN;
    
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = RGBAlpha(153, 153, 153, 1);

    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = RGBMAIN;
    
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    /**
     * 设置背景色
     */
//    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
//    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    self.delegate = self;
}

#pragma mark - 添加所有子控制器
- (void)addAllChildController{
    //首页
    HDCutHomeViewController *homeVC = [[HDCutHomeViewController alloc] init];
    [self settingChildController:homeVC title:@"剪发" imageName:@"tab_ic_01" selectedImageName:@"tab_ic_01_slected"];
    
    //精选
//    HDTaoMallViewController *shopVC = [[HDTaoMallViewController alloc] init];
//    [self settingChildController:shopVC title:@"精选" imageName:@"tab_ic_02" selectedImageName:@"tab_ic_02_slected"];
    
    //任务
//    HDNewTaskViewController *taskVC = [[HDNewTaskViewController alloc] init];
//    [self settingChildController:taskVC title:@"任务列表" imageName:@"tab_ic_03" selectedImageName:@"tab_ic_03_slected"];
    
    //我的
    HDNewPersonalViewController *personalVC = [[HDNewPersonalViewController alloc] init];
//    HDPersonalViewController *personalVC = [[HDPersonalViewController alloc] init];
    [self settingChildController:personalVC title:@"我的" imageName:@"tab_ic_04" selectedImageName:@"tab_ic_04_slected"];

}

#pragma mark - 设置子控制器
-(void)settingChildController:(UIViewController *)childVC
                        title:(NSString *)title
                    imageName:(NSString *)imageName
            selectedImageName:(NSString *)selectedImageName{
    
    //赋值item
    childVC.tabBarItem.title = title;
    childVC.title = title;
    childVC.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVC.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    HDBaseNavViewController *nav = [[HDBaseNavViewController alloc] initWithRootViewController:childVC];
    [self addChildViewController:nav];
}

#pragma mark - tabbar delegate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
