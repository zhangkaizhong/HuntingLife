//
//  HDAddShopConfigViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDAddShopConfigViewController.h"

#import "HDChooseServicesViewController.h"
#import "MHActionSheet.h"
#import "HDShopEditChooseModel.h"

@interface HDAddShopConfigViewController ()<navViewDelegate,HDChooseServicesConfigDelegate,UITextFieldDelegate>
{
    BOOL isHaveDian;
}
@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,strong) UIView *viewAmount;//金额
@property (nonatomic,weak) HDTextFeild *txtAmount;

@property (nonatomic,strong) UIView *viewDefault;//是否默认
@property (nonatomic,weak) UILabel *lblDefault;

@property (nonatomic,strong) UIView *viewLinkName;//服务名称
@property (nonatomic,weak) UILabel *lblLinkName;

@property (nonatomic,strong) UIView *viewConfigDesc;//配置描述
@property (nonatomic,weak) UITextView *textConfigDesc;
@property (nonatomic,weak) UILabel *lblPlaceholder;

@property (nonatomic,strong) UIButton *btnDone;// 确认
@property (nonatomic,copy) NSString *linkId;//
@property (nonatomic,copy) NSString *linkName;//

@property (nonatomic,strong) NSMutableArray *servicesTypeArr;
@property (nonatomic,strong) HDShopEditChooseModel *modelService;

@end

@implementation HDAddShopConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    self.servicesTypeArr = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:nil];
    
    if (self.storeConfigModel) {
        self.linkId = self.storeConfigModel.linkId;
        self.linkName = self.storeConfigModel.linkName;
    }
}
#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//选择服务名称回调
-(void)chooseConfigList:(NSString *)type configs:(NSArray *)arrConfigs{
    [self.servicesTypeArr removeAllObjects];
    [self.servicesTypeArr addObjectsFromArray:arrConfigs];
    if (self.servicesTypeArr.count > 0) {
        self.modelService = self.servicesTypeArr[0];
        self.lblLinkName.text = self.modelService.configName;
        self.linkId = self.modelService.configValue;
        self.linkName = self.modelService.configName;
    }
}

//输入金额监听
-(void)moneyTextFieldDidChange:(UITextField *)txt{
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


// 描述输入监听
- (void)textDidChange{
    // 有文字就隐藏
    if (self.textConfigDesc.text.length == 0) {
        self.lblPlaceholder.hidden = NO;
    }else{
        self.lblPlaceholder.hidden = YES;
    }
}

//是否默认
-(void)tapDefaultAction:(UIGestureRecognizer *)sender{
    [self.txtAmount resignFirstResponder];
    WeakSelf;
    MHActionSheet *actionSheet = [[MHActionSheet alloc] initSheetWithTitle:nil style:MHSheetStyleWeiChat itemTitles:@[@"是",@"否"]];
        [actionSheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
            NSLog(@"%@",title);
            weakSelf.lblDefault.text = title;
    }];
}

//服务名称
-(void)tapLinkNameAction:(UIGestureRecognizer *)sender{
    [self.txtAmount resignFirstResponder];
    HDChooseServicesViewController *serviceVC = [HDChooseServicesViewController new];
    serviceVC.chooseType = @"service_item";
    serviceVC.delegate = self;
    serviceVC.arrSelects = self.servicesTypeArr;
    serviceVC.singleChoose = YES;
    [self.navigationController pushViewController:serviceVC animated:YES];
}

//完成
-(void)doneAction{
    [self.txtAmount resignFirstResponder];
    [self addConfigData];
}

//删除
-(void)navRightClicked{
    [self.txtAmount resignFirstResponder];
    
    [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定删除此配置吗?" viewController:self leftHandle:^(id anyID) {
        //取消
    }rightHandle:^(id any) {
        //确定
        [self deleteConfigData];
    }];
}

#pragma mark -- 数据请求
//添加
-(void)addConfigData{
    if ([HDToolHelper StringIsNullOrEmpty:self.txtAmount.text]) {
        [SVHUDHelper showDarkWarningMsg:@"请输入金额"];
        return;
    }
    if ([self.lblDefault.text isEqualToString:@"请选择"]) {
        [SVHUDHelper showDarkWarningMsg:@"请选择是否默认"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.linkName] || [HDToolHelper StringIsNullOrEmpty:self.linkId]) {
        [SVHUDHelper showDarkWarningMsg:@"请选择服务名称"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.textConfigDesc.text]) {
        self.textConfigDesc.text = @"";
    }
    NSString *isDefault = @"T";
    if ([self.lblDefault.text isEqualToString:@"否"]) {
        isDefault = @"F";
    }
    NSString *configId = @"";
    if (self.storeConfigModel) {
        configId = self.storeConfigModel.storeConfigId;
    }
    NSDictionary *params = @{
        @"amount":self.txtAmount.text,
        @"configDesc":self.textConfigDesc.text,
        @"defaultFlag":isDefault,
        @"linkId":self.linkId,
        @"linkName":self.linkName,
        @"linkType":@"service_item",
        @"storeConfigId":configId,//编辑必传
        @"storeId":[HDUserDefaultMethods getData:@"storeId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_StoreEditStoreConfig params:params successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshShopConfigList)]) {
                    [self.delegate refreshShopConfigList];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [SVHUDHelper showDarkWarningMsg:@"添加成功"];
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//删除
-(void)deleteConfigData{
    if (!self.storeConfigModel) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_StoreDelStoreConfig params:@{@"storeConfigId":self.storeConfigModel.storeConfigId} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshShopConfigList)]) {
                    [self.delegate refreshShopConfigList];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [SVHUDHelper showDarkWarningMsg:@"删除成功"];
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- ui
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = RGBBG;
        
        [_mainScrollView addSubview:self.viewAmount];
        [_mainScrollView addSubview:self.viewDefault];
        [_mainScrollView addSubview:self.viewLinkName];
        [_mainScrollView addSubview:self.viewConfigDesc];
        [_mainScrollView addSubview:self.btnDone];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.btnDone.bottom);
    }
    return _mainScrollView;
}

