//
//  HDNewPersonalViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/4/26.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDNewPersonalViewController.h"

#import "HDNewPersonalView.h"

#import "HDCalenderViewController.h"
#import "HDAboutUsViewController.h"
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
#import "HDQuestionsViewController.h"
#import "HDPlatformRulesViewController.h"
#import "HDSuperEquityViewController.h"
#import "HDMyTaoGoodsOrderViewController.h"
#import "HDMyCutAllOrdersViewController.h"
#import "HDUpGradeViewController.h"
#import "HDNewTaskViewController.h"

#import "SWQRCode.h"
#import "PersonViewModels.h"

@interface HDNewPersonalViewController ()<HDNewPersonalViewDelegate,HDSettingDelegate>

@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) HDNewPersonalView *personView;//已登陆状态
@property (nonatomic,strong) HDNewPersonalView *logoutView;//未登录状态
@property (nonatomic,strong) UIView *navView;//导航

//分享数据
@property (nonatomic,strong) NSDictionary *shareInfo;

@end

@implementation HDNewPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBCOLOR(248, 248, 248);

    [self.view addSubview:self.mainScrollView];
    
    [PersonViewModels getShareInfo:^(NSDictionary * _Nonnull result) {
        self.shareInfo = result;
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        _personView.hidden = YES;
        _logoutView.hidden = NO;
    }else{
        _personView.hidden = NO;
        _logoutView.hidden = YES;
    }
    WeakSelf;
    if (weakSelf.personView && weakSelf.personView.hidden == NO) {
        [PersonViewModels getMemberInfo:^(NSDictionary * _Nonnull result) {
            if (result) {
                [weakSelf.personView reloadUIWithData:result complete:^{
                    weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, weakSelf.personView.bottom+16*SCALE);
                    
                    [PersonViewModels getNewPersonalInfoData:^(NewPersonInfoModel * _Nonnull personModel) {
                        if (personModel) {
                            [weakSelf.personView reloadProfitData:personModel];
                            weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, weakSelf.personView.bottom+16*SCALE);
                        }
                    }];
                }];
            }
        }];
        
        [PersonViewModels getStoreOrderNumData:^(NewPersonInfoModel * _Nonnull personModel) {
            [weakSelf.personView reloadOrderNumData:personModel];
        }];
        
        [PersonViewModels getUserOrderNumData:^(NewPersonInfoModel * _Nonnull personModel) {
            [weakSelf.personView reloadUserOrderNumData:personModel];
        }];
    }
}

#pragma mark --  UI
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-KTarbarHeight)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        [_mainScrollView addSubview:self.personView];
        [_mainScrollView addSubview:self.logoutView];
        if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {//未登录
            _personView.hidden = YES;
            _logoutView.hidden = NO;
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _logoutView.bottom+16*SCALE);
        }
        else{//已登录
            _personView.hidden = NO;
            _logoutView.hidden = YES;
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _personView.bottom+16*SCALE);
        }
    }
    return _mainScrollView;
}

#pragma mark -- 加载控件
//个人中心视图（已登陆）
-(HDNewPersonalView *)personView{
    if (!_personView) {
        _personView = [[HDNewPersonalView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, _mainScrollView.height) type:YES];
        _personView .delegate = self;
    }
    return _personView;
}

//未登录
-(HDNewPersonalView *)logoutView{
    if (!_logoutView) {
        _logoutView = [[HDNewPersonalView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, _mainScrollView.height) type:NO];
        _logoutView .delegate = self;
    }
    return _logoutView;
}

#pragma mark -- delegate
//退出登录后初始化页面
-(void)logoutAction{
    _personView.hidden = YES;
    _logoutView.hidden = NO;
    _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _logoutView.bottom+16*SCALE);
}

