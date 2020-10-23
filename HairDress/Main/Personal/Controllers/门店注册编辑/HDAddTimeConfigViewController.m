//
//  HDAddShopConfigViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDAddTimeConfigViewController.h"
#import "DateTimePickerView.h"

@interface HDAddTimeConfigViewController ()<navViewDelegate,DateTimePickerViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) DateTimePickerView *datePickerView;
@property (nonatomic,copy) NSString *timeType;

@property (nonatomic,strong) UIView *viewNum;//可预约人数
@property (nonatomic,weak) HDTextFeild *txtNum;

@property (nonatomic,strong) UIView *viewStartTime;//开始时间
@property (nonatomic,weak) UILabel *lblStartTime;

@property (nonatomic,strong) UIView *viewEndTime;//结束时间
@property (nonatomic,weak) UILabel *lblEndTime;

@property (nonatomic,strong) UIButton *btnDone;// 确认
@property (nonatomic,copy) NSString *storeTimeId;//
@property (nonatomic,copy) NSString *startTimeStr;//
@property (nonatomic,copy) NSString *endTimeStr;//

@end

@implementation HDAddTimeConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
    if (self.timeModel) {
        
    }
}
#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//输入人数监听
-(void)moneyTextFieldDidChange:(UITextField *)txt{
    if (self.txtNum.text.length > 4) {
        self.txtNum.text = [self.txtNum.text substringToIndex:4];
    }
}

//textfield代理实现每隔四位添加空格
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    return YES;
}

// 选择开始时间
-(void)tapStartTimeAction:(UIGestureRecognizer *)sender{
    [self.txtNum resignFirstResponder];
    self.timeType = @"1";
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    self.datePickerView = pickerView;
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewHourMode;
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

// 选择结束时间
-(void)tapEndTimeAction:(UIGestureRecognizer *)sender{
    [self.txtNum resignFirstResponder];
    self.timeType = @"2";
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    self.datePickerView = pickerView;
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewHourMode;
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

// 选择时间回调
- (void)didClickFinishDateTimePickerView:(NSString *)date{
    if ([self.timeType isEqualToString:@"1"]) {
        self.startTimeStr = date;
        self.lblStartTime.text = [NSString stringWithFormat:@"%@",date];
    }else{
        self.endTimeStr = date;
        self.lblEndTime.text = [NSString stringWithFormat:@"%@",date];
    }
}

//完成
-(void)doneAction{
    [self.txtNum resignFirstResponder];
    [self addConfigData];
}

//删除
-(void)navRightClicked{
    [self.txtNum resignFirstResponder];
    
    [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您确定删除此预约时间段吗?" viewController:self leftHandle:^(id anyID) {
        //取消
    }rightHandle:^(id any) {
        //确定
        [self deleteConfigData];
    }];
}

#pragma mark -- 数据请求
//添加
-(void)addConfigData{
    if ([HDToolHelper StringIsNullOrEmpty:self.txtNum.text]) {
        [SVHUDHelper showDarkWarningMsg:@"请输入可预约人数"];
        return;
    }
    if (![HDToolHelper isInputShouldBeNumber:self.txtNum.text]) {
        [SVHUDHelper showDarkWarningMsg:@"可预约人数应为数字"];
        return;
    }
    if ([self.txtNum.text integerValue] > 999) {
        [SVHUDHelper showDarkWarningMsg:@"可预约人数最大为999人"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.startTimeStr]) {
        [SVHUDHelper showDarkWarningMsg:@"请选择开始时间"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.endTimeStr]) {
        [SVHUDHelper showDarkWarningMsg:@"请选择结束时间"];
        return;
    }
    NSString *storeTimeId = @"";
    if (self.timeModel) {
        storeTimeId = self.timeModel.storeTimeId;
    }
    NSDictionary *params = @{
        @"endTime":self.endTimeStr,
        @"startTime":self.startTimeStr,
        @"totalNum":self.txtNum.text,
        @"storeTimeId":storeTimeId,//编辑必传
        @"storeId":[HDUserDefaultMethods getData:@"storeId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_StoreTimeEdit params:params successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTimeConfigList)]) {
                    [self.delegate refreshTimeConfigList];
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
    if (!self.timeModel) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_StoreTimeDel params:@{@"storeTimeId":self.timeModel.storeTimeId} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTimeConfigList)]) {
                    [self.delegate refreshTimeConfigList];
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
        
        [_mainScrollView addSubview:self.viewNum];
        [_mainScrollView addSubview:self.viewStartTime];
        [_mainScrollView addSubview:self.viewEndTime];
        [_mainScrollView addSubview:self.btnDone];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.btnDone.bottom);
    }
    return _mainScrollView;
}

