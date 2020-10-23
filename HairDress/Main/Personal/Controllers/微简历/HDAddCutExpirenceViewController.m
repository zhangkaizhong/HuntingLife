//
//  HDAddCutExpirenceViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDAddCutExpirenceViewController.h"

#import "DateTimePickerView.h"

@interface HDAddCutExpirenceViewController ()<navViewDelegate,DateTimePickerViewDelegate>

@property (nonatomic,strong) HDBaseNavView * navView;  // 导航栏
@property (nonatomic, strong) DateTimePickerView *datePickerView;
@property (nonatomic,strong) UIScrollView *mainSrollView;

@property (nonatomic,strong) UIButton * btnComfirn;  // 确定
@property (nonatomic,weak) HDTextFeild *txtShopName;// 就职机构

@property (nonatomic,weak) UILabel *lblBegainTime;// 入职时间
@property (nonatomic,weak) UILabel *lblEndTime;// 离职时间

@property (nonatomic,copy) NSString *timeType;

@end

@implementation HDAddCutExpirenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainSrollView];
    [self.view addSubview:self.btnComfirn];
    
    if (self.expId) {
        [self getCutExpInfo];
    }
}

#pragma mark -- 添加经验请求接口
-(void)addCutExpRequest{
    NSString *expId = @"";
    if (self.expId) {
        expId = self.expId;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[NSString stringWithFormat:@"%@ 00:00:00",self.lblEndTime.text] forKey:@"endTime"];
    [params setValue:[NSString stringWithFormat:@"%@ 00:00:00",self.lblBegainTime.text] forKey:@"startTime"];
    [params setValue:self.txtShopName.text forKey:@"storeName"];
    [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"tonyId"];
    if (![expId isEqualToString:@""]) {
        [params setValue:expId forKey:@"expId"];
    }
    [MHNetworkManager postReqeustWithURL:URL_TonyAddExpManage params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showInfoWithTimestamp:1 msg:@"添加成功"];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(addCutExpActionDelegate)]) {
                    [self.delegate addCutExpActionDelegate];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//获取剪发经验详情
-(void)getCutExpInfo{
    NSString *expId = @"";
    if (self.expId) {
        expId = self.expId;
    }
    [MHNetworkManager postReqeustWithURL:URL_TonyExpManageDetail params:@{@"id":expId} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.lblBegainTime.text = returnData[@"data"][@"startTime"];
            self.lblEndTime.text = returnData[@"data"][@"endTime"];
            self.txtShopName.text = returnData[@"data"][@"storeName"];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//删除剪发经验
-(void)deleteCutExp{
    [MHNetworkManager postReqeustWithURL:URL_TonyDelResume params:@{@"expId":self.expId} successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showWorningMsg:@"删除成功" timeInt:1];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(addCutExpActionDelegate)]) {
                    [self.delegate addCutExpActionDelegate];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- delegate / action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//删除剪发经验
-(void)navRightClicked{
    [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定删除该作品集吗?" viewController:self leftHandle:^(id anyID) {
        //取消
    }rightHandle:^(id any) {
        //确定
        [self deleteCutExp];
    }];
    
}

// 开始时间
-(void)tapBegainAction:(UIGestureRecognizer *)sender{
    [self.txtShopName resignFirstResponder];
    self.timeType = @"1";
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    self.datePickerView = pickerView;
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewDateMode;
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

// 离职时间选择
-(void)tapEndAction:(UIGestureRecognizer*)sender{
    [self.txtShopName resignFirstResponder];
    self.timeType = @"2";
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    self.datePickerView = pickerView;
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewDateMode;
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

// 选择时间回调
- (void)didClickFinishDateTimePickerView:(NSString *)date{
    if ([self.timeType isEqualToString:@"1"]) {
        self.lblBegainTime.text = date;
    }else{
        self.lblEndTime.text = date;
    }
}

// 确定添加
-(void)comfirnAction{
    if ([self.lblBegainTime.text isEqualToString:@"请选择"]) {
        [SVHUDHelper showWorningMsg:@"请选择入职时间" timeInt:1];
        return;
    }
    if ([self.lblEndTime.text isEqualToString:@"请选择"]) {
        [SVHUDHelper showWorningMsg:@"请选择离职时间" timeInt:1];
        return;
    }
    if ([self.txtShopName.text isEqualToString:@""]) {
        [SVHUDHelper showWorningMsg:@"请输入就职机构名称" timeInt:1];
        return;
    }
    [self addCutExpRequest];
}


#pragma mark -- 加载控件

-(HDBaseNavView *)navView{
    if (!_navView) {
        if (self.expId) {
            _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"剪发经验" bgColor:RGBMAIN backBtn:YES rightBtn:@"删除" rightBtnImage:@"" theDelegate:self];
        }else{
            _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"剪发经验" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
        }
        
    }
    return _navView;
}

-(UIScrollView *)mainSrollView{
    if (!_mainSrollView) {
        _mainSrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainSrollView.backgroundColor = [UIColor clearColor];
        
        // 入职时间
        UIView *viewBegain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 57)];
        viewBegain.backgroundColor = [UIColor whiteColor];
        [_mainSrollView addSubview:viewBegain];
        
        // 点击
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBegainAction:)];
        viewBegain.userInteractionEnabled = YES;
        [viewBegain addGestureRecognizer:tap1];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, kSCREEN_WIDTH/2-16, 14) title:@"入职时间" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewBegain addSubview:lblText];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 56, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewBegain addSubview:line];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.x = kSCREEN_WIDTH-16-24;
        imageGo.centerY = lblText.centerY;
        [viewBegain addSubview:imageGo];
        
        UILabel *lblBegain = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2-24-16, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblBegain.centerY = lblText.centerY;
        self.lblBegainTime = lblBegain;
        
        [viewBegain addSubview:self.lblBegainTime];
        
        // 离职时间
        UIView *viewEnd = [[UIView alloc] initWithFrame:CGRectMake(0, viewBegain.bottom, kSCREEN_WIDTH, 57)];
        viewEnd.backgroundColor = [UIColor whiteColor];
        [_mainSrollView addSubview:viewEnd];
        
        // 点击
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEndAction:)];
        viewEnd.userInteractionEnabled = YES;
        [viewEnd addGestureRecognizer:tap2];

        UILabel *lblEndText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, kSCREEN_WIDTH/2-16, 14) title:@"离职时间" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewEnd addSubview:lblEndText];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(16, 56, kSCREEN_WIDTH-32, 1)];
        line1.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewEnd addSubview:line1];
        
        UIImageView *imageGo1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo1.x = kSCREEN_WIDTH-16-24;
        imageGo1.centerY = lblEndText.centerY;
        [viewEnd addSubview:imageGo1];
        
        UILabel *lblEnd = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2-24-16, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblEnd.centerY = lblEndText.centerY;
        self.lblEndTime = lblEnd;
        [viewEnd addSubview:self.lblEndTime];
        
        //就职机构
        UIView *viewShop = [[UIView alloc] initWithFrame:CGRectMake(0, viewEnd.bottom, kSCREEN_WIDTH, 89)];
        viewShop.backgroundColor = [UIColor whiteColor];
        [_mainSrollView addSubview:viewShop];
        
        UILabel *lblShopText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH/2-16, 14) title:@"就职机构" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewShop addSubview:lblShopText];
        
        HDTextFeild *textShopName = [[HDTextFeild alloc] initWithFrame:CGRectMake(16, lblShopText.bottom+12, kSCREEN_WIDTH-32, 22)];
        self.txtShopName = textShopName;
        self.txtShopName.placeholder = @"请输入就职机构名称";
        self.txtShopName.textColor = RGBTEXT;
        self.txtShopName.font = [UIFont systemFontOfSize:14];
        [viewShop addSubview:self.txtShopName];
        
        _mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, viewShop.bottom);
    }
    return _mainSrollView;
}

// 确定
-(UIButton *)btnComfirn{
    if (!_btnComfirn) {
        _btnComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnComfirn.layer.cornerRadius = 24;
        _btnComfirn.backgroundColor = RGBMAIN;
        
        [_btnComfirn addTarget:self action:@selector(comfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnComfirn;
}

@end
