//
//  HDNewPersonalView.m
//  HairDress
//
//  Created by 张凯中 on 2020/4/30.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDNewPersonalView.h"

@interface HDNewPersonalView ()

@property (nonatomic,strong) UIView *personInfoView;//个人信息
@property (nonatomic,strong) UIView *profitView;//收益
@property (nonatomic,strong) UIView *tuanzhangView;//升级团长
@property (nonatomic,strong) UIView *memberView;//会员详情
@property (nonatomic,strong) UIView *calendarView;//剪发日历
@property (nonatomic,strong) UIView *myCutOrderView;//我的剪发订单
@property (nonatomic,strong) UIView *cutOrderView;//剪发订单
@property (nonatomic,strong) UIView *memberQuanyiView;//会员权益
@property (nonatomic,strong) UIView *taskView;//任务
@property (nonatomic,strong) UIView *memberCenterView;//会员中心
@property (nonatomic,strong) UIView *myServiceView;//我的服务

@property (nonatomic,assign) BOOL status;//登录状态：1已登陆，0未登录
@property (nonatomic,copy) NSString *storeType;//用户身份

@property (nonatomic,copy) NSString *version;// 版本号

@end

@implementation HDNewPersonalView

-(instancetype)initWithFrame:(CGRect)frame type:(BOOL)logOut{
    if (self = [super initWithFrame:frame]) {
        self.status = logOut;
        self.storeType = [HDUserDefaultMethods getData:@"storePost"];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        self.version = [NSString stringWithFormat:@"V%@",appVersion];
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    if (self.status) {
        [self addSubview:self.personInfoView];
        [self addSubview:self.profitView];
        [self addSubview:self.tuanzhangView];
//        [self addSubview:self.memberView];
        [self addSubview:self.calendarView];
        [self addSubview:self.myCutOrderView];
        [self addSubview:self.cutOrderView];
        [self addSubview:self.memberQuanyiView];
//        [self addSubview:self.taskView];
        [self addSubview:self.memberCenterView];
        [self addSubview:self.myServiceView];
        
//        NSArray *arrBtns = @[@{@"title":@"提现",@"image":@"membercentre_ic_withdraw"},@{@"title":@"粉丝",@"image":@"membercentre_ic_fans"},@{@"title":@"淘宝订单",@"image":@"membercentre_ic_tborder"}];
//        [self createMemberView:arrBtns];
        
        [self resetUI];
    }
    else{
        [self addSubview:self.personInfoView];
        
        [self addSubview:self.memberQuanyiView];
        self.memberQuanyiView.y = self.personInfoView.bottom;
        
        [self addSubview:self.memberCenterView];
        self.memberCenterView.y = self.memberQuanyiView.bottom;
        
        NSArray *arr = @[
            @{@"title":@"成为店主",@"subTitle":@"分享团队，坐享收益",@"image":@"membercentre_ic_becomeowner"},@{@"title":@"新手教程",@"subTitle":@"初入巢流必读攻略",@"image":@"membercentre_ic_tutorial"}];
        [self createMemberCenterView:arr];
        
        [self addSubview:self.myServiceView];
        self.myServiceView.y = self.memberCenterView.bottom;
        
        //我的服务
        NSArray *arrServices = @[
        @{@"title":@"收藏夹",@"subTitle":@"收藏喜欢的商品",@"image":@"membercentre_ic_favorites"},
        @{@"title":@"平台规则",@"subTitle":@"请严格遵守",@"image":@"membercentre_ic_rule"},
        @{@"title":@"常见问题",@"subTitle":@"有疑问点这里",@"image":@"membercentre_ic_question"},
            @{@"title":@"关于巢流",@"subTitle":self.version,@"image":@"membercentre_ic_about"}];
        [self createMyServiceView:arrServices];
        
        self.height = _myServiceView.bottom;
    }
}

//刷新UI
-(void)reloadUIWithData:(NSDictionary *)memberInfo complete:(nonnull void (^)(void))block{
    
    UIImageView *imageHead = (UIImageView *)[_personInfoView viewWithTag:100];
    [imageHead sd_setImageWithURL:[NSURL URLWithString:memberInfo[@"headImg"]] placeholderImage:[UIImage imageNamed:@"personal_default"]];
    
    if (![memberInfo[@"storePost"] isEqualToString:[HDUserDefaultMethods getData:@"storePost"]]) {
        self.storeType = memberInfo[@"storePost"];
        [self resetUI];
    }
    // 缓存用户信息
    [HDToolHelper saveData:memberInfo];
    
    //数据更新完成回调
    block();
}

//刷新用户收益数据
-(void)reloadProfitData:(NewPersonInfoModel *)profitData{
    UILabel *lblMoney = (UILabel *)[_profitView viewWithTag:200];
//    UILabel *lblToday = (UILabel *)[_profitView viewWithTag:202];
//    UILabel *lblMonth = (UILabel *)[_profitView viewWithTag:203];
//    UILabel *lblLastMonth = (UILabel *)[_profitView viewWithTag:204];
    
    lblMoney.text = [NSString stringWithFormat:@"%.2f",[profitData.canGetFee floatValue]];
    [lblMoney sizeToFit];
    lblMoney.height = 20*SCALE;
    
//    lblToday.text = [NSString stringWithFormat:@"¥%.2f",[profitData.todayPredictFee floatValue]];
//    lblMonth.text = [NSString stringWithFormat:@"¥%.2f",[profitData.monthPredictFee floatValue]];
//    lblLastMonth.text = [NSString stringWithFormat:@"¥%.2f",[profitData.lastMonthSettledFee floatValue]];
    
    //个人信息
    UILabel *lblName = (UILabel *)[_personInfoView viewWithTag:101];
    UIView *viewIdenti = (UIView *)[_personInfoView viewWithTag:103];
    UIButton *btnScan = (UIButton *)[_personInfoView viewWithTag:99];
    UILabel *lblIdentiName = (UILabel *)[viewIdenti viewWithTag:10000];
    UIImageView *imageIden = (UIImageView *)[viewIdenti viewWithTag:20000];
    
    lblName.text = [HDUserDefaultMethods getData:@"nickName"];
    [lblName sizeToFit];
    lblName.height = 20*SCALE;
    
    viewIdenti.hidden = NO;
    
    lblIdentiName.text = profitData.identityName;
    [lblIdentiName sizeToFit];
    lblIdentiName.centerY = viewIdenti.height/2;
    lblIdentiName.x = CGRectGetMaxX(imageIden.frame)+3*SCALE;
    
    viewIdenti.centerY = lblName.centerY;
    viewIdenti.x = CGRectGetMaxX(lblName.frame) + 12*SCALE;
    viewIdenti.width = CGRectGetMaxX(lblIdentiName.frame) + 6*SCALE;
    
    // 判断宽度是否会超出屏幕宽度
    if (CGRectGetMaxX(viewIdenti.frame) + 12*SCALE > btnScan.x) {
        viewIdenti.x = btnScan.x - 12*SCALE - viewIdenti.width;
        lblName.width = viewIdenti.x -12*SCALE - lblName.x;
    }
    
    if ([profitData.isUpgrade isEqualToString:@"T"]) {
        _tuanzhangView.hidden = NO;
        
//        _memberView.y = _tuanzhangView.bottom+8*SCALE;
        if ([self.storeType isEqualToString:@"B"]) {
            _profitView.hidden = NO;
            _tuanzhangView.y = _profitView.bottom;
            _calendarView.y = _tuanzhangView.bottom+8*SCALE;
        }else{
            _profitView.hidden = YES;
            _tuanzhangView.y = _personInfoView.bottom;
            _calendarView.y = _tuanzhangView.bottom+8*SCALE;
        }
        
        if ([self.storeType isEqualToString:@"B"] || [self.storeType isEqualToString:@"T"]) {
            _myCutOrderView.hidden = NO;
            _myCutOrderView.y = _calendarView.bottom;
            _cutOrderView.y = _myCutOrderView.bottom+8*SCALE;
        }
        else {
            _myCutOrderView.hidden = YES;
            _cutOrderView.y = _calendarView.bottom;
        }
        _memberQuanyiView.y = _cutOrderView.bottom;
        
        //是否显示任务中心
//        if ([profitData.iosIsShowTask isEqualToString:@"T"]) {
//            _taskView.hidden = NO;
//            _taskView.y = _memberQuanyiView.bottom+8*SCALE;
//            _memberCenterView.y = _taskView.bottom;
//
//            NSArray *arrBtns = @[@{@"title":@"提现",@"image":@"membercentre_ic_withdraw"},@{@"title":@"粉丝",@"image":@"membercentre_ic_fans"},@{@"title":@"淘宝订单",@"image":@"membercentre_ic_tborder"},@{@"title":@"其他订单",@"image":@"membercentre_ic_order"}];
//            [self createMemberView:arrBtns];
//        }
//        else{
//            _taskView.hidden = YES;
//            _memberCenterView.y = _memberQuanyiView.bottom;
//
//            NSArray *arrBtns = @[@{@"title":@"提现",@"image":@"membercentre_ic_withdraw"},@{@"title":@"粉丝",@"image":@"membercentre_ic_fans"},@{@"title":@"淘宝订单",@"image":@"membercentre_ic_tborder"}];
//            [self createMemberView:arrBtns];
//        }
        _memberCenterView.y = _memberQuanyiView.bottom;
        _myServiceView.y = _memberCenterView.bottom;
        
        self.height = _myServiceView.bottom;
        
    }else{
        _tuanzhangView.hidden = YES;
        
//        _memberView.y = _profitView.bottom+8*SCALE;
        if ([self.storeType isEqualToString:@"B"]) {
            _profitView.hidden = NO;
            _calendarView.y = _profitView.bottom+8*SCALE;
        }else{
            _profitView.hidden = YES;
            _calendarView.y = _personInfoView.bottom;
        }
        if ([self.storeType isEqualToString:@"B"] || [self.storeType isEqualToString:@"T"]) {
            _myCutOrderView.hidden = NO;
            _myCutOrderView.y = _calendarView.bottom;
            _cutOrderView.y = _myCutOrderView.bottom+8*SCALE;
        }
        else {
            _myCutOrderView.hidden = YES;
            _cutOrderView.y = _calendarView.bottom;
        }
        _memberQuanyiView.y = _cutOrderView.bottom;
        
//        if ([profitData.iosIsShowTask isEqualToString:@"T"]) {
//            _taskView.hidden = NO;
//            _taskView.y = _memberQuanyiView.bottom+8*SCALE;
//            _memberCenterView.y = _taskView.bottom;
//
//            NSArray *arrBtns = @[@{@"title":@"提现",@"image":@"membercentre_ic_withdraw"},@{@"title":@"粉丝",@"image":@"membercentre_ic_fans"},@{@"title":@"淘宝订单",@"image":@"membercentre_ic_tborder"},@{@"title":@"其他订单",@"image":@"membercentre_ic_order"}];
//            [self createMemberView:arrBtns];
//        }
//        else{
//            _taskView.hidden = YES;
//            _memberCenterView.y = _memberQuanyiView.bottom;
//
//            NSArray *arrBtns = @[@{@"title":@"提现",@"image":@"membercentre_ic_withdraw"},@{@"title":@"粉丝",@"image":@"membercentre_ic_fans"},@{@"title":@"淘宝订单",@"image":@"membercentre_ic_tborder"}];
//            [self createMemberView:arrBtns];
//        }
        _memberCenterView.y = _memberQuanyiView.bottom;
        _myServiceView.y = _memberCenterView.bottom;
        
        self.height = _myServiceView.bottom;
    }
}

//刷新界面
-(void)resetUI{
    if ([self.storeType isEqualToString:@"B"]) {
        // 店主
        NSArray *arr = @[
//        @{@"title":@"邀请好友",@"subTitle":@"自用省钱，分享赚钱",@"image":@"membercentre_ic_invitefriends"},
        @{@"title":@"招募店员",@"subTitle":@"分享团队，坐享收益",@"image":@"membercentre_ic_becomeowner"},
        @{@"title":@"新手教程",@"subTitle":@"初入巢流必读攻略",@"image":@"membercentre_ic_tutorial"}];
        [self createMemberCenterView:arr];
        
        //我的服务
        NSArray *arrServices = @[
            @{@"title":@"预约理发时段",@"subTitle":@"编辑预约理发时段",@"image":@"membercentre_ic_order-1"},
            @{@"title":@"收益统计",@"subTitle":@"查看店铺收益概况",@"image":@"membercentre_ic_profit"},
            @{@"title":@"我的店员",@"subTitle":@"修改店员身份",@"image":@"membercentre_ic_mystaff"},
            @{@"title":@"门店信息",@"subTitle":@"编辑门店信息",@"image":@"membercentre_ic_store"},
            @{@"title":@"服务项目",@"subTitle":@"配置服务项目",@"image":@"membercentre_ic_project"},
            @{@"title":@"提现账户",@"subTitle":@"支付宝或者微信授权",@"image":@"membercentre_ic_withdrawalaccount"},
            @{@"title":@"收藏夹",@"subTitle":@"收藏喜欢的商品",@"image":@"membercentre_ic_favorites"},
            @{@"title":@"微简历",@"subTitle":@"编辑工作简历",@"image":@"membercentre_ic_reservation"},
            @{@"title":@"平台规则",@"subTitle":@"请严格遵守",@"image":@"membercentre_ic_rule"},
            @{@"title":@"常见问题",@"subTitle":@"有疑问点这里",@"image":@"membercentre_ic_question"},
            @{@"title":@"关于巢流",@"subTitle":self.version,@"image":@"membercentre_ic_about"}
        ];
        
        [self createMyServiceView:arrServices];
    }
    else if ([self.storeType isEqualToString:@"T"]){
        // 发型师
        NSArray *arr = @[
//        @{@"title":@"邀请好友",@"subTitle":@"自用省钱，分享赚钱",@"image":@"membercentre_ic_invitefriends"},
        @{@"title":@"成为店主",@"subTitle":@"分享团队，坐享收益",@"image":@"membercentre_ic_becomeowner"},
        @{@"title":@"新手教程",@"subTitle":@"初入巢流必读攻略",@"image":@"membercentre_ic_tutorial"}];
        [self createMemberCenterView:arr];
        
        //我的服务
        NSArray *arrServices = @[
            @{@"title":@"收藏夹",@"subTitle":@"收藏喜欢的商品",@"image":@"membercentre_ic_favorites"},
            @{@"title":@"微简历",@"subTitle":@"编辑工作简历",@"image":@"membercentre_ic_reservation"},
            @{@"title":@"平台规则",@"subTitle":@"请严格遵守",@"image":@"membercentre_ic_rule"},
            @{@"title":@"常见问题",@"subTitle":@"有疑问点这里",@"image":@"membercentre_ic_question"},
            @{@"title":@"关于巢流",@"subTitle":self.version,@"image":@"membercentre_ic_about"}
        ];
        
        [self createMyServiceView:arrServices];
    }
    else if ([self.storeType isEqualToString:@"O"]){
        // 普通店员
        NSArray *arr = @[
//        @{@"title":@"邀请好友",@"subTitle":@"自用省钱，分享赚钱",@"image":@"membercentre_ic_invitefriends"},
        @{@"title":@"成为店主",@"subTitle":@"分享团队，坐享收益",@"image":@"membercentre_ic_becomeowner"},
        @{@"title":@"新手教程",@"subTitle":@"初入巢流必读攻略",@"image":@"membercentre_ic_tutorial"}];
        [self createMemberCenterView:arr];
        
        //我的服务
        NSArray *arrServices = @[
            @{@"title":@"收藏夹",@"subTitle":@"收藏喜欢的商品",@"image":@"membercentre_ic_favorites"},
            @{@"title":@"员工信息",@"subTitle":@"编辑员工信息",@"image":@"membercentre_ic_withdrawalaccount"},
            @{@"title":@"平台规则",@"subTitle":@"请严格遵守",@"image":@"membercentre_ic_rule"},
            @{@"title":@"常见问题",@"subTitle":@"有疑问点这里",@"image":@"membercentre_ic_question"},
            @{@"title":@"关于巢流",@"subTitle":self.version,@"image":@"membercentre_ic_about"}
        ];
        
        [self createMyServiceView:arrServices];
    }
    else{
        // 普通用户
        NSArray *arr = @[
//        @{@"title":@"邀请好友",@"subTitle":@"自用省钱，分享赚钱",@"image":@"membercentre_ic_invitefriends"},
        @{@"title":@"成为店主",@"subTitle":@"分享团队，坐享收益",@"image":@"membercentre_ic_becomeowner"},@{@"title":@"新手教程",@"subTitle":@"初入巢流必读攻略",@"image":@"membercentre_ic_tutorial"}];
        [self createMemberCenterView:arr];
        
        //我的服务
        NSArray *arrServices = @[
            @{@"title":@"收藏夹",@"subTitle":@"收藏喜欢的商品",@"image":@"membercentre_ic_favorites"},
            @{@"title":@"平台规则",@"subTitle":@"请严格遵守",@"image":@"membercentre_ic_rule"},
            @{@"title":@"常见问题",@"subTitle":@"有疑问点这里",@"image":@"membercentre_ic_question"},
            @{@"title":@"关于巢流",@"subTitle":self.version,@"image":@"membercentre_ic_about"}
        ];
        
        [self createMyServiceView:arrServices];
    }
    
    self.height = _myServiceView.bottom;
}

//刷新店主或发型师预约订单数量
-(void)reloadOrderNumData:(NewPersonInfoModel *)orderNumData{
    UIButton *btn = (UIButton *)[_myCutOrderView viewWithTag:550];
    UIButton *btn1 = (UIButton *)[_myCutOrderView viewWithTag:551];
    UIButton *btn2 = (UIButton *)[_myCutOrderView viewWithTag:552];
    UIButton *btn3 = (UIButton *)[_myCutOrderView viewWithTag:553];
    
    UILabel *lblNum = (UILabel *)[btn viewWithTag:1000];
    UILabel *lblNum1 = (UILabel *)[btn1 viewWithTag:1000];
    UILabel *lblNum2 = (UILabel *)[btn2 viewWithTag:1000];
    UILabel *lblNum3 = (UILabel *)[btn3 viewWithTag:1000];
    
    if ([orderNumData.queueOrderNum intValue] >0) {
        lblNum.hidden = NO;
        if ([orderNumData.queueOrderNum intValue] > 99) {
            lblNum.text = @"99+";
        }else{
            lblNum.text = [NSString stringWithFormat:@"%ld",(long)[orderNumData.queueOrderNum intValue]];
        }
    }else{
        lblNum.hidden = YES;
    }
    
    if ([orderNumData.serviceOrderNum intValue] > 0) {
        lblNum1.hidden = NO;
        if ([orderNumData.serviceOrderNum intValue] > 99) {
            lblNum1.text = @"99+";
        }else{
            lblNum1.text = [NSString stringWithFormat:@"%ld",(long)[orderNumData.serviceOrderNum intValue]];
        }
    }else{
        lblNum1.hidden = YES;
    }
    
    if ([orderNumData.finishOrderNum intValue]> 0) {
        lblNum2.hidden = NO;
        if ([orderNumData.finishOrderNum intValue] > 99) {
            lblNum2.text = @"99+";
        }else{
            lblNum2.text = [NSString stringWithFormat:@"%d",[orderNumData.finishOrderNum intValue]];
        }
    }else{
        lblNum2.hidden = YES;
    }
    
    if ([orderNumData.cancelOrderNum intValue] > 0) {
        lblNum3.hidden = NO;
        if ([orderNumData.cancelOrderNum intValue] > 99) {
            lblNum3.text = @"99+";
        }else{
            lblNum3.text = [NSString stringWithFormat:@"%d",[orderNumData.cancelOrderNum intValue]];
        }
    }else{
        lblNum3.hidden = YES;
    }
}

//刷新用户理发订单数量
-(void)reloadUserOrderNumData:(NewPersonInfoModel *)orderNumData{
    UIButton *btn = (UIButton *)[_cutOrderView viewWithTag:600];
    UIButton *btn1 = (UIButton *)[_cutOrderView viewWithTag:601];
    UIButton *btn2 = (UIButton *)[_cutOrderView viewWithTag:602];
    UIButton *btn3 = (UIButton *)[_cutOrderView viewWithTag:603];
    UIButton *btn4 = (UIButton *)[_cutOrderView viewWithTag:604];
    
    UILabel *lblNum = (UILabel *)[btn viewWithTag:1000];
    UILabel *lblNum1 = (UILabel *)[btn1 viewWithTag:1000];
    UILabel *lblNum2 = (UILabel *)[btn2 viewWithTag:1000];
    UILabel *lblNum3 = (UILabel *)[btn3 viewWithTag:1000];
    UILabel *lblNum4 = (UILabel *)[btn4 viewWithTag:1000];
    
    if ([orderNumData.userWaitOrQueueNum intValue] >0) {
        lblNum.hidden = NO;
        if ([orderNumData.userWaitOrQueueNum intValue] > 99) {
            lblNum.text = @"99+";
        }else{
            lblNum.text = [NSString stringWithFormat:@"%ld",(long)[orderNumData.userWaitOrQueueNum intValue]];
        }
    }else{
        lblNum.hidden = YES;
    }
    
    if ([orderNumData.userPayNum intValue] > 0) {
        lblNum1.hidden = NO;
        if ([orderNumData.userPayNum intValue] > 99) {
            lblNum1.text = @"99+";
        }else{
            lblNum1.text = [NSString stringWithFormat:@"%ld",(long)[orderNumData.userPayNum intValue]];
        }
    }else{
        lblNum1.hidden = YES;
    }
    
    if ([orderNumData.userServiceNum intValue]> 0) {
        lblNum2.hidden = NO;
        if ([orderNumData.userServiceNum intValue] > 99) {
            lblNum2.text = @"99+";
        }else{
            lblNum2.text = [NSString stringWithFormat:@"%d",[orderNumData.userServiceNum intValue]];
        }
    }else{
        lblNum2.hidden = YES;
    }
    
    if ([orderNumData.userFinishNum intValue] > 0) {
        lblNum3.hidden = NO;
        if ([orderNumData.userFinishNum intValue] > 99) {
            lblNum3.text = @"99+";
        }else{
            lblNum3.text = [NSString stringWithFormat:@"%d",[orderNumData.userFinishNum intValue]];
        }
    }else{
        lblNum3.hidden = YES;
    }
    
    if ([orderNumData.userCancelNum intValue] > 0) {
        lblNum4.hidden = NO;
        if ([orderNumData.userCancelNum intValue] > 99) {
            lblNum4.text = @"99+";
        }else{
            lblNum4.text = [NSString stringWithFormat:@"%d",[orderNumData.userCancelNum intValue]];
        }
    }else{
        lblNum4.hidden = YES;
    }
}

#pragma mark -- 个人信息
-(UIView *)personInfoView{
    if (!_personInfoView) {
        _personInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 166*SCALE)];
        
        UIButton *btnSet = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-12*SCALE-40*SCALE, NAVHIGHT-30*SCALE, 40*SCALE, 30*SCALE) btnTitle:@"设置" btnImage:@"" titleColor:RGBCOLOR(20, 20, 20) titleFont:16*SCALE];
        [_personInfoView addSubview:btnSet];
        [btnSet addTarget:self action:@selector(btnSetAction) forControlEvents:UIControlEventTouchUpInside];
        