// 金额
-(UIView *)viewNum{
    if (!_viewNum) {
        _viewNum = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 55)];
        _viewNum.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"可预约人数" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewNum addSubview:lblText];
        
        // 人数
        HDTextFeild *txtNum = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10, 14)];
        txtNum.textAlignment = NSTextAlignmentRight;
        txtNum.placeholder = @"请输入可预约人数";
        txtNum.textColor = RGBTEXTINFO;
        txtNum.font = [UIFont systemFontOfSize:14];
        txtNum.keyboardType = UIKeyboardTypeNumberPad;
        txtNum.delegate = self;
        [txtNum addTarget:self action:@selector(moneyTextFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        self.txtNum = txtNum;
        txtNum.centerY = lblText.centerY;
        [_viewNum addSubview:self.txtNum];
        
        if (self.timeModel) {
            self.txtNum.text = self.timeModel.totalNum;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewNum addSubview:line];
    }
    return _viewNum;
}

// 开始时间
-(UIView *)viewStartTime{
    if (!_viewStartTime) {
        _viewStartTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewNum.bottom, kSCREEN_WIDTH, 55)];
        _viewStartTime.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"开始时间" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewStartTime addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewStartTime addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        UILabel *lblStartTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10-24, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblStartTime = lblStartTime;
        lblStartTime.centerY = lblText.centerY;
        [_viewStartTime addSubview:self.lblStartTime];
        
        if (self.timeModel) {
            self.startTimeStr = self.timeModel.startTime;
            self.lblStartTime.text = [NSString stringWithFormat:@"%@:00",self.timeModel.startTime];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStartTimeAction:)];
        _viewStartTime.userInteractionEnabled = YES;
        [_viewStartTime addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewStartTime addSubview:line];

    }
    return _viewStartTime;
}

// 结束时间
-(UIView *)viewEndTime{
    if (!_viewEndTime) {
        _viewEndTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewStartTime.bottom, kSCREEN_WIDTH, 55)];
        _viewEndTime.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"结束时间" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewEndTime addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewEndTime addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        UILabel *lblEndTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10-24, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblEndTime = lblEndTime;
        lblEndTime.centerY = lblText.centerY;
        [_viewEndTime addSubview:self.lblEndTime];
        
        if (self.timeModel) {
            self.endTimeStr = self.timeModel.endTime;
            self.lblEndTime.text = [NSString stringWithFormat:@"%@:00",self.timeModel.endTime];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEndTimeAction:)];
        _viewEndTime.userInteractionEnabled = YES;
        [_viewEndTime addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewEndTime addSubview:line];
    }
    return _viewEndTime;
}

-(UIButton *)btnDone{
    if (!_btnDone) {
        _btnDone = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, _viewEndTime.bottom+40, kSCREEN_WIDTH-32, 48) btnTitle:@"完成" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnDone.layer.cornerRadius = 24;
        _btnDone.backgroundColor = RGBMAIN;
        
        [_btnDone addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDone;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        NSString *rightBtn = @"";
        if (self.timeModel) {
            rightBtn = @"删除";
        }
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"新增预约理发时段" bgColor:RGBMAIN backBtn:YES rightBtn:rightBtn rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
