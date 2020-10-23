//
//  HDPersonalViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalViewController.h"

#import "HDPersonalHomeHeaderView.h"
#import "HDPersonalHomeCell1.h"
#import "HDPersonalHomeCell2.h"
#import "HDPersonalHomeCell3.h"
#import "HDPersonalHomeCell4.h"
#import "HDPersonalHomeCell5.h"

#import "HDCalenderViewController.h"
#import "HDMysStoreIncomTotalViewController.h"
#import "HDShopConfigViewController.h"
#import "HDTimeConfigViewController.h"
#import "HDEditShopInfoViewController.h"
#import "HDPersonalInfoEditViewController.h"
#import "HDMyTaskListViewController.h"
#import "HDWaiterInfoEditViewController.h"
#import "HDMyAllOrdersViewController.h"
#import "HDMyWithdrawViewController.h"
#import "HDMyTeamsViewController.h"
#import "HDMyIncomsViewController.h"
#import "HDMyCollectionsViewController.h"
#import "HDMyBankCardViewController.h"
#import "HDMyHairListsViewController.h"
#import "HDInviteWaiterViewController.h"
#import "HDOrderManageViewController.h"
#import "HDMyShopWaiterViewController.h"
#import "HDMyOrdersViewController.h"
#import "HDTinyResumeViewController.h"
#import "HDShopRegisterViewController.h"
#import "HDMyInviteUserViewController.h"
#import "HDSettingViewController.h"
#import "HDQRScanViewController.h"

#import "SWQRCode.h"

#define Header_height 304
#define headImgWidth 54

@interface HDPersonalViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,PersonalInfoDelegate,PersonCellOneMenuDelegate,HDPersonalHomeCellThreeDelegate,HDSettingDelegate>
{
    UIView *navJiadeView;
    UIImageView *smallImgView;
    UIView *viewRedBack;
    
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}

@property (nonatomic,weak) HDPersonalHomeHeaderView *viewheader;
@property (nonatomic,strong) UIButton *btnScan;
@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) NSMutableArray * arrMenu;  // 菜单
@property (nonatomic,strong) NSDictionary *profitInfoDic;//收益详情
//门店ID
@property (nonatomic,copy) NSString *storeId;
//分享数据
@property (nonatomic,strong) NSDictionary *shareInfo;

@end

@implementation HDPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrMenu = [NSMutableArray new];
    
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    [self createNavView];
    [self.view addSubview:self.btnScan];
    
    initialFrame       = viewRedBack.frame;
    defaultViewHeight  = initialFrame.size.height;
    
    [self initDataMenu];
    
    [self getShareInfoData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.viewheader) {
        NSString *nickName = [HDUserDefaultMethods getData:@"nickName"];
        if ([nickName isEqualToString:@""]) {
            nickName = @"请先登录";
        }
        self.viewheader.userDic = @{@"nickName":nickName,@"headImg":[HDUserDefaultMethods getData:@"headImg"]};
    }
    if (smallImgView) {
        [smallImgView sd_setImageWithURL:[NSURL URLWithString:[HDUserDefaultMethods getData:@"headImg"]] placeholderImage:[UIImage imageNamed:@"barber_ic_customer"]];
    }
    [self getMemberInfo];
    [self getPersonalProfitData];
}