//        UIButton *btnMsg = [[UIButton alloc] initSystemWithFrame:CGRectMake(btnSet.x-16*SCALE-40*SCALE, NAVHIGHT-30*SCALE, 40*SCALE, 30*SCALE) btnTitle:@"消息" btnImage:@"" titleColor:RGBCOLOR(20, 20, 20) titleFont:16*SCALE];
//        [btnMsg addTarget:self action:@selector(btnMsgAction) forControlEvents:UIControlEventTouchUpInside];
//        [_personInfoView addSubview:btnMsg];
        
        //扫一扫
        UIButton *btnScan = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-15*SCALE-23*SCALE, 78*SCALE, 23*SCALE, 23*SCALE) btnTitle:@"" btnImage:@"membercentre_ic_scan" titleColor:RGBCOLOR(20, 20, 20) titleFont:16*SCALE];
        btnScan.tag = 99;
        [btnScan addTarget:self action:@selector(btnScanAction) forControlEvents:UIControlEventTouchUpInside];
        [_personInfoView addSubview:btnScan];
        
        UIImageView *imageHead = [[UIImageView alloc] initWithFrame:CGRectMake(16*SCALE, 74*SCALE, 64*SCALE, 64*SCALE)];
        imageHead.tag = 100;
        imageHead.contentMode = 2;
        [_personInfoView addSubview:imageHead];
        imageHead.layer.cornerRadius = 64*SCALE/2;
        imageHead.layer.masksToBounds = YES;
        imageHead.image = [UIImage imageNamed:@"personal_default"];
        
        //点击头像
        UITapGestureRecognizer *tapHead = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeadAction:)];
        imageHead.userInteractionEnabled = YES;
        [imageHead addGestureRecognizer:tapHead];
        
        UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageHead.frame)+10*SCALE, 79*SCALE, 100, 20*SCALE) title:@"" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(20, 20, 20) titleFont:20*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        lblName.tag = 101;
        lblName.centerY = imageHead.centerY;
        lblName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 20*SCALE);
        [_personInfoView addSubview:lblName];
        btnScan.centerY = imageHead.centerY;
        
        //点击名字
        UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeadAction:)];
        lblName.userInteractionEnabled = YES;
        [lblName addGestureRecognizer:tapName];
        
        //用户级别
        UIImageView *imageHehuoren = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"membercentre_ic_partner"]];
        imageHehuoren.x = CGRectGetMaxX(lblName.frame)+12*SCALE;
        imageHehuoren.centerY = lblName.centerY;
        imageHehuoren.tag = 102;
        imageHehuoren.hidden = YES;
        [_personInfoView addSubview:imageHehuoren];
        
        //用户级别名称
        UIView *viewIdenti = [[UIView alloc] initWithFrame:CGRectMake(0, 16*SCALE, 100, 20*SCALE)];
        viewIdenti.tag = 103;
        [_personInfoView addSubview:viewIdenti];
        viewIdenti.layer.cornerRadius = 4;
        viewIdenti.hidden = YES;
        viewIdenti.backgroundColor = RGBCOLOR(12, 12, 12);
        
        UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"membercentre_ic_partner"]];
        imageV.tag = 20000;
        imageV.x = 6*SCALE;
        imageV.centerY = viewIdenti.height/2;
        [viewIdenti addSubview:imageV];
        
        UILabel *lblIdentiName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblName.frame)+12*SCALE, 79*SCALE, 100, 20*SCALE) title:@"" bgColor:RGBCOLOR(12, 12, 12) titleColor:[UIColor whiteColor] titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        lblIdentiName.tag = 10000;
        [viewIdenti addSubview:lblIdentiName];
        
