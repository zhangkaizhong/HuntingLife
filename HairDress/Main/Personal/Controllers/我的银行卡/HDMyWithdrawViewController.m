//
//  HDMyWithdrawViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyWithdrawViewController.h"

#import "HDMyBankCardViewController.h"
#import "HDSetPasswordViewController.h"
#import "HDMyWithdrawRecordsViewController.h"

@interface HDMyWithdrawViewController ()<navViewDelegate,HDMyBankCardDelegate,UITextFieldDelegate>
{
    BOOL isHaveDian;
}
@property (nonatomic,strong) UIView *viewCard;//银行卡视图
@property (nonatomic,strong) UIView *viewWithdraw;//提现视图

@property (nonatomic,weak) UIImageView *imageBank;
@property (nonatomic,weak) UILabel *lblBank;
@property (nonatomic,weak) UILabel *lblBankNo;
@property (nonatomic,weak) UILabel *lblBankChange;
@property (nonatomic,weak) HDTextFeild *textMoney;
@property (nonatomic,weak) UILabel *lblWithMinPercent;//提现手续费
@property (nonatomic,weak) UILabel *lblCanWithMoney;

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;//主视图
@property (nonatomic,strong) UIButton *buttonComfirn;

@property (nonatomic,strong) NSDictionary *bankDic;//银行卡信息
@property (nonatomic,copy) NSString *bankNo;
@property (nonatomic,copy) NSString *payPassword;//提现密码
@property (nonatomic,copy) NSString *balanceMoney;//余额
@property (nonatomic,copy) NSString *minAmount;//最低提现金额
@property (nonatomic,copy) NSString *amount;//手续费
@property (nonatomic,copy) NSString *tixianNum;//单日提现次数

@end

@implementation HDMyWithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.minAmount = @"0.1";
    self.amount = @"0";
    self.tixianNum = @"200";
    self.bankNo = [HDUserDefaultMethods getData:@"bankNo"];
    self.balanceMoney = [HDUserDefaultMethods getData:@"balance"];
    
    self.bankDic = @{@"userName":[HDUserDefaultMethods getData:@"userName"],@"bankNo":[HDUserDefaultMethods getData:@"bankNo"],@"bankName":[HDUserDefaultMethods getData:@"bankName"]};
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
    [self getPersonalProfitData];
    [self getConfigBankData];
}

#pragma mark -- delegate / action

- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//提现记录
-(void)navRightClicked{
    HDMyWithdrawRecordsViewController *recordVC = [HDMyWithdrawRecordsViewController new];
    [self.navigationController pushViewController:recordVC animated:YES];
}

//确认提现
-(void)btnDoneAction{
    
    if ([self.balanceMoney floatValue] < 0) {
        [SVHUDHelper showDarkWarningMsg:@"您可提现余额不足，无法提现"];
        return;
    }
    
    if ([self.bankNo isEqualToString:@""]) {
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"暂无银行卡信息，请先绑定银行卡" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            HDMyBankCardViewController *bankVC = [HDMyBankCardViewController new];
            bankVC.delegate = self;
            [self.navigationController pushViewController:bankVC animated:YES];
        }];
        return;
    }
    
    if ([[HDUserDefaultMethods getData:@"payPassword"] isEqualToString:@""]) {
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您未设置支付密码，请先设置密码" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            HDSetPasswordViewController *setVC = [HDSetPasswordViewController new];
            [self.navigationController pushViewController:setVC animated:YES];
        }];
        return;
    }
    
    if ([self.textMoney.text isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"请输入提现金额"];
        return;
    }
    if ([self.textMoney.text floatValue] < [self.minAmount floatValue]) {
        [SVHUDHelper showDarkWarningMsg:[NSString stringWithFormat:@"最低提现金额为%.2f元",[self.minAmount floatValue]]];
        return;
    }
    if ([self.tixianNum integerValue] < 1) {
        [SVHUDHelper showDarkWarningMsg:@"您已超过当日最大提现次数，无法提现"];
        return;
    }
    
    [[WMZAlert shareInstance] showAlertWithType:AlertTypePay headTitle:@"请输入支付密码" textTitle:@{@"balance":self.textMoney.text,@"minMoney":[NSString stringWithFormat:@"%.2f",[self.amount floatValue]]} viewController:self leftHandle:^(id anyID) {
        //取消
    }rightHandle:^(id any) {
        //确定
        self.payPassword = any;
        [self requestToWithdrew];
    }];
}

//全部提现
-(void)btnAllWithdrewAction{
    self.textMoney.text = [NSString stringWithFormat:@"%.2f",[self.balanceMoney floatValue]];
}

//更改银行卡
-(void)changeCardAction:(UIGestureRecognizer *)sender{
    HDMyBankCardViewController *bankVC = [HDMyBankCardViewController new];
    bankVC.delegate = self;
    [self.navigationController pushViewController:bankVC animated:YES];
}