//个人中心列表数组
-(void)initDataMenu{
    [self.arrMenu removeAllObjects];
    NSString *storeType = [HDUserDefaultMethods getData:@"storePost"];
    self.storeId = [HDUserDefaultMethods getData:@"storeId"];
    if ([storeType isEqualToString:@"B"]) {
        // 店主
        [self.arrMenu addObject:@{@"title":@"邀请好友",@"image":@"personal_ic_03_gift"}];
        [self.arrMenu addObject:@{@"title":@"我的任务",@"image":@"personal_ic_03_task"}];
        [self.arrMenu addObject:@{@"title":@"剪发日历",@"image":@"personal_ic_03_time"}];
        [self.arrMenu addObject:@{@"title":@"预约处理",@"image":@"personal_ic_03_dealwith"}];
        [self.arrMenu addObject:@{@"title":@"我的店员",@"image":@"personal_ic_03_assistant"}];
        [self.arrMenu addObject:@{@"title":@"邀请店员",@"image":@"personal_ic_03_invite"}];
        [self.arrMenu addObject:@{@"title":@"预约理发时段",@"image":@"personal_ic_03_time"}];
        [self.arrMenu addObject:@{@"title":@"收益统计",@"image":@"personal_ic_03_income"}];
        [self.arrMenu addObject:@{@"title":@"编辑门店信息",@"image":@"personal_ic_03_edit"}];
        [self.arrMenu addObject:@{@"title":@"配置服务项目",@"image":@"personal_ic_03_configuration"}];
        [self.arrMenu addObject:@{@"title":@"我的银行卡",@"image":@"personal_ic_03_bankcard"}];
        [self.arrMenu addObject:@{@"title":@"设置",@"image":@"personal_ic_03_set"}];
    }
    else if ([storeType isEqualToString:@"T"]){
        // 发型师
        [self.arrMenu addObject:@{@"title":@"邀请好友",@"image":@"personal_ic_03_gift"}];
        [self.arrMenu addObject:@{@"title":@"我的任务",@"image":@"personal_ic_03_task"}];
        [self.arrMenu addObject:@{@"title":@"成为店主",@"image":@"personal_ic_03_shopkeeper"}];
        if(![self.storeId isEqualToString:@""]){
            [self.arrMenu addObject:@{@"title":@"员工信息",@"image":@"personal_ic_03_edit"}];
        }
        [self.arrMenu addObject:@{@"title":@"我的预约",@"image":@"personal_ic_03_reservation"}];
        [self.arrMenu addObject:@{@"title":@"剪发日历",@"image":@"personal_ic_03_time"}];
        [self.arrMenu addObject:@{@"title":@"收益统计",@"image":@"personal_ic_03_income"}];
        [self.arrMenu addObject:@{@"title":@"微简历",@"image":@"personal_ic_03_resume"}];
        [self.arrMenu addObject:@{@"title":@"我的银行卡",@"image":@"personal_ic_03_bankcard"}];
        [self.arrMenu addObject:@{@"title":@"设置",@"image":@"personal_ic_03_set"}];
    }
    else if ([storeType isEqualToString:@"O"]){
        // 普通店员
        [self.arrMenu addObject:@{@"title":@"邀请好友",@"image":@"personal_ic_03_gift"}];
        [self.arrMenu addObject:@{@"title":@"我的任务",@"image":@"personal_ic_03_task"}];
        [self.arrMenu addObject:@{@"title":@"成为店主",@"image":@"personal_ic_03_shopkeeper"}];
        if(![self.storeId isEqualToString:@""]){
            [self.arrMenu addObject:@{@"title":@"员工信息",@"image":@"personal_ic_03_edit"}];
        }
        [self.arrMenu addObject:@{@"title":@"查看预约",@"image":@"personal_ic_03_lookover"}];
        [self.arrMenu addObject:@{@"title":@"剪发日历",@"image":@"personal_ic_03_time"}];
        [self.arrMenu addObject:@{@"title":@"我的银行卡",@"image":@"personal_ic_03_bankcard"}];
        [self.arrMenu addObject:@{@"title":@"设置",@"image":@"personal_ic_03_set"}];
    }
    else{
        // 普通用户
        [self.arrMenu addObject:@{@"title":@"邀请好友",@"image":@"personal_ic_03_gift"}];
        [self.arrMenu addObject:@{@"title":@"我的任务",@"image":@"personal_ic_03_task"}];
        [self.arrMenu addObject:@{@"title":@"剪发日历",@"image":@"personal_ic_03_time"}];
        [self.arrMenu addObject:@{@"title":@"成为店主",@"image":@"personal_ic_03_shopkeeper"}];
        [self.arrMenu addObject:@{@"title":@"我的银行卡",@"image":@"personal_ic_03_bankcard"}];
        [self.arrMenu addObject:@{@"title":@"设置",@"image":@"personal_ic_03_set"}];
    }
    
    [self.mainTableView reloadData];
}

#pragma mark -- action
-(void)scanAction{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    SWQRCodeConfig *config = [[SWQRCodeConfig alloc]init];
    config.scannerType = SWScannerTypeBoth;
    
    HDQRScanViewController *qrcodeVC = [[HDQRScanViewController alloc]init];
    qrcodeVC.codeConfig = config;
    [self.navigationController pushViewController:qrcodeVC animated:YES];
}

//退出登录代理
-(void)logoutAction{
    [self initDataMenu];
}