//        UILabel *lblYaoQingKouling = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageHead.frame)+10*SCALE, lblName.bottom+24*SCALE, 100, 12*SCALE) title:[NSString stringWithFormat:@"邀请口令：%@",[HDUserDefaultMethods getData:@"userId"]] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(150, 150, 150) titleFont:12*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
//        lblYaoQingKouling.height = 12*SCALE;
//        lblYaoQingKouling.tag = 104;
//        [_personInfoView addSubview:lblYaoQingKouling];
        
//        UIButton *btnCopy = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(lblYaoQingKouling.frame)+13*SCALE, 0, 30*SCALE, 20*SCALE) btnTitle:@"复制" btnImage:@"" titleColor:RGBCOLOR(150, 150, 150) titleFont:12*SCALE];
//        btnCopy.tag = 104;
//        btnCopy.centerY = lblYaoQingKouling.centerY;
//        [_personInfoView addSubview:btnCopy];
//
//        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, btnCopy.height-0.5, btnCopy.width, 0.5)];
//        line1.backgroundColor = RGBCOLOR(150, 150, 150);
//        line1.centerX = btnCopy.width/2;
//        [btnCopy addSubview:line1];
        
//        UIButton *btnYincang = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(btnCopy.frame)+8*SCALE, 0, 30*SCALE, 20*SCALE) btnTitle:@"隐藏" btnImage:@"" titleColor:RGBCOLOR(150, 150, 150) titleFont:12*SCALE];
//        btnYincang.tag = 105;
//        btnYincang.centerY = lblYaoQingKouling.centerY;
//        [_personInfoView addSubview:btnYincang];
//        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, btnYincang.height-0.5, 25*SCALE, 0.5)];
//        line2.backgroundColor = RGBCOLOR(150, 150, 150);
//        line2.centerX = btnYincang.width/2;
//        [btnYincang addSubview:line2];
        
        if (!self.status) {
            btnSet.hidden = YES;
//            btnMsg.hidden = YES;
            imageHead.image = [UIImage imageNamed:@"membercentre_ic_head"];
            lblName.text = @"立即登录/注册";
            lblName.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 20*SCALE);
            [lblName sizeToFit];
            lblName.centerY = imageHead.centerY;
            btnScan.centerY = imageHead.centerY;
            imageHehuoren.image = [UIImage imageNamed:@"membercentre_ic_sign"];
            imageHehuoren.x = CGRectGetMaxX(lblName.frame)+5;
            imageHehuoren.centerY = lblName.centerY;
            imageHehuoren.width = 11*SCALE;
            imageHehuoren.hidden = NO;