//更改银行卡信息代理
-(void)changeMyBankMsg:(NSDictionary *)dicBank{
    self.bankDic = dicBank;
    
    self.bankNo = dicBank[@"bankNo"];
    
    NSString *bankNoStr = self.bankNo;
    bankNoStr = [bankNoStr substringFromIndex:bankNoStr.length-4];
    NSString *strBankMsg = [NSString stringWithFormat:@"%@(%@)%@",dicBank[@"bankName"],bankNoStr,dicBank[@"userName"]];
    self.lblBankNo.text = strBankMsg;
    [self.lblBankNo sizeToFit];
    self.lblBankNo.height = 14;
    
    self.lblBankChange.text = @"更改银行卡";
}

//输入金额监听
-(void)moneyTextFieldDidChange:(UITextField *)txt{
    if ([txt.text floatValue] > [self.balanceMoney floatValue]) {
        txt.text = [NSString stringWithFormat:@"%.2f",[self.balanceMoney floatValue]];
    }
    NSString *string = txt.text;
    if ([string rangeOfString:@"."].location != NSNotFound) {
        NSArray *array = [string componentsSeparatedByString:@"."]; //从字符A中分隔成2个元素的数组
        NSString *str1 = array[1];
        if ([str1 length] > 2) {
            [SVHUDHelper showWorningMsg:@"亲，您最多输入两位小数" timeInt:1];
            txt.text = [NSString stringWithFormat:@"%@.%@",array[0],[str1 substringToIndex:2]];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text rangeOfString:@"."].location == NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length] > 0) {

        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.') {//数据格式正确

            //首字母不能为0和小数点
            if([textField.text length] == 0){
                if(single == '.') {
                    [SVHUDHelper showWorningMsg:@"亲，第一个数字不能为小数点" timeInt:1];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }

            //输入的字符是否是小数点
            if (single == '.') {
                if(!isHaveDian)//text中还没有小数点
                {
                    isHaveDian = YES;
                    return YES;

                }else{
                    [SVHUDHelper showWorningMsg:@"亲，您已经输入过小数点了" timeInt:1];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }else{
                if (isHaveDian) {//存在小数点
                    //判断小数点的位数
                    NSRange ran = [textField.text rangeOfString:@"."];
                    if (range.location - ran.location <= 2) {
                        return YES;
                    }else{
                        [SVHUDHelper showWorningMsg:@"亲，您最多输入两位小数" timeInt:1];
                        return NO;
                    }
                }else{
                    return YES;
                }
            }
        }else{//输入的数据格式不正确
            [SVHUDHelper showWorningMsg:@"亲，您输入的格式不正确" timeInt:1];
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    else
    {
        return YES;
    }
}

#pragma mark -- 数据请求
//获取可提现余额
-(void)getPersonalProfitData{
    NSDictionary *params = @{
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_UserQueryMoneyInfo params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.balanceMoney = [NSString stringWithFormat:@"%.2f",[returnData[@"data"][@"canGetFee"] floatValue]];
            NSString *blanceStr = [NSString stringWithFormat:@"可提现余额%.2f元",[self.balanceMoney floatValue]];
            self.lblCanWithMoney.text = blanceStr;
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//获取银行卡提现配置数据
-(void)getConfigBankData{
    [MHNetworkManager postReqeustWithURL:URL_MemberWithdrawConfigDetail params:@{} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if([returnData[@"respCode"] integerValue] == 200){
            NSDictionary *dic = [HDToolHelper nullDicToDic:returnData[@"data"]];
            self.minAmount = dic[@"minAmount"];
            self.amount = dic[@"amount"];
            self.tixianNum = dic[@"num"];
            self.lblWithMinPercent.text = [NSString stringWithFormat:@"提现金额（提现手续费¥%.2f）",[self.amount floatValue]];
            self.textMoney.placeholder = [NSString stringWithFormat:@"最低提现金额%.2f元",[self.minAmount floatValue]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//提现请求
-(void)requestToWithdrew{
    if (!self.payPassword) {
        [SVHUDHelper showDarkWarningMsg:@"请输入密码"];
        return;
    }
    
    NSDictionary *params = @{
        @"balance":self.textMoney.text,
        @"bankName":self.bankDic[@"bankName"],
        @"bankNo":self.bankDic[@"bankNo"],
        @"password":self.payPassword,
        @"userId":[HDUserDefaultMethods getData:@"userId"],
        @"userName":self.bankDic[@"userName"],
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_Withdraw params:params successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSString *restBalance = [NSString stringWithFormat:@"%.2f",[self.balanceMoney floatValue]-[self.textMoney.text floatValue]];
            [HDUserDefaultMethods saveData:restBalance andKey:@"balance"];
            [HDToolHelper delayMethodFourGCD:1.5 method:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    } failureBlock:^(NSError *error) {
            
    } showHUD:YES];
}

#pragma mark ================== 加载视图 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        [_mainScrollView addSubview:self.viewCard];
        [_mainScrollView addSubview:self.viewWithdraw];
        [_mainScrollView addSubview:self.buttonComfirn];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _buttonComfirn.bottom+16);
    }
    return _mainScrollView;
}

// 银行卡视图
-(UIView *)viewCard{
    if (!_viewCard) {
        _viewCard = [[UIView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, 74)];
        _viewCard.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tapChangeCard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCardAction:)];
        _viewCard.userInteractionEnabled = YES;
        [_viewCard addGestureRecognizer:tapChangeCard];
        
        UILabel *lblBank = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, 150, 14) title:@"银行卡信息" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewCard addSubview:lblBank];
        self.lblBank = lblBank;
        
        NSString *strBankMsg = @"";
        NSString *bankChangeStr = @"更改银行卡";
        NSString *bankNoStr = self.bankNo;
        if ([bankNoStr isEqualToString:@""]) {
            strBankMsg = @"暂无银行卡信息";
            bankChangeStr = @"绑定银行卡";
        }else{
            if (bankNoStr.length >= 4) {
                bankNoStr = [bankNoStr substringFromIndex:bankNoStr.length-4];
            }
            strBankMsg = [NSString stringWithFormat:@"%@(%@)%@",[HDUserDefaultMethods getData:@"bankName"],bankNoStr,[HDUserDefaultMethods getData:@"userName"]];
        }
        
        UILabel *lblBankNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblBank.bottom+16, kSCREEN_WIDTH/2, 14) title:strBankMsg bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewCard addSubview:lblBankNo];
        lblBankNo.height = 14;
        self.lblBankNo = lblBankNo;
        
        UILabel *lblBankChange = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH-24-16-80, 0, 80, 12) title:bankChangeStr bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        lblBankChange.centerY = lblBank.centerY;
        [_viewCard addSubview:lblBankChange];
        self.lblBankChange = lblBankChange;
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.centerY = lblBankChange.centerY;
        imageGo.x = CGRectGetMaxX(lblBankChange.frame);
        [_viewCard addSubview:imageGo];
    }
    return _viewCard;
}

