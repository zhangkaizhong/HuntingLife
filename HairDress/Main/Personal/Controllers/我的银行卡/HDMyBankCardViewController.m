//
//  HDMyBankCardViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/13.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyBankCardViewController.h"

#import "BankTypePickView.h"

@interface HDMyBankCardViewController ()<navViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) HDBaseNavView *navView;

@property (nonatomic,weak) HDTextFeild *textBankName;
@property (nonatomic,weak) HDTextFeild *textBankNo;
@property (nonatomic,weak) HDTextFeild *textBankNoComfirn;
@property (nonatomic,weak) HDTextFeild *textBankUserName;
@property (nonatomic,strong) UIButton *btnDone;

@property (nonatomic,copy) NSString *bankNoStr;

@property (nonatomic,strong) NSMutableArray *arrBanks;

@end

@implementation HDMyBankCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    self.arrBanks = [NSMutableArray new];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
    [self getBankListData];
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//确定
-(void)btnComfirnAction{
    if ([self.textBankName.text isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"请选择银行"];
        return;
    }
    if (![HDToolHelper isInputShouldBeNumber:[HDToolHelper filterString:self.textBankNo.text]]) {
        [SVHUDHelper showDarkWarningMsg:@"银行卡号输入有误"];
        return;
    }
    if (![[HDToolHelper filterString:self.textBankNo.text] isEqualToString:[HDToolHelper filterString:self.textBankNoComfirn.text]]) {
        [SVHUDHelper showDarkWarningMsg:@"两次输入的银行卡号不一致"];
        return;
    }
    if ([self.textBankUserName.text isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"请输入银行卡用户名"];
        return;
    }
    NSDictionary *params = @{
        @"bankName":self.textBankName.text,
        @"bankNo":[HDToolHelper filterString:self.textBankNo.text],
        @"id":[HDUserDefaultMethods getData:@"userId"],
        @"userName":self.textBankUserName.text
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_MemberUpdateBank params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            // 缓存用户信息
            [HDUserDefaultMethods saveData:userInfo[@"userName"] andKey:@"userName"];
            [HDUserDefaultMethods saveData:userInfo[@"bankNo"] andKey:@"bankNo"];
            [HDUserDefaultMethods saveData:userInfo[@"bankName"] andKey:@"bankName"];
            [SVHUDHelper showWorningMsg:@"银行卡信息更新成功" timeInt:2];
            if (self.delegate && [self.delegate respondsToSelector:@selector(changeMyBankMsg:)]) {
                [self.delegate changeMyBankMsg:@{@"userName":userInfo[@"userName"],@"bankNo":userInfo[@"bankNo"],@"bankName":userInfo[@"bankName"]}];
            }
            
            [HDToolHelper delayMethodFourGCD:1.5 method:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//选择银行
-(void)tapChooseBankAction:(UIGestureRecognizer *)sender{
    WeakSelf;
    if (self.arrBanks.count == 0) {
        WeakSelf;
        [MHNetworkManager postReqeustWithURL:URL_WithdrawGetBankType params:@{} successBlock:^(NSDictionary *returnData) {
            if ([returnData[@"respCode"] integerValue] == 200) {
                [self.arrBanks removeAllObjects];
                [self.arrBanks addObjectsFromArray:returnData[@"data"]];
                if (self.arrBanks.count > 0) {
                    BankTypePickView *picker = [[BankTypePickView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) arrData:self.arrBanks];
                    picker.bankblock = ^(NSDictionary * _Nonnull bankType) {
                        weakSelf.textBankName.text = bankType[@"bankType"];
                    };
                    [self.view addSubview:picker];
                }
            }
        } failureBlock:^(NSError *error) {
            
        } showHUD:YES];
    }else{
        BankTypePickView *picker = [[BankTypePickView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) arrData:self.arrBanks];
        picker.bankblock = ^(NSDictionary * _Nonnull bankType) {
            weakSelf.textBankName.text = bankType[@"bankType"];
        };
        [self.view addSubview:picker];
    }
}

//输入监听
-(void)textFeildChangedAction:(UITextField *)sender{
    if (self.textBankUserName.text.length > 10) {
        self.textBankUserName.text = [self.textBankUserName.text substringToIndex:10];
    }
}

//textfield代理实现每隔四位添加空格
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.textBankUserName) {
        return YES;
    }
    
    NSString *text = [textField text];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *newString = @"";
    while (text.length > 0){
        NSString *subString = [text substringToIndex:MIN(text.length, 4)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 4) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 4)];
    }
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    if (newString.length >= 24){
        [textField resignFirstResponder];
        return NO;
    }
    [textField setText:newString];
    return NO;
}