// 金额
-(UIView *)viewAmount{
    if (!_viewAmount) {
        _viewAmount = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 55)];
        _viewAmount.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"金额" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewAmount addSubview:lblText];
        
        // 金额
        HDTextFeild *txtAmount = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10, 14)];
        txtAmount.textAlignment = NSTextAlignmentRight;
        txtAmount.placeholder = @"请输入金额";
        txtAmount.textColor = RGBTEXTINFO;
        txtAmount.font = [UIFont systemFontOfSize:14];
        txtAmount.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        txtAmount.delegate = self;
        [txtAmount addTarget:self action:@selector(moneyTextFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        self.txtAmount = txtAmount;
        txtAmount.centerY = lblText.centerY;
        [_viewAmount addSubview:self.txtAmount];
        
        if (self.storeConfigModel) {
            self.txtAmount.text = [NSString stringWithFormat:@"%.2f",[self.storeConfigModel.amount floatValue]];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewAmount addSubview:line];
    }
    return _viewAmount;
}

// 是否默认
-(UIView *)viewDefault{
    if (!_viewDefault) {
        _viewDefault = [[UIView alloc] initWithFrame:CGRectMake(0, _viewAmount.bottom, kSCREEN_WIDTH, 55)];
        _viewDefault.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"是否默认" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewDefault addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewDefault addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        UILabel *lblDefault = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10-24, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblDefault = lblDefault;
        lblDefault.centerY = lblText.centerY;
        [_viewDefault addSubview:self.lblDefault];
        
        if (self.storeConfigModel) {
            if ([self.storeConfigModel.defaultFlag isEqualToString:@"T"]) {
                self.lblDefault.text = @"是";
            }else{
                self.lblDefault.text = @"否";
            }
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDefaultAction:)];
        _viewDefault.userInteractionEnabled = YES;
        [_viewDefault addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewDefault addSubview:line];

    }
    return _viewDefault;
}

// 服务名称
-(UIView *)viewLinkName{
    if (!_viewLinkName) {
        _viewLinkName = [[UIView alloc] initWithFrame:CGRectMake(0, _viewDefault.bottom, kSCREEN_WIDTH, 55)];
        _viewLinkName.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"服务名称" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewLinkName addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewLinkName addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        UILabel *lblLinkName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10-24, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblLinkName = lblLinkName;
        lblLinkName.centerY = lblText.centerY;
        [_viewLinkName addSubview:self.lblLinkName];
        
        if (self.storeConfigModel) {
            self.lblLinkName.text = self.storeConfigModel.linkName;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLinkNameAction:)];
        _viewLinkName.userInteractionEnabled = YES;
        [_viewLinkName addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewLinkName addSubview:line];
    }
    return _viewLinkName;
}

//评论内容
-(UIView *)viewConfigDesc{
    if (!_viewConfigDesc) {
        _viewConfigDesc = [[UIView alloc] initWithFrame:CGRectMake(0, _viewLinkName.bottom, kSCREEN_WIDTH, 48+54)];
        _viewConfigDesc.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblTalentText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"配置描述" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewConfigDesc addSubview:lblTalentText];

        UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(10, lblTalentText.bottom+6, _viewConfigDesc.width-32, 64)];
        txt.font = [UIFont systemFontOfSize:14];
        [_viewConfigDesc addSubview:txt];
        self.textConfigDesc = txt;
        
        UILabel *placelbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblTalentText.bottom+16, _viewConfigDesc.width-32, 14) title:@"请输入配置描述内容" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblPlaceholder = placelbl;
        [_viewConfigDesc addSubview:self.lblPlaceholder];
        
        if (self.storeConfigModel) {
            if (![HDToolHelper StringIsNullOrEmpty:self.storeConfigModel.configDesc]) {
                self.textConfigDesc.text = self.storeConfigModel.configDesc;
                self.lblPlaceholder.hidden = YES;
            }
        }
        
        _viewConfigDesc.height = _textConfigDesc.bottom;
        
    }
    return _viewConfigDesc;
}

-(UIButton *)btnDone{
    if (!_btnDone) {
        _btnDone = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, _viewConfigDesc.bottom+40, kSCREEN_WIDTH-32, 48) btnTitle:@"完成" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnDone.layer.cornerRadius = 24;
        _btnDone.backgroundColor = RGBMAIN;
        
        [_btnDone addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDone;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        NSString *rightBtn = @"";
        if (self.storeConfigModel) {
            rightBtn = @"删除";
        }
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"新增门店配置" bgColor:RGBMAIN backBtn:YES rightBtn:rightBtn rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