//            lblYaoQingKouling.hidden = YES;
//            btnCopy.hidden = YES;
//            btnYincang.hidden = YES;
            
            UITapGestureRecognizer *tapSign = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeadAction:)];
            imageHehuoren.userInteractionEnabled = YES;
            [imageHehuoren addGestureRecognizer:tapSign];
        }
    }
    return _personInfoView;
}

#pragma mark -- 收益视图
-(UIView *)profitView{
    if (!_profitView) {
        _profitView = [[UIView alloc] initWithFrame:CGRectMake(0, _personInfoView.bottom, kSCREEN_WIDTH, 66*SCALE)];
        
        UIImageView *imageBack = [[UIImageView alloc] initWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-32*SCALE, 66*SCALE)];
        imageBack.image = [UIImage imageNamed:@"bg_sale"];
        imageBack.layer.cornerRadius = 8;
        imageBack.layer.masksToBounds = YES;
        [_profitView addSubview:imageBack];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(14*SCALE, 26*SCALE, 10, 14*SCALE) title:@"可提现 ¥" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblText.height = 14*SCALE;
        [imageBack addSubview:lblText];
        
        UILabel *lblMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame), 0, 20, 20*SCALE) title:@"0" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:20*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        lblMoney.tag = 200;
        lblMoney.centerY = lblText.centerY;
        lblMoney.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 20*SCALE);
        [imageBack addSubview:lblMoney];
        
        UIButton *btnWithdrew = [[UIButton alloc] initCommonWithFrame:CGRectMake(imageBack.width-14*SCALE-90*SCALE, 0, 90*SCALE, 28*SCALE) btnTitle:@"立即提现" bgColor:[UIColor whiteColor] titleColor:HexRGBAlpha(0xFF0D1B, 1) titleFont:14*SCALE];
        btnWithdrew.layer.cornerRadius = btnWithdrew.height/2;
        btnWithdrew.tag = 201;
        btnWithdrew.centerY = lblText.centerY;
        [imageBack addSubview:btnWithdrew];
        imageBack.userInteractionEnabled = YES;
        [btnWithdrew addTarget:self action:@selector(btnWithdrewAction) forControlEvents:UIControlEventTouchUpInside];
        