#pragma mark ================== 请求数据 =====================
//查询收益信息
-(void)getPersonalProfitData{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        self.viewheader.profitDic = @{@"todayPredictFee":@"0",@"monthPredictFee":@"0",@"lastMonthSettledFee":@"0",@"canGetFee":@"0",@"totalPredictFee":@"0",};
        return;
    }
    NSDictionary *params = @{
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_UserQueryMoneyInfo params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.profitInfoDic = returnData[@"data"];
            weakSelf.viewheader.profitDic = self.profitInfoDic;
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//获取用户数据
-(void)getMemberInfo{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_UserGetMemberInfo params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            if (![userInfo[@"storePost"] isEqualToString:[HDUserDefaultMethods getData:@"storePost"]]) {
                [HDUserDefaultMethods saveData:userInfo[@"storePost"] andKey:@"storePost"];
                [HDUserDefaultMethods saveData:userInfo[@"storeId"] andKey:@"storeId"];
                [self initDataMenu];
            }
            // 缓存用户信息
            [HDToolHelper saveData:userInfo];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//获取分享数据
-(void)getShareInfoData{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_UserGetAppConfigInfo params:@{} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.shareInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark -- delegate/action
// 头部视图
-(void)clickPersonalHeaderView:(PersonalHeaderClickType)type{
    if (type == PersonalHeaderClickTypeIntr) {
        // 说明
    }
    if (type == PersonalHeaderClickTypePersonInfo) {
        // 个人资料
        if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
            [HDToolHelper preToLoginView];
        }
        else{
            HDPersonalInfoEditViewController *infoVC = [HDPersonalInfoEditViewController new];
            [self.navigationController pushViewController:infoVC animated:YES];
        }
    }
}

// cellone delegate
-(void)clickCellOneMenuType:(PersonCellOneMenuType)type{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    if (type == 0) {
        HDMyIncomsViewController *incomsVC = [HDMyIncomsViewController new];
        [self.navigationController pushViewController:incomsVC animated:YES];
    }
    if (type == 1) {
        HDMyAllOrdersViewController *ordersVC = [HDMyAllOrdersViewController new];
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == 2) {
        HDMyWithdrawViewController *withVC = [HDMyWithdrawViewController new];
        [self.navigationController pushViewController:withVC animated:YES];
    }
    if (type == 3) {
        HDMyTeamsViewController *teamVC = [HDMyTeamsViewController new];
        [self.navigationController pushViewController:teamVC animated:YES];
    }
}

-(void)clickCellThreeViews:(HDPersonalHomeCellThreeClickType)type{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    if (type == HDPersonalHomeCellThreeClickTypeVIPCard) {
        // VIP卡
    }
    else{
        // 我的收藏
        HDMyCollectionsViewController *collectVC = [HDMyCollectionsViewController new];
        [self.navigationController pushViewController:collectVC animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate 导航栏渐变
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {//下拉，隐藏 navView
        smallImgView.alpha = 0;
        navJiadeView.backgroundColor = [RGBMAIN colorWithAlphaComponent:0];
        // 背景拉伸
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        initialFrame.origin.y = - offsetY * 1;
        initialFrame.size.height = defaultViewHeight + offsetY;
        viewRedBack.frame = initialFrame;
    }else{//移动过程
        smallImgView.alpha = offsetY/NAVHIGHT;
        navJiadeView.backgroundColor = [RGBMAIN colorWithAlphaComponent:offsetY/NAVHIGHT];
    }
}

#pragma mark -- tableView delegate datasouce

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2+self.arrMenu.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        return 28 + 32 +38;
    }
//    if (indexPath.item == 1) {
//        return 72;
//    }
    if (indexPath.item == 1) {
        return 56+16;
    }
//    if (indexPath.item == 2) {
//        return 66+16;
//    }
    return 48;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item > 1) {
        HDPersonalHomeCell5 *cell5 = (HDPersonalHomeCell5 *)[tableView cellForRowAtIndexPath:indexPath];
        NSString *titleMenu = cell5.dic[@"title"];
        if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
            [HDToolHelper preToLoginView];
            return;
        }
        // 我的发型
        if ([titleMenu isEqualToString:@"我的发型"]) {
            HDMyHairListsViewController *hairVC = [HDMyHairListsViewController new];
            [self.navigationController pushViewController:hairVC animated:YES];
        }
        // 邀请有礼
        if ([titleMenu isEqualToString:@"邀请好友"]) {
            [HDToolHelper runMainQueue:^{
                if (self.shareInfo) {
                    NSString *urlShare = [NSString stringWithFormat:@"%@?parentId=%@",self.shareInfo[@"privilegeUrl"],[HDUserDefaultMethods getData:@"userId"]];
                    [HDToolHelper createShareUI:@{@"title":self.shareInfo[@"shareInviteTitle"],@"subImage":self.shareInfo[@"shareInviteImg"],@"shareTitle":self.shareInfo[@"shareInviteDes"],@"url":urlShare} controller:self];
                }
                else{
                    [MHNetworkManager postReqeustWithURL:URL_UserGetAppConfigInfo params:@{} successBlock:^(NSDictionary *returnData) {
                        if ([returnData[@"respCode"] integerValue] == 200) {
                            self.shareInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
                            NSString *urlShare = [NSString stringWithFormat:@"%@?parentId=%@",self.shareInfo[@"privilegeUrl"],[HDUserDefaultMethods getData:@"userId"]];
                            [HDToolHelper createShareUI:@{@"title":self.shareInfo[@"shareInviteTitle"],@"subImage":self.shareInfo[@"shareInviteImg"],@"shareTitle":self.shareInfo[@"shareInviteDes"],@"url":urlShare} controller:self];
                        }
                    } failureBlock:^(NSError *error) {
                        
                    } showHUD:YES];
                }
            }];
        }
        // 编辑店员信息
        if ([titleMenu isEqualToString:@"员工信息"]) {
            HDWaiterInfoEditViewController *infoVC = [HDWaiterInfoEditViewController new];
            [self.navigationController pushViewController:infoVC animated:YES];
        }
        // 我的任务
        if ([titleMenu isEqualToString:@"我的任务"]) {
            HDMyTaskListViewController *taskVC = [HDMyTaskListViewController new];
            [self.navigationController pushViewController:taskVC animated:YES];
        }
        // 预约处理
        if ([titleMenu isEqualToString:@"预约处理"]) {
            HDOrderManageViewController *orderVC = [HDOrderManageViewController new];
            orderVC.suTitle = @"预约处理";
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        // 查看预约
        if ([titleMenu isEqualToString:@"查看预约"]) {
            HDOrderManageViewController *orderVC = [HDOrderManageViewController new];
            orderVC.suTitle = @"查看预约";
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        // 我的店员
        if ([titleMenu isEqualToString:@"我的店员"]) {
            HDMyShopWaiterViewController *waiterVC = [HDMyShopWaiterViewController new];
            [self.navigationController pushViewController:waiterVC animated:YES];
        }
        // 成为店主
        if ([titleMenu isEqualToString:@"成为店主"]) {
            HDShopRegisterViewController *shopRegVC = [HDShopRegisterViewController new];
            [self.navigationController pushViewController:shopRegVC animated:YES];
        }
        // 我的预约
        if ([titleMenu isEqualToString:@"我的预约"]) {
            HDMyOrdersViewController *myOrderVC = [HDMyOrdersViewController new];
            [self.navigationController pushViewController:myOrderVC animated:YES];
        }
        // 微简历
        if ([titleMenu isEqualToString:@"微简历"]) {
            HDTinyResumeViewController *tinyVC = [HDTinyResumeViewController new];
            [self.navigationController pushViewController:tinyVC animated:YES];
        }
        // 邀请店员
        if ([titleMenu isEqualToString:@"邀请店员"]) {
            HDInviteWaiterViewController *inviateVC = [HDInviteWaiterViewController new];
            [self.navigationController pushViewController:inviateVC animated:YES];
        }
        // 预约理发时段
        if ([titleMenu isEqualToString:@"预约理发时段"]) {
            HDTimeConfigViewController *timeVC = [HDTimeConfigViewController new];
            [self.navigationController pushViewController:timeVC animated:YES];
        }
        // 收益统计
        if ([titleMenu isEqualToString:@"收益统计"]) {
            HDMysStoreIncomTotalViewController *incomeVC = [HDMysStoreIncomTotalViewController new];
            [self.navigationController pushViewController:incomeVC animated:YES];
        }
        // 编辑门店信息
        if ([titleMenu isEqualToString:@"编辑门店信息"]) {
            HDEditShopInfoViewController *shopVC = [HDEditShopInfoViewController new];
            shopVC.shop_id = [HDUserDefaultMethods getData:@"storeId"];
            [self.navigationController pushViewController:shopVC animated:YES];
        }
        // 配置服务项目
        if ([titleMenu isEqualToString:@"配置服务项目"]) {
            HDShopConfigViewController *shopConfigVC = [HDShopConfigViewController new];
            [self.navigationController pushViewController:shopConfigVC animated:YES];
        }
        // 我的银行卡
        if ([titleMenu isEqualToString:@"我的银行卡"]) {
            HDMyBankCardViewController *bankVC = [[HDMyBankCardViewController alloc] init];
            [self.navigationController pushViewController:bankVC animated:YES];
        }
        // 设置
        if ([titleMenu isEqualToString:@"设置"]) {
            HDSettingViewController *setVC = [HDSettingViewController new];
            setVC.delegate = self;
            [self.navigationController pushViewController:setVC animated:YES];
        }
        // 剪发日历
        if ([titleMenu isEqualToString:@"剪发日历"]) {
            //查看剪发日历
            HDCalenderViewController *calenderVC = [HDCalenderViewController new];
            [self.navigationController pushViewController:calenderVC animated:YES];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        HDPersonalHomeCell1 *cell1 = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        cell1.delegate = self;
        return cell1;
    }
//    else if (indexPath.item == 1){
//        HDPersonalHomeCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
//        return cell;
//    }
    else if (indexPath.item == 1){
        HDPersonalHomeCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3" forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }
//    else if (indexPath.item == 2){
//        HDPersonalHomeCell4 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell4" forIndexPath:indexPath];
//        return cell;
//    }
    HDPersonalHomeCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell5" forIndexPath:indexPath];
    cell.dic = self.arrMenu[indexPath.item-2];
    return cell;
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-KTarbarHeight) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // 创建头视图
        HDPersonalHomeHeaderView *viewheader = [[HDPersonalHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, Header_height)];
        viewheader.delegate = self;
        NSString *nickName = [HDUserDefaultMethods getData:@"nickName"];
        if ([nickName isEqualToString:@""]) {
            nickName = @"请先登录";
        }
        viewheader.userDic = @{@"nickName":nickName,@"headImg":[HDUserDefaultMethods getData:@"headImg"]};
        viewRedBack = [viewheader viewWithTag:10000];
        self.viewheader = viewheader;
        _mainTableView.tableHeaderView = viewheader;
        
        [_mainTableView registerClass:[HDPersonalHomeCell1 class] forCellReuseIdentifier:@"cell1"];
        [_mainTableView registerClass:[HDPersonalHomeCell2 class] forCellReuseIdentifier:@"cell2"];
        [_mainTableView registerClass:[HDPersonalHomeCell3 class] forCellReuseIdentifier:@"cell3"];
        [_mainTableView registerClass:[HDPersonalHomeCell4 class] forCellReuseIdentifier:@"cell4"];
        [_mainTableView registerClass:[HDPersonalHomeCell5 class] forCellReuseIdentifier:@"cell5"];
    }
    return _mainTableView;
}

//创建虚拟导航栏
-(void)createNavView{
    //虚拟导航栏，存放title，设置，客服，信息btn
    navJiadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kSCREEN_WIDTH, NAVHIGHT)];
    navJiadeView.backgroundColor = [RGBMAIN colorWithAlphaComponent:0];
    [self.view addSubview:navJiadeView];
    
    //小headImg
    smallImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    smallImgView.centerY = navJiadeView.centerY+10;
    smallImgView.centerX = navJiadeView.centerX;
    smallImgView.layer.cornerRadius = 30/2;
    smallImgView.layer.masksToBounds = YES;
    smallImgView.alpha = 0;
    smallImgView.contentMode = 2;
    [navJiadeView addSubview:smallImgView];
    
    [smallImgView sd_setImageWithURL:[NSURL URLWithString:[HDUserDefaultMethods getData:@"headImg"]] placeholderImage:[UIImage imageNamed:@"barber_ic_customer"]];
}

-(UIButton *)btnScan{
    if (!_btnScan) {
        _btnScan = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, NAVHIGHT-10-24, 24, 24) btnTitle:@"" btnImage:@"personal_ic_scan" titleColor:[UIColor clearColor] titleFont:0];
        [_btnScan addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnScan;
}


@end