//提现视图
-(UIView *)viewWithdraw{
    if (!_viewWithdraw) {
        _viewWithdraw = [[UIView alloc] initWithFrame:CGRectMake(0, _viewCard.bottom+8, kSCREEN_WIDTH, 129)];
        _viewWithdraw.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblWithText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 14) title:[NSString stringWithFormat:@"提现金额（提现手续费¥%.2f）",[self.amount floatValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewWithdraw addSubview:lblWithText];
        self.lblWithMinPercent = lblWithText;
        
        UILabel *lblMoneyIcon = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblWithText.bottom+16, 21, 23) title:@"¥" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_viewWithdraw addSubview:lblMoneyIcon];
        
        HDTextFeild *textMoney = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblMoneyIcon.frame)+8, lblMoneyIcon.y+7, kSCREEN_WIDTH-CGRectGetMaxX(lblMoneyIcon.frame)-8-16-60, 14)];
        textMoney.placeholder = @"最低提现金额0.10元";
        textMoney.keyboardType = UIKeyboardTypeDecimalPad;
        textMoney.font = [UIFont systemFontOfSize:14];
        textMoney.delegate = self;
        [_viewWithdraw addSubview:textMoney];
        self.textMoney = textMoney;
        [self.textMoney addTarget:self action:@selector(moneyTextFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        
        UIButton *buttonAll = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16-60, textMoney.y, 60, 14) btnTitle:@"全部提现" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        [_viewWithdraw addSubview:buttonAll];
        [buttonAll addTarget:self action:@selector(btnAllWithdrewAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, lblMoneyIcon.bottom+17, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewWithdraw addSubview:line];
        
        NSString *blanceStr = [NSString stringWithFormat:@"可提现余额%.2f元",[self.balanceMoney floatValue]];
        UILabel *lblCanWithMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, line.bottom+12, kSCREEN_WIDTH-32, 14) title:blanceStr bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewWithdraw addSubview:lblCanWithMoney];
        self.lblCanWithMoney = lblCanWithMoney;
    }
    return _viewWithdraw;
}

// 确认提现
-(UIButton *)buttonComfirn{
    if (!_buttonComfirn) {
        _buttonComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, _viewWithdraw.bottom+64, kSCREEN_WIDTH-32, 48) btnTitle:@"提现" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _buttonComfirn.backgroundColor = RGBMAIN;
        _buttonComfirn.layer.cornerRadius = 24;
        [_buttonComfirn addTarget:self action:@selector(btnDoneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonComfirn;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"提现" bgColor:RGBMAIN backBtn:YES rightBtn:@"提现记录" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