//        //今日预估
//        UILabel *lblToday = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblText.bottom+26*SCALE, imageBack.width/3, 16*SCALE) title:@"¥0" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
//        lblToday.tag = 202;
//        lblToday.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 16*SCALE);
//        [imageBack addSubview:lblToday];
//        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblToday.frame), 71*SCALE, 1, 32*SCALE)];
//        line1.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
//        [imageBack addSubview:line1];
//        UILabel *lblTodayText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblToday.bottom+17*SCALE, imageBack.width/3, 12*SCALE) title:@"今日预估" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
//        [imageBack addSubview:lblTodayText];
//
//        //本月预估
//        UILabel *lblMonth = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblToday.frame), lblText.bottom+26*SCALE, imageBack.width/3, 16*SCALE) title:@"¥0" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
//        lblMonth.tag = 203;
//        lblMonth.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 16*SCALE);
//        [imageBack addSubview:lblMonth];
//        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblMonth.frame), 71*SCALE, 1, 32*SCALE)];
//        line2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
//        [imageBack addSubview:line2];
//        UILabel *lblMonthText = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblMonth.x, lblMonth.bottom+17*SCALE, imageBack.width/3, 12*SCALE) title:@"本月预估" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
//        [imageBack addSubview:lblMonthText];
//
//        //上月结算
//        UILabel *lblLastMonth = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblMonth.frame), lblText.bottom+26*SCALE, imageBack.width/3, 16*SCALE) title:@"¥0" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
//        lblLastMonth.tag = 204;
//        lblLastMonth.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 16*SCALE);
//        [imageBack addSubview:lblLastMonth];
//        UILabel *lblLastMonthText = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblLastMonth.x, lblLastMonth.bottom+17*SCALE, imageBack.width/3, 12*SCALE) title:@"上月结算" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
//        [imageBack addSubview:lblLastMonthText];
//
//        UILabel *lblmsg = [[UILabel alloc] initCommonWithFrame:CGRectMake(14*SCALE, imageBack.height-18*SCALE-10*SCALE, imageBack.width-28*SCALE, 10*SCALE) title:@"每月25号提现上月确认收货的订单收入" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:10*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
//        [imageBack addSubview:lblmsg];
    }
    return _profitView;
}

#pragma mark -- 升级团长
-(UIView *)tuanzhangView{
    if (!_tuanzhangView) {
        _tuanzhangView = [[UIView alloc] initWithFrame:CGRectMake(0, _profitView.bottom, kSCREEN_WIDTH, 64*SCALE)];
        
        UIImageView *imgeTuanBack = [[UIImageView alloc] initWithFrame:CGRectMake(16*SCALE, 8*SCALE, kSCREEN_WIDTH-32*SCALE, 48*SCALE)];
        imgeTuanBack.image = [UIImage imageNamed:@"membercentre_bg_02"];
        imgeTuanBack.userInteractionEnabled = YES;
        [_tuanzhangView addSubview:imgeTuanBack];
        
        UIImageView *imgeZhuanshi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"membercentre_ic_upgrade"]];
        imgeZhuanshi.x = 12*SCALE;
        imgeZhuanshi.centerY = imgeTuanBack.height/2;
        [imgeTuanBack addSubview:imgeZhuanshi];
        
        UILabel *lblUpdate = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgeZhuanshi.frame)+7*SCALE, 0, 100, 14*SCALE) title:@"0元升级享更多特权" bgColor:[UIColor clearColor] titleColor:HexRGBAlpha(0xE9C764, 1) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblUpdate.centerY = imgeZhuanshi.centerY;
        [imgeTuanBack addSubview:lblUpdate];
        
        UIButton *btnUp = [[UIButton alloc] initCommonWithFrame:CGRectMake(imgeTuanBack.width-12*SCALE-80*SCALE, 0, 80*SCALE, 24*SCALE) btnTitle:@"升级团长" bgColor:[UIColor clearColor] titleColor:HexRGBAlpha(0xE9C764, 1) titleFont:12*SCALE];
        btnUp.tag = 300;
        btnUp.centerY = imgeZhuanshi.centerY;
        [imgeTuanBack addSubview:btnUp];
        btnUp.layer.cornerRadius = 24*SCALE/2;
        btnUp.layer.borderWidth = 1;
        btnUp.layer.borderColor = HexRGBAlpha(0xDBC169, 1).CGColor;
        [btnUp addTarget:self action:@selector(btnUpTuanzhangAction) forControlEvents:UIControlEventTouchUpInside];
        
        _tuanzhangView.hidden = YES;
    }
    return _tuanzhangView;
}

#pragma mark -- 会员详情
-(UIView *)memberView{
    if (!_memberView) {
        _memberView = [[UIView alloc] initWithFrame:CGRectMake(0, _profitView.bottom+8*SCALE, kSCREEN_WIDTH, 134*SCALE)];
        _memberView.hidden = YES;
    }
    return _memberView;
}