#pragma mark -- 获取银行数据
-(void)getBankListData{
    [MHNetworkManager postReqeustWithURL:URL_WithdrawGetBankType params:@{} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrBanks removeAllObjects];
            [self.arrBanks addObjectsFromArray:returnData[@"data"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark --UI

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的银行卡" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UIView *viewBankName = [self createTextView:CGRectMake(0, 0, kSCREEN_WIDTH, 55) title:@"银行名字" placeText:@"请选择银行"];
        self.textBankName = (HDTextFeild *)[viewBankName viewWithTag:100];
        UIView *viewBankNo = [self createTextView:CGRectMake(0, viewBankName.bottom, kSCREEN_WIDTH, 55) title:@"银行卡号" placeText:@"请输入银行卡号"];
        self.textBankNo = (HDTextFeild *)[viewBankNo viewWithTag:100];
        self.textBankNo.secureTextEntry = YES;
        UIView *viewBankNoComfirn = [self createTextView:CGRectMake(0, viewBankNo.bottom, kSCREEN_WIDTH, 55) title:@"银行卡号" placeText:@"请再次确认银行卡号"];
        self.textBankNoComfirn = (HDTextFeild *)[viewBankNoComfirn viewWithTag:100];
        UIView *viewBankUserName = [self createTextView:CGRectMake(0, viewBankNoComfirn.bottom, kSCREEN_WIDTH, 55) title:@"收款人姓名" placeText:@"请输入银行卡用户名"];
        self.textBankUserName = (HDTextFeild *)[viewBankUserName viewWithTag:100];
        [self.textBankUserName addTarget:self action:@selector(textFeildChangedAction:) forControlEvents:UIControlEventEditingChanged];
        
        self.textBankName.text = [HDUserDefaultMethods getData:@"bankName"];
        self.textBankNo.text = [self formatterBankCardNum:[HDUserDefaultMethods getData:@"bankNo"]];
        self.textBankNoComfirn.text = [self formatterBankCardNum:[HDUserDefaultMethods getData:@"bankNo"]];
        self.textBankUserName.text = [HDUserDefaultMethods getData:@"userName"];
        
        self.bankNoStr = [HDUserDefaultMethods getData:@"bankNo"];
        
        [_mainScrollView addSubview:viewBankName];
        [_mainScrollView addSubview:viewBankNo];
        [_mainScrollView addSubview:viewBankNoComfirn];
        [_mainScrollView addSubview:viewBankUserName];
        [_mainScrollView addSubview:self.btnDone];
        self.btnDone.y = viewBankUserName.bottom+40;
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _btnDone.bottom+16);
    }
    return _mainScrollView;
}

-(UIButton *)btnDone{
    if (!_btnDone) {
        _btnDone = [[UIButton alloc] initCommonWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:14];
        _btnDone.layer.cornerRadius = 24;
        
        [_btnDone addTarget:self action:@selector(btnComfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDone;
}

-(UIView *)createTextView:(CGRect)frame title:(NSString *)title placeText:(NSString *)place{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    view.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, view.height-1, kSCREEN_WIDTH-16, 1)];
    line.backgroundColor = RGBCOLOR(241, 241, 241);
    [view addSubview:line];
    if ([title isEqualToString:@"收款人姓名"]) {
        line.hidden = YES;
    }
    
    UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 20) title:title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lblTitle.centerY = view.height/2;
    [view addSubview:lblTitle];
    
    HDTextFeild *txtField = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblTitle.frame)+20, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblTitle.frame)-20-16, 20)];
    [view addSubview:txtField];
    txtField.delegate = self;
    txtField.tag = 100;
    txtField.placeholder = place;
    txtField.centerY = view.height/2;
    txtField.font = [UIFont systemFontOfSize:14];
    txtField.textColor = RGBTEXT;
    
    if ([title isEqualToString:@"银行卡号"]) {
        txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
        txtField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    if ([title isEqualToString:@"银行名字"]) {
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.x = kSCREEN_WIDTH-16-imageGo.width;
        imageGo.centerY = lblTitle.centerY;
        [view addSubview:imageGo];
        
        txtField.userInteractionEnabled = NO;
        txtField.width = kSCREEN_WIDTH-CGRectGetMaxX(lblTitle.frame)-20-16-imageGo.width;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChooseBankAction:)];
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
    }
    
    return view;
}

-(NSString *)formatterBankCardNum:(NSString *)string{
    NSString *tempStr=string;
    NSInteger size =(tempStr.length / 4);
    NSMutableArray *tmpStrArr = [[NSMutableArray alloc] init];
    for (int n = 0;n < size; n++){
        [tmpStrArr addObject:[tempStr substringWithRange:NSMakeRange(n*4, 4)]];
    }
    [tmpStrArr addObject:[tempStr substringWithRange:NSMakeRange(size*4, (tempStr.length % 4))]];
    tempStr = [tmpStrArr componentsJoinedByString:@" "];
    return tempStr;
}

@end