#pragma mark -- 个人中心点击事件
-(void)clickPersonFunciton:(PersonFunctionType)type{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    if (type == FunctionTypeSet) {
        //设置
        HDSettingViewController *setVC = [HDSettingViewController new];
        setVC.delegate = self;
        [self.navigationController pushViewController:setVC animated:YES];
    }
    if (type == FunctionTypeMsg) {
        //消息
    }
    if (type == FunctionTypeScan) {
        //扫一扫
        SWQRCodeConfig *config = [[SWQRCodeConfig alloc]init];
        config.scannerType = SWScannerTypeBoth;
        
        HDQRScanViewController *qrcodeVC = [[HDQRScanViewController alloc]init];
        qrcodeVC.codeConfig = config;
        [self.navigationController pushViewController:qrcodeVC animated:YES];
    }
    if (type == FunctionTypePersonInfo) {
        //个人资料
        HDPersonalInfoEditViewController *infoVC = [HDPersonalInfoEditViewController new];
        [self.navigationController pushViewController:infoVC animated:YES];
    }
    if (type == FunctionTypeWithdrew) {
        //提现
        HDMyWithdrawViewController *withVC = [HDMyWithdrawViewController new];
        [self.navigationController pushViewController:withVC animated:YES];
    }
    if (type == FunctionTypeFans) {
        //粉丝
        HDMyTeamsViewController *teamVC = [HDMyTeamsViewController new];
        [self.navigationController pushViewController:teamVC animated:YES];
    }
    if (type == FunctionTypeTBOrders) {
        //淘宝订单
        HDMyTaoGoodsOrderViewController *ordersVC = [HDMyTaoGoodsOrderViewController new];
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeOtherOrders) {
        //其他订单
//        //预约处理
//        NSString *storeType = [HDUserDefaultMethods getData:@"storePost"];
//        if ([storeType isEqualToString:@"B"]){
//            //店主
//            HDOrderManageViewController *orderVC = [HDOrderManageViewController new];
//            orderVC.suTitle = @"预约处理";
//            [self.navigationController pushViewController:orderVC animated:YES];
//        }else if ([storeType isEqualToString:@"T"]){
//            //发型师
//            HDMyOrdersViewController *myOrderVC = [HDMyOrdersViewController new];
//            [self.navigationController pushViewController:myOrderVC animated:YES];
//        }else if ([storeType isEqualToString:@"O"]){
//            //普通店员
//            HDOrderManageViewController *orderVC = [HDOrderManageViewController new];
//            orderVC.suTitle = @"查看预约";
//            [self.navigationController pushViewController:orderVC animated:YES];
//        }
        HDMyTaskListViewController *taskVC = [HDMyTaskListViewController new];
        [self.navigationController pushViewController:taskVC animated:YES];
    }
    if (type == FunctionTypeMemberGaikuang) {
        //会员详情查看概况
        HDMyIncomsViewController *incomsVC = [HDMyIncomsViewController new];
        [self.navigationController pushViewController:incomsVC animated:YES];
    }
    if (type == FunctionTypeUpdateTuanzhang) {
        //升级团长
        HDUpGradeViewController *upVC = [HDUpGradeViewController new];
        [self.navigationController pushViewController:upVC animated:YES];
    }
    if (type == FunctionTypeCheckCutCalender) {
        //查看剪发日历
        HDCalenderViewController *calenderVC = [HDCalenderViewController new];
        [self.navigationController pushViewController:calenderVC animated:YES];
    }
    if (type == FunctionTypeCutOrdersMore) {
        //查看理发预约订单
        HDMyCutAllOrdersViewController *ordersVC = [HDMyCutAllOrdersViewController new];
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeCutOrdersWiatXiaofei) {
        //待消费理发预约订单
        HDMyCutAllOrdersViewController *ordersVC = [HDMyCutAllOrdersViewController new];
        ordersVC.index = 0;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeCutOrdersWaitToPay) {
        //待付款理发预约订单
        HDMyCutAllOrdersViewController *ordersVC = [HDMyCutAllOrdersViewController new];
        ordersVC.index = 1;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeCutOrdersService) {
        //服务中理发预约订单
        HDMyCutAllOrdersViewController *ordersVC = [HDMyCutAllOrdersViewController new];
        ordersVC.index = 2;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeCutOrdersDone) {
        //已完成理发预约订单
        HDMyCutAllOrdersViewController *ordersVC = [HDMyCutAllOrdersViewController new];
        ordersVC.index = 3;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeCutOrdersRefund) {
        //过号退款理发预约订单
        HDMyCutAllOrdersViewController *ordersVC = [HDMyCutAllOrdersViewController new];
        ordersVC.index = 4;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    
    if (type == FunctionTypeMyCutOrdersMore) {
        //查看理发预约订单
        HDOrderManageViewController *orderVC = [HDOrderManageViewController new];
        orderVC.suTitle = @"预约处理";
        [self.navigationController pushViewController:orderVC animated:YES];
    }
    if (type == FunctionTypeMyCutOrdersUnaccept) {
        //待接单
        HDOrderManageViewController *orderVC = [HDOrderManageViewController new];
        [self.navigationController pushViewController:orderVC animated:YES];
    }
    if (type == FunctionTypeMyCutOrdersAccepted) {
        //已接单
        HDOrderManageViewController *ordersVC = [HDOrderManageViewController new];
        ordersVC.index = 1;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeMyCutOrdersDone) {
        //已完成
        HDOrderManageViewController *ordersVC = [HDOrderManageViewController new];
        ordersVC.index = 2;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    if (type == FunctionTypeMyCutOrdersRefund) {
        //退款过号
        HDOrderManageViewController *ordersVC = [HDOrderManageViewController new];
        ordersVC.index = 3;
        [self.navigationController pushViewController:ordersVC animated:YES];
    }
    
    if (type == FunctionTypeSuperQuanyi) {
        //超级权益
        HDSuperEquityViewController *eauityVC = [HDSuperEquityViewController new];
        eauityVC.type = @"1";
        [self.navigationController pushViewController:eauityVC animated:YES];
    }
    if (type == FunctionTypeTaskMore) {
        //查看任务详情
        HDMyTaskListViewController *taskVC = [HDMyTaskListViewController new];
        [self.navigationController pushViewController:taskVC animated:YES];
    }
    if (type == FunctionTypeTaskCenter) {
        //任务中心
        HDNewTaskViewController *taskVC = [HDNewTaskViewController new];
        [self.navigationController pushViewController:taskVC animated:YES];
    }
    if (type == FunctionTypeMemberCenterInvite) {
        //邀请好友
        [HDToolHelper runMainQueue:^{
            if (self.shareInfo) {
                NSString *urlShare = [NSString stringWithFormat:@"%@?parentId=%@",self.shareInfo[@"privilegeUrl"],[HDUserDefaultMethods getData:@"userId"]];
                [HDToolHelper createShareUI:@{@"title":self.shareInfo[@"shareInviteTitle"],@"subImage":self.shareInfo[@"shareInviteImg"],@"shareTitle":self.shareInfo[@"shareInviteDes"],@"url":urlShare} controller:self];
            }
            else{
                [PersonViewModels getShareInfo:^(NSDictionary * _Nonnull result) {
                    self.shareInfo = result;
                    NSString *urlShare = [NSString stringWithFormat:@"%@?parentId=%@",self.shareInfo[@"privilegeUrl"],[HDUserDefaultMethods getData:@"userId"]];
                    [HDToolHelper createShareUI:@{@"title":self.shareInfo[@"shareInviteTitle"],@"subImage":self.shareInfo[@"shareInviteImg"],@"shareTitle":self.shareInfo[@"shareInviteDes"],@"url":urlShare} controller:self];
                }];
            }
        }];
    }
    if (type == FunctionTypeMemberCenterBeOwner) {
        //成为店主
        HDShopRegisterViewController *shopRegVC = [HDShopRegisterViewController new];
        [self.navigationController pushViewController:shopRegVC animated:YES];
    }
    if (type == FunctionTypeMemberCenterInviteWaiter) {
        //邀请店员
        HDInviteWaiterViewController *inviateVC = [HDInviteWaiterViewController new];
        [self.navigationController pushViewController:inviateVC animated:YES];
    }
    if (type == FunctionTypeMemeberCenterNewerTeach) {
        //新手教程
        HDSuperEquityViewController *userVC = [HDSuperEquityViewController new];
        userVC.type = @"2";
        [self.navigationController pushViewController:userVC animated:YES];
    }
    if (type == FunctionTypeMyServiceAccount) {
        //提现账户
        HDMyBankCardViewController *bankVC = [[HDMyBankCardViewController alloc] init];
        [self.navigationController pushViewController:bankVC animated:YES];
    }
    if (type == FunctionTypeMyServiceMaterial) {
        //地推物料
    }
    if (type == FunctionTypeMyServiceCollect) {
        //我的收藏
        HDMyCollectionsViewController *collectVC = [HDMyCollectionsViewController new];
        [self.navigationController pushViewController:collectVC animated:YES];
    }
    if (type == FunctionTypeMyServiceRules) {
        //平台规则
        HDPlatformRulesViewController *rulesVC = [HDPlatformRulesViewController new];
        [self.navigationController pushViewController:rulesVC animated:YES];
    }
    if (type == FunctionTypeMyServiceQuestion) {
        //常见问题
        HDQuestionsViewController *questionVC = [HDQuestionsViewController new];
        [self.navigationController pushViewController:questionVC animated:YES];
    }
    if (type == FunctionTypeMyServiceAbout) {
        //关于
        HDAboutUsViewController *aboutVC = [[HDAboutUsViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
    if (type == FunctionTypeMyServiceYuyueTime) {
        //理发预约时段
        HDTimeConfigViewController *timeVC = [HDTimeConfigViewController new];
        [self.navigationController pushViewController:timeVC animated:YES];
    }
    if (type == FunctionTypeMyServiceProfitTongji) {
        //收益统计
        HDMysStoreIncomTotalViewController *incomeVC = [HDMysStoreIncomTotalViewController new];
        [self.navigationController pushViewController:incomeVC animated:YES];
    }
    if (type == FunctionTypeMyServiceStoreInfo) {
        //门店信息
        HDEditShopInfoViewController *shopVC = [HDEditShopInfoViewController new];
        shopVC.shop_id = [HDUserDefaultMethods getData:@"storeId"];
        [self.navigationController pushViewController:shopVC animated:YES];
    }
    if (type == FunctionTypeMyServiceMyStoreWaiter) {
        //我的店员
        HDMyShopWaiterViewController *waiterVC = [HDMyShopWaiterViewController new];
        [self.navigationController pushViewController:waiterVC animated:YES];
    }
    if (type == FunctionTypeMyServiceCountDetail) {
        //服务项目
        HDShopConfigViewController *shopConfigVC = [HDShopConfigViewController new];
        [self.navigationController pushViewController:shopConfigVC animated:YES];
    }
    if (type == FunctionTypeMyServiceWeijianli) {
        //微简历
        HDTinyResumeViewController *tinyVC = [HDTinyResumeViewController new];
        [self.navigationController pushViewController:tinyVC animated:YES];
    }
    if (type == FunctionTypeMyServiceWaiterInfo) {
        //员工信息
        HDWaiterInfoEditViewController *infoVC = [HDWaiterInfoEditViewController new];
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}


@end