-(void)createMemberView:(NSArray *)arrBtns{
    for (UIView *view in _memberView.subviews) {
        [view removeFromSuperview];
    }
    UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-32*SCALE, _memberView.height)];
    viewBack.backgroundColor = [UIColor whiteColor];
    [_memberView addSubview:viewBack];
    viewBack.layer.cornerRadius = 8*SCALE;
    
    UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 18*SCALE, viewBack.width-32*SCALE, 16*SCALE) title:@"会员详情（收益）" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
    lblText.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16*SCALE);
    [viewBack addSubview:lblText];
    
    UIButton *btnInfo = [[UIButton alloc] initCustomWithFrame:CGRectMake(viewBack.width-13*SCALE-70*SCALE, 0, 70*SCALE, 16*SCALE) btnTitle:@"查看概况 >" btnImage:@"" btnType:RIGHT bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE];
    [viewBack addSubview:btnInfo];
    btnInfo.centerY = lblText.centerY;
    [btnInfo addTarget:self action:@selector(btnMemberInfoTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    for (int i=0; i<arrBtns.count; i++) {
        UIButton *btn = [[UIButton alloc] initCustomWithFrame:CGRectMake(i*(viewBack.width/arrBtns.count), lblText.bottom, viewBack.width/arrBtns.count, viewBack.height-lblText.bottom-24*SCALE) btnTitle:arrBtns[i][@"title"] btnImage:arrBtns[i][@"image"] btnType:Top_24 bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE];
        btn.tag = 400+i;
        [btn addTarget:self action:@selector(btnMemberInfoTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewBack addSubview:btn];
    }
}

#pragma mark -- 剪发日历
-(UIView *)calendarView{
    if (!_calendarView) {
        _calendarView = [[UIView alloc] initWithFrame:CGRectMake(0, _profitView.bottom+8*SCALE, kSCREEN_WIDTH, 74*SCALE)];
        
        UIImageView *imgeTuanBack = [[UIImageView alloc] initWithFrame:CGRectMake(16*SCALE, 8*SCALE, kSCREEN_WIDTH-32*SCALE, 58*SCALE)];
        imgeTuanBack.image = [UIImage imageNamed:@"membercentre_bg_calendar"];
        [_calendarView addSubview:imgeTuanBack];
        
        UIImageView *imgeZhuanshi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"membercentre_ic_calendar"]];
        imgeZhuanshi.x = 24*SCALE;
        imgeZhuanshi.centerY = imgeTuanBack.height/2;
        [imgeTuanBack addSubview:imgeZhuanshi];
        
        UILabel *lblRIli = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgeZhuanshi.frame)+12*SCALE, 0, 100, 20*SCALE) title:@"剪发日历" bgColor:[UIColor clearColor] titleColor:HexRGBAlpha(0xF2E2C8, 1) titleFont:20*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblRIli.centerY = imgeZhuanshi.centerY;
        [imgeTuanBack addSubview:lblRIli];
        
        UIButton *btnCalender = [[UIButton alloc] initSystemWithFrame:CGRectMake(imgeTuanBack.width-8*SCALE-80*SCALE, 0, 80*SCALE, 30*SCALE) btnTitle:@"" btnImage:@"membercentre_bt_view" titleColor:[UIColor clearColor] titleFont:0];
        btnCalender.tag = 500;
        btnCalender.centerY = imgeZhuanshi.centerY;
        [imgeTuanBack addSubview:btnCalender];
        imgeTuanBack.userInteractionEnabled = YES;
        [btnCalender addTarget:self action:@selector(btnCalenderAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _calendarView;
}

#pragma mark -- 我的美发订单视图550
-(UIView *)myCutOrderView{
    if (!_myCutOrderView) {
        _myCutOrderView = [[UIView alloc] initWithFrame:CGRectMake(0, _calendarView.bottom, kSCREEN_WIDTH, 132*SCALE)];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-32*SCALE, _myCutOrderView.height)];
        viewBack.backgroundColor = [UIColor whiteColor];
        [_myCutOrderView addSubview:viewBack];
        viewBack.layer.cornerRadius = 8*SCALE;
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 18*SCALE, viewBack.width-32*SCALE, 16*SCALE) title:@"我的美发订单" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        lblText.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16*SCALE);
        [viewBack addSubview:lblText];
        
        UIButton *btnInfo = [[UIButton alloc] initCustomWithFrame:CGRectMake(viewBack.width-13*SCALE-80*SCALE, 0, 70*SCALE, 16*SCALE) btnTitle:@"查看更多订单 >" btnImage:@"" btnType:RIGHT bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE];
        btnInfo.tag = 549;
        [viewBack addSubview:btnInfo];
        btnInfo.centerY = lblText.centerY;
        [btnInfo addTarget:self action:@selector(btnOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *arrBtns = @[@{@"title":@"待接单",@"image":@"membercentre_ic_waitingorder"},@{@"title":@"已接单",@"image":@"membercentre_ic_myorder"},@{@"title":@"已完成",@"image":@"membercentre_ic_finishorder"},@{@"title":@"退款/过号",@"image":@"membercentre_ic_refund"}];
        for (int i=0; i<arrBtns.count; i++) {
            UIButton *btn = [[UIButton alloc] initCustomWithFrame:CGRectMake(i*(viewBack.width/arrBtns.count), lblText.bottom, viewBack.width/arrBtns.count, viewBack.height-lblText.bottom-24*SCALE) btnTitle:arrBtns[i][@"title"] btnImage:arrBtns[i][@"image"] btnType:Top_24 bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE];
            btn.tag = 550+i;
            [btn addTarget:self action:@selector(btnOrderAction:) forControlEvents:UIControlEventTouchUpInside];
            [viewBack addSubview:btn];
            
            UILabel *lblNum = [[UILabel alloc] initWithFrame:CGRectMake(btn.width/2+3, btn.height/2 - 23, 18, 18)];
            lblNum.tag = 1000;
            lblNum.backgroundColor = [UIColor whiteColor];
            lblNum.text = @"99+";
            lblNum.adjustsFontSizeToFitWidth = YES;
            lblNum.textColor = HexRGBAlpha(0xFF0000, 1);
            lblNum.textAlignment = NSTextAlignmentCenter;
            lblNum.font = [UIFont systemFontOfSize:12];
            [btn addSubview:lblNum];
            lblNum.layer.cornerRadius = 9;
            lblNum.layer.borderWidth = 1;
            lblNum.layer.borderColor = HexRGBAlpha(0xFF0000, 1).CGColor;
        }
        
        _myCutOrderView.hidden = YES;
    }
    return _myCutOrderView;
}

#pragma mark -- 我的美发预约订单视图600
-(UIView *)cutOrderView{
    if (!_cutOrderView) {
        _cutOrderView = [[UIView alloc] initWithFrame:CGRectMake(0, _calendarView.bottom, kSCREEN_WIDTH, 132*SCALE)];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-32*SCALE, _cutOrderView.height)];
        viewBack.backgroundColor = [UIColor whiteColor];
        [_cutOrderView addSubview:viewBack];
        viewBack.layer.cornerRadius = 8*SCALE;
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 18*SCALE, viewBack.width-32*SCALE, 16*SCALE) title:@"我的美发预约订单" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        lblText.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16*SCALE);
        [viewBack addSubview:lblText];
        
        UIButton *btnInfo = [[UIButton alloc] initCustomWithFrame:CGRectMake(viewBack.width-13*SCALE-80*SCALE, 0, 70*SCALE, 16*SCALE) btnTitle:@"查看更多订单 >" btnImage:@"" btnType:RIGHT bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE];
        btnInfo.tag = 599;
        [viewBack addSubview:btnInfo];
        btnInfo.centerY = lblText.centerY;
        [btnInfo addTarget:self action:@selector(btnOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *arrBtns = @[@{@"title":@"待消费",@"image":@"membercentre_ic_pendingconsumption"},@{@"title":@"待付款",@"image":@"membercentre_ic_pendingpayment"},@{@"title":@"服务中",@"image":@"membercentre_ic_serving"},@{@"title":@"已完成",@"image":@"membercentre_ic_finish"},@{@"title":@"退款/过号",@"image":@"membercentre_ic_overnumber"}];
        for (int i=0; i<arrBtns.count; i++) {
            UIButton *btn = [[UIButton alloc] initCustomWithFrame:CGRectMake(i*(viewBack.width/arrBtns.count), lblText.bottom, viewBack.width/arrBtns.count, viewBack.height-lblText.bottom-24*SCALE) btnTitle:arrBtns[i][@"title"] btnImage:arrBtns[i][@"image"] btnType:Top_24 bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE];
            btn.tag = 600+i;
            [btn addTarget:self action:@selector(btnOrderAction:) forControlEvents:UIControlEventTouchUpInside];
            [viewBack addSubview:btn];
            
            UILabel *lblNum = [[UILabel alloc] initWithFrame:CGRectMake(btn.width/2+3, btn.height/2 - 23, 18, 18)];
            lblNum.tag = 1000;
            lblNum.backgroundColor = [UIColor whiteColor];
            lblNum.text = @"9";
            lblNum.adjustsFontSizeToFitWidth = YES;
            lblNum.textColor = HexRGBAlpha(0xFF0000, 1);
            lblNum.textAlignment = NSTextAlignmentCenter;
            lblNum.font = [UIFont systemFontOfSize:12];
            [btn addSubview:lblNum];
            lblNum.layer.cornerRadius = 9;
            lblNum.layer.borderWidth = 1;
            lblNum.layer.borderColor = HexRGBAlpha(0xFF0000, 1).CGColor;
        }
    }
    return _cutOrderView;
}

