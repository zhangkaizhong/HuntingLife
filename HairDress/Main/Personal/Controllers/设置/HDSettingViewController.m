//
//  HDSettingViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/1.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDSettingViewController.h"

#import "ZKZCleanCaches.h"
#import "HDSettingTableViewCell.h"

#import "HDAccoutSafeSetViewController.h"
#import "HDAboutUsViewController.h"

@interface HDSettingViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;// 导航栏
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) UIButton *buttonLogout;

@property (nonatomic,strong) NSArray *arrMenu;

@end

@implementation HDSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrMenu = @[@"账号与安全",@"清除缓存",@"关于我们"];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.buttonLogout];
    if ([HDToolHelper StringIsNullOrEmpty:[HDUserDefaultMethods getData:@"userId"]]) {
        self.buttonLogout.hidden = YES;
    }
}

#pragma mark ================== delegate / action =====================

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 推出登录
-(void)btnLogoutAction{
    [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定要退出登录吗？" viewController:self leftHandle:^(id anyID) {
        //取消
    }rightHandle:^(id any) {
        //确定    
        [MHNetworkManager postReqeustWithURL:URL_MemberLogout params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
            if ([returnData[@"respCode"] integerValue] == 200) {
                [HDUserDefaultMethods removeData:@"userId"];
                [HDUserDefaultMethods logout];
                [HDToolHelper delayMethodFourGCD:1 method:^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(logoutAction)]) {
                        [self.delegate logoutAction];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
            }
        } failureBlock:^(NSError *error) {
            
        } showHUD:YES];
    }];
}

#pragma mark -- tableView delegate datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrMenu.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDSettingTableViewCell class]) forIndexPath:indexPath];
    cell.cellTitle = self.arrMenu[indexPath.row];
    if ([cell.cellTitle isEqualToString:@"清除缓存"]) {
        // 计算缓存大小
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        float size = [ZKZCleanCaches folderSizeAtPath:cachesDir];
        cell.cacheSize = [NSString stringWithFormat:@"%.2fM",size/2];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        //账号与安全
        if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
            [HDToolHelper preToLoginView];
        }else{
            HDAccoutSafeSetViewController *accoutVC = [HDAccoutSafeSetViewController new];
            [self.navigationController pushViewController:accoutVC animated:YES];
        }
    }
    if (indexPath.row == 1) {
        [SVHUDHelper showLoadingHUD];
        [HDToolHelper delayMethodFourGCD:1 method:^{
            [SVProgressHUD dismiss];
        }];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        //清除缓存
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定要清除所有缓存数据吗？" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            [ZKZCleanCaches clearCache:cachesDir];
            [self.mainTableView reloadData];
        }];
    }
    if (indexPath.row == 2) {
        //关于我们
        HDAboutUsViewController *aboutVC = [[HDAboutUsViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT+8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-8-32-48) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDSettingTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDSettingTableViewCell class])];
    }
    return _mainTableView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"设置" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIButton *)buttonLogout{
    if (!_buttonLogout) {
        _buttonLogout = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-32-48, kSCREEN_WIDTH-32, 48) btnTitle:@"退出登录" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        _buttonLogout.layer.cornerRadius = 24;
        _buttonLogout.layer.borderWidth = 1;
        _buttonLogout.layer.borderColor = RGBMAIN.CGColor;
        [_buttonLogout addTarget:self action:@selector(btnLogoutAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonLogout;
}


@end