#pragma mark -- 会员权益700
-(UIView *)memberQuanyiView{
    if (!_memberQuanyiView) {
        _memberQuanyiView = [[UIView alloc] initWithFrame:CGRectMake(0, _cutOrderView.bottom, kSCREEN_WIDTH, 74*SCALE)];
        
        UIImageView *imgeTuanBack = [[UIImageView alloc] initWithFrame:CGRectMake(16*SCALE, 8*SCALE, kSCREEN_WIDTH-32*SCALE, 58*SCALE)];
        imgeTuanBack.image = [UIImage imageNamed:@"membercentre_bg_02"];
        imgeTuanBack.userInteractionEnabled = YES;
        [_memberQuanyiView addSubview:imgeTuanBack];
        
        UILabel *lblRIli = [[UILabel alloc] initCommonWithFrame:CGRectMake(20*SCALE, 0, 100, 20*SCALE) title:@"巢流超级权益" bgColor:[UIColor clearColor] titleColor:HexRGBAlpha(0xF2E2C8, 1) titleFont:20*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblRIli.centerY = imgeTuanBack.height/2;
        [imgeTuanBack addSubview:lblRIli];
        
        UILabel *lblquanyi = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblRIli.frame)+8*SCALE, 0, 100, 20*SCALE) title:@"震撼来袭" bgColor:[UIColor clearColor] titleColor:HexRGBAlpha(0xF2E2C8, 1) titleFont:20*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblquanyi.centerY = imgeTuanBack.height/2;
        lblquanyi.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 20*SCALE);
        [imgeTuanBack addSubview:lblquanyi];
        
        UIButton *btnQuanyi = [[UIButton alloc] initSystemWithFrame:CGRectMake(imgeTuanBack.width-8*SCALE-88*SCALE, 0, 80*SCALE, 30*SCALE) btnTitle:@"" btnImage:@"membercentre_bt_view" titleColor:[UIColor clearColor] titleFont:0];
        btnQuanyi.tag = 700;
        btnQuanyi.centerY = imgeTuanBack.height/2;
        [imgeTuanBack addSubview:btnQuanyi];
        [btnQuanyi addTarget:self action:@selector(btnQuanyiAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _memberQuanyiView;
}

#pragma mark -- 我的任务800
-(UIView *)taskView{
    if (!_taskView) {
        _taskView = [[UIView alloc] initWithFrame:CGRectMake(0, _memberQuanyiView.bottom+8*SCALE, kSCREEN_WIDTH, 140*SCALE)];
        
        UIView *viewMain = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 0, _taskView.width-32*SCALE, _taskView.height)];
        viewMain.backgroundColor = [UIColor whiteColor];
        viewMain.layer.cornerRadius = 8;
        [_taskView addSubview:viewMain];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 18*SCALE, viewMain.width-32*SCALE, 16*SCALE) title:@"我的任务" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        lblText.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16*SCALE);
        [viewMain addSubview:lblText];
        
        UIButton *btnInfo = [[UIButton alloc] initCustomWithFrame:CGRectMake(viewMain.width-13*SCALE-70*SCALE, 0, 70*SCALE, 16*SCALE) btnTitle:@"任务中心 >" btnImage:@"" btnType:RIGHT bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE];
        [viewMain addSubview:btnInfo];
        btnInfo.centerY = lblText.centerY;
        [btnInfo addTarget:self action:@selector(btnMoreTaskAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //我的任务
        UIView *subViewTotalNum = [[UIView alloc] initWithFrame:CGRectMake(0, lblText.bottom, viewMain.width/3, viewMain.height)];
        [viewMain addSubview:subViewTotalNum];
        UILabel *lblTotalNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 32*SCALE, subViewTotalNum.width, 22*SCALE) title:@"0" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:22*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalNum addSubview:lblTotalNum];
        
        UILabel *lblTotalNumText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTotalNum.bottom+16*SCALE, subViewTotalNum.width, 12*SCALE) title:@"我的任务" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(89, 89, 89) titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalNum addSubview:lblTotalNumText];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(subViewTotalNum.width-1,20*SCALE,0.5,60*SCALE)];
        line1.backgroundColor = RGBCOLOR(216, 216, 216);
        [subViewTotalNum addSubview:line1];
        
        //累计收入
        UIView *subViewTotalMoney = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(subViewTotalNum.frame), lblText.bottom, viewMain.width/3, viewMain.height)];
        [viewMain addSubview:subViewTotalMoney];
        UILabel *lblTotalMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 32*SCALE, subViewTotalMoney.width, 22*SCALE) title:@"0" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:22*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalMoney addSubview:lblTotalMoney];
        
        UILabel *lblTotalMoneyText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTotalMoney.bottom+16*SCALE, subViewTotalMoney.width, 12*SCALE) title:@"累计收入 (元)" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(89, 89, 89) titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [subViewTotalMoney addSubview:lblTotalMoneyText];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(subViewTotalMoney.width-1,20*SCALE,0.5,60*SCALE)];
        line2.backgroundColor = RGBCOLOR(216, 216, 216);
        [subViewTotalMoney addSubview:line2];
        
        //看更多
        UIButton *btnWithdrew = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(subViewTotalMoney.frame)+17*SCALE, 66*SCALE, viewMain.width/3-34*SCALE, 30*SCALE) btnTitle:@"查看更多" btnImage:@"" titleColor:RGBLIGHT_TEXTINFO titleFont:12*SCALE];
        btnWithdrew.layer.cornerRadius = 30*SCALE/2;
        btnWithdrew.layer.borderWidth = 0.5;
        btnWithdrew.layer.borderColor = HexRGBAlpha(0xB9B9B9, 1).CGColor;
        [btnWithdrew addTarget:self action:@selector(btnMoreTaskAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewMain addSubview:btnWithdrew];
        
        _taskView.hidden = YES;
    }
    return _taskView;
}

#pragma mark -- 会员中心900
-(UIView *)memberCenterView{
    if (!_memberCenterView) {
        _memberCenterView = [[UIView alloc] initWithFrame:CGRectMake(0, _memberQuanyiView.bottom, kSCREEN_WIDTH, 158*SCALE)];
    }
    return _memberCenterView;
}

//会员中心菜单视图
-(void)createMemberCenterView:(NSArray *)arr{
    for (UIView *view in _memberCenterView.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 8*SCALE, kSCREEN_WIDTH-32*SCALE, 140*SCALE)];
    viewBack.layer.cornerRadius = 8*SCALE;
    viewBack.backgroundColor = [UIColor whiteColor];
    [_memberCenterView addSubview:viewBack];
    
    UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 18*SCALE, viewBack.width-32*SCALE, 16*SCALE) title:@"会员中心" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
    lblText.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16*SCALE);
    [viewBack addSubview:lblText];
    
    for (int i=0; i<arr.count; i++) {
        UIView *viewBtn = [[UIView alloc] initWithFrame:CGRectMake(i*viewBack.width/arr.count, lblText.bottom, viewBack.width/arr.count, _memberCenterView.height-lblText.bottom)];
        viewBtn.tag = 900+i;
        [viewBack addSubview:viewBtn];
        
        //点击
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMemberCenterAction:)];
        viewBtn.userInteractionEnabled = YES;
        [viewBtn addGestureRecognizer:tapView];
        
        UIImageView *imageBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:arr[i][@"image"]]];
        imageBtn.centerX = viewBtn.width/2;
        imageBtn.y = 19*SCALE;
        [viewBtn addSubview:imageBtn];
        
        UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageBtn.bottom+10*SCALE, viewBtn.width, 12*SCALE) title:arr[i][@"title"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        lblTitle.tag = 10000;
        [viewBtn addSubview:lblTitle];
        
        UILabel *lblSubTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTitle.bottom+10*SCALE, viewBtn.width, 10*SCALE) title:arr[i][@"subTitle"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(150, 150, 150) titleFont:10*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewBtn addSubview:lblSubTitle];
    }
}

#pragma mark -- 我的服务1000
-(UIView *)myServiceView{
    if (!_myServiceView) {
        _myServiceView = [[UIView alloc] initWithFrame:CGRectMake(0, _memberCenterView.bottom, kSCREEN_WIDTH, 246*SCALE)];
    }
    return _myServiceView;
}

//我的服务菜单
-(void)createMyServiceView:(NSArray *)arr{
    for (UIView *view in _myServiceView.subviews) {
        [view removeFromSuperview];
    }
    _myServiceView.height = 0;
    UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-32*SCALE, _myServiceView.height)];
    viewBack.layer.cornerRadius = 8*SCALE;
    viewBack.backgroundColor = [UIColor whiteColor];
    [_myServiceView addSubview:viewBack];
    
    UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 18*SCALE, viewBack.width-32*SCALE, 16*SCALE) title:@"我的服务" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
    lblText.font = TEXT_SC_TFONT(TEXT_SC_Medium, 16*SCALE);
    [viewBack addSubview:lblText];
    
    for (int i=0; i<arr.count; i++) {
        CGFloat x = viewBack.width/3 *(i%3);
        CGFloat y = lblText.bottom+4*SCALE + 84*SCALE * ceil(i/3);
        CGFloat h = 84*SCALE;
        UIView *viewBtn = [[UIView alloc] initWithFrame:CGRectMake(x, y, viewBack.width/3, h)];
        viewBtn.tag = 1000+i;
        [viewBack addSubview:viewBtn];
        
        //点击
        UITapGestureRecognizer *tapService = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapServiceAction:)];
        viewBtn.userInteractionEnabled = YES;
        [viewBtn addGestureRecognizer:tapService];
        
        UIImageView *imageBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:arr[i][@"image"]]];
        imageBtn.centerX = viewBtn.width/2;
        imageBtn.y = 16*SCALE;
        [viewBtn addSubview:imageBtn];
        
        UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageBtn.bottom+10*SCALE, viewBtn.width, 12*SCALE) title:arr[i][@"title"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(19, 19, 19) titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        lblTitle.tag = 10000;
        [viewBtn addSubview:lblTitle];
        
        UILabel *lblSubTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTitle.bottom+10*SCALE, viewBtn.width, 10*SCALE) title:arr[i][@"subTitle"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(150, 150, 150) titleFont:10*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewBtn addSubview:lblSubTitle];
        
        viewBack.height = viewBtn.bottom+40*SCALE;
    }
    
    _myServiceView.height = viewBack.bottom;
}

#pragma mark -- 点击事件
//设置
-(void)btnSetAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypeSet];
    }
}

//消息
-(void)btnMsgAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypeMsg];
    }
}

//扫一扫
-(void)btnScanAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypeScan];
    }
}

//点击头像/名字
-(void)tapHeadAction:(UIGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypePersonInfo];
    }
}

//提现
-(void)btnWithdrewAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypeWithdrew];
    }
}

//升级团长
-(void)btnUpTuanzhangAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypeUpdateTuanzhang];
    }
}

//会员详情按钮点击
-(void)btnMemberInfoTypeAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"查看概况 >"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMemberGaikuang];
        }
    }
    if ([sender.titleLabel.text isEqualToString:@"提现"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeWithdrew];
        }
    }
    if ([sender.titleLabel.text isEqualToString:@"粉丝"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeFans];
        }
    }
    if ([sender.titleLabel.text isEqualToString:@"淘宝订单"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeTBOrders];
        }
    }
    if ([sender.titleLabel.text isEqualToString:@"其他订单"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeOtherOrders];
        }
    }
}

//查看日历
-(void)btnCalenderAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypeCheckCutCalender];
    }
}

//查看理发订单
-(void)btnOrderAction:(UIButton *)sender{
    if (sender.tag >= 599) {
        if ([sender.titleLabel.text isEqualToString:@"查看更多订单 >"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeCutOrdersMore];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"待消费"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeCutOrdersWiatXiaofei];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"待付款"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeCutOrdersWaitToPay];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"服务中"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeCutOrdersService];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"已完成"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeCutOrdersDone];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"退款/过号"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeCutOrdersRefund];
            }
        }
    }
    else{
        if ([sender.titleLabel.text isEqualToString:@"查看更多订单 >"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeMyCutOrdersMore];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"待接单"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeMyCutOrdersUnaccept];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"已接单"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeMyCutOrdersAccepted];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"已完成"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeMyCutOrdersDone];
            }
        }
        if ([sender.titleLabel.text isEqualToString:@"退款/过号"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
                [self.delegate clickPersonFunciton:FunctionTypeMyCutOrdersRefund];
            }
        }
    }
}

//会员超级权益
-(void)btnQuanyiAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
        [self.delegate clickPersonFunciton:FunctionTypeSuperQuanyi];
    }
}

//我的任务查看更多
-(void)btnMoreTaskAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"任务中心 >"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeTaskCenter];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeTaskMore];
        }
    }
}

//会员中心点击事件
-(void)tapMemberCenterAction:(UIGestureRecognizer *)sender{
    UILabel *lblTitle = (UILabel *)[sender.view viewWithTag:10000];
    if ([lblTitle.text isEqualToString:@"邀请好友"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMemberCenterInvite];
        }
    }
    if ([lblTitle.text isEqualToString:@"招募店员"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMemberCenterInviteWaiter];
        }
    }
    if ([lblTitle.text isEqualToString:@"成为店主"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMemberCenterBeOwner];
        }
    }
    if ([lblTitle.text isEqualToString:@"新手教程"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMemeberCenterNewerTeach];
        }
    }
}

//我的服务点击事件
-(void)tapServiceAction:(UIGestureRecognizer *)sender{
    UILabel *lblTitle = (UILabel *)[sender.view viewWithTag:10000];
    if ([lblTitle.text isEqualToString:@"提现账户"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceAccount];
        }
    }
    if ([lblTitle.text isEqualToString:@"收藏夹"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceCollect];
        }
    }
    if ([lblTitle.text isEqualToString:@"预约理发时段"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceYuyueTime];
        }
    }
    if ([lblTitle.text isEqualToString:@"收益统计"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceProfitTongji];
        }
    }
    if ([lblTitle.text isEqualToString:@"门店信息"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceStoreInfo];
        }
    }
    if ([lblTitle.text isEqualToString:@"我的店员"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceMyStoreWaiter];
        }
    }
    if ([lblTitle.text isEqualToString:@"服务项目"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceCountDetail];
        }
    }
    if ([lblTitle.text isEqualToString:@"平台规则"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceRules];
        }
    }
    if ([lblTitle.text isEqualToString:@"常见问题"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceQuestion];
        }
    }
    if ([lblTitle.text isEqualToString:@"关于巢流"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceAbout];
        }
    }
    if ([lblTitle.text isEqualToString:@"微简历"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceWeijianli];
        }
    }
    if ([lblTitle.text isEqualToString:@"员工信息"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonFunciton:)]) {
            [self.delegate clickPersonFunciton:FunctionTypeMyServiceWaiterInfo];
        }
    }
}

@end
