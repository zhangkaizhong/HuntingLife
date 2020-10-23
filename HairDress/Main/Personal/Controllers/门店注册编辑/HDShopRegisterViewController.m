//
//  HDShopRegisterViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDShopRegisterViewController.h"

#import "HDEditShopInfoViewController.h"
#import "AddressPickView.h"
#import "TradeAreaPickerView.h"
#import "MHActionSheet.h"
#import "ACMediaPickerManager.h"

@interface HDShopRegisterViewController ()<navViewDelegate,UITextFieldDelegate>

///需要先定义一个属性，防止临时变量被释放
@property (nonatomic, strong) ACMediaPickerManager *mgr;
@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

// 法人
@property (nonatomic,strong) UIView *viewLegal;
@property (nonatomic,weak) HDTextFeild *txtLegalName;

// 电话
@property (nonatomic,strong) UIView *viewPhone;
@property (nonatomic,weak) HDTextFeild *txtPhone;

// 信用代码
@property (nonatomic,strong) UIView *viewCode;
@property (nonatomic,weak) HDTextFeild *txtCode;

// 营业执照
@property (nonatomic,strong) UIView *viewLicense;
@property (nonatomic,weak) UIImageView *imgLicense;

// 门店名称
@property (nonatomic,strong) UIView *viewShopName;
@property (nonatomic,weak) HDTextFeild *txtShopName;

// 门店地址
@property (nonatomic,strong) UIView *viewAddress;
@property (nonatomic,weak) HDTextFeild *txtAddress;
@property (nonatomic,strong) UIView *viewCity;//城市
@property (nonatomic,weak) UILabel *lblCity;
@property (nonatomic,strong) UIView *viewTradeArea;//商圈
@property (nonatomic,weak) UILabel *lblTrade;

// 审核状态
@property (nonatomic,strong) UIView *viewCheckStatus;
@property (nonatomic,strong) UIView *viewReson;// 拒绝
@property (nonatomic,weak) UILabel *lblReson;//拒绝原因
@property (nonatomic,weak) UILabel *lblStatus;//审核状态

// 申请
@property (nonatomic,strong) UIButton *btnApply;

// 地区数据
@property (nonatomic,strong) NSArray *arrAreasData;
// 商圈数据
@property (nonatomic,strong) NSArray *arrTradesData;
// 门店详情数据
@property (nonatomic,strong) NSDictionary *dicShop;

//省市区ID
@property (nonatomic,copy) NSString *provinceID,*cityID,*areaID;
//商圈id
@property (nonatomic,copy) NSString *tradeID;
//执照图片地址
@property (nonatomic,copy) NSString *lisenceImageUrl;

@property (nonatomic, assign) NSInteger textLocation;//用来记录输入位置

@end

@implementation HDShopRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    // 获取门店注册详情
    [self getRegisterShopDetail];
    
    // 请求地区数据
    [self getAreasRequest];
}

#pragma mark -- delegate / action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 申请
-(void)applyAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"开始编辑"]) {
        HDEditShopInfoViewController *editVC = [HDEditShopInfoViewController new];
        editVC.shop_id = self.dicShop[@"storeId"];
        [self.navigationController pushViewController:editVC animated:YES];
    }else if ([sender.titleLabel.text isEqualToString:@"申请"]){
        [self registerShopRequest];
    }else if ([sender.titleLabel.text isEqualToString:@"重新申请"]){
        [self registerShopRequest];
    }
}

// 添加营业执照
-(void)tapLicenseAddAction:(UIGestureRecognizer *)sender{
    
    self.mgr = [[ACMediaPickerManager alloc] init];
    //外观
    self.mgr.naviBgColor = [UIColor whiteColor];
    self.mgr.naviTitleColor = [UIColor blackColor];
    self.mgr.naviTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.mgr.barItemTextColor = [UIColor blackColor];
    self.mgr.barItemTextFont = [UIFont systemFontOfSize:15.0f];
    self.mgr.statusBarStyle = UIStatusBarStyleDefault;
    
    self.mgr.allowPickingImage = YES;
    self.mgr.allowPickingGif = YES;
    self.mgr.maxImageSelected = 1;
    __weak typeof(self) weakSelf = self;
    self.mgr.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {
        if (list.count>0) {
            ACMediaModel *model = list[0];
            [weakSelf uploadImageFile:model.image];
        }
    };
    [self.mgr picker];
}

// 选择城市
-(void)tapCityAction:(UIGestureRecognizer *)sender{
    WeakSelf;
    if (self.arrAreasData.count == 0) {
        [MHNetworkManager postReqeustWithURL:URL_AreasList params:@{} successBlock:^(NSDictionary *returnData) {
            NSArray *arrProvice = returnData[@"data"];
            weakSelf.arrAreasData = arrProvice;
            AddressPickView *picker = [[AddressPickView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) arrData:weakSelf.arrAreasData];
            picker.addressblock = ^(NSDictionary *province, NSDictionary *city, NSDictionary *town) {
                weakSelf.provinceID = province[@"id"];
                weakSelf.cityID = city[@"id"];
                weakSelf.areaID = town[@"id"];
                weakSelf.lblCity.text = [NSString stringWithFormat:@"%@ %@ %@",province[@"name"],city[@"name"],town[@"name"]];
                weakSelf.lblTrade.text = @"请选择";
                weakSelf.tradeID = @"";
            };
            [weakSelf.view addSubview:picker];
        } failureBlock:^(NSError *error) {
            
        } showHUD:YES];
    }else{
        AddressPickView *picker = [[AddressPickView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) arrData:self.arrAreasData];
        picker.addressblock = ^(NSDictionary *province, NSDictionary *city, NSDictionary *town) {
            weakSelf.provinceID = [NSString stringWithFormat:@"%ld",(long)[province[@"id"] integerValue]];
            weakSelf.cityID = [NSString stringWithFormat:@"%ld",(long)[city[@"id"] integerValue]];
            weakSelf.areaID = [NSString stringWithFormat:@"%ld",(long)[town[@"id"] integerValue]];
            weakSelf.lblCity.text = [NSString stringWithFormat:@"%@ %@ %@",province[@"name"],city[@"name"],town[@"name"]];
            weakSelf.lblTrade.text = @"请选择";
            weakSelf.tradeID = @"";
        };
        [self.view addSubview:picker];
    }
}

// 选择商圈
-(void)tapTradeAction:(UIGestureRecognizer *)sender{
    if ([HDToolHelper StringIsNullOrEmpty:self.areaID]) {
        [SVHUDHelper showDarkWarningMsg:@"请先选择所在区域"];
        return;
    }
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TradeAreaList params:@{@"cityId":self.areaID} successBlock:^(NSDictionary *returnData) {
        self.arrTradesData = returnData[@"data"];
        if (self.arrTradesData.count > 0) {
            TradeAreaPickerView *picker = [[TradeAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) arrData:self.arrTradesData];
            picker.tradeblock = ^(NSDictionary * _Nonnull tradeArea) {
                weakSelf.tradeID = [NSString stringWithFormat:@"%ld",(long)[tradeArea[@"id"] integerValue]];
                weakSelf.lblTrade.text = tradeArea[@"name"];
            };
            [self.view addSubview:picker];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:@"该地区暂无商圈"];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

// 输入监听
-(void)textFieldDidChange:(UITextField *)textField{
    //法人名长度
    if (self.txtLegalName.text.length > 10) {
        self.txtLegalName.text = [self.txtLegalName.text substringToIndex:10];
    }
    //联系电话
    if (self.txtPhone.text.length > 15) {
        self.txtPhone.text = [self.txtPhone.text substringToIndex:15];
    }
    //信用代码
    if (self.txtCode.text.length > 25) {
        self.txtCode.text = [self.txtCode.text substringToIndex:25];
    }
    //门店名称
    if (self.txtShopName.text.length > 20) {
        self.txtShopName.text = [self.txtShopName.text substringToIndex:20];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    DTLog(@"%@",string);
    if ([textField isFirstResponder]) {
        
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }

        //判断键盘是不是九宫格键盘
        if ([HDToolHelper isNineKeyBoard:string] ){
                return YES;
        }else{
            if ([HDToolHelper hasEmoji:string] || [HDToolHelper stringContainsEmoji:string]){
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark -- 上传图片
-(void)uploadImageFile:(UIImage *)image{
    
    [MHNetworkManager uploadFileWithURL:URL_UploadFile params:@{} imageFile:image successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.imgLicense.image = image;
            self.lisenceImageUrl = returnData[@"data"];
        }else{
            [SVHUDHelper showInfoWithTimestamp:0.5 msg:@"图片上传失败"];
        }
    } failureBlock:^(NSError *error) {
            
    } showHUD:NO];
}

#pragma mark -- 门店注册请求
-(void)registerShopRequest{
    if ([HDToolHelper StringIsNullOrEmpty:self.txtLegalName.text]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请输入法人姓名"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.txtPhone.text]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请输入联系电话"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.txtAddress.text]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请输入门店地址"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.provinceID] || [HDToolHelper StringIsNullOrEmpty:self.cityID] || [HDToolHelper StringIsNullOrEmpty:self.areaID]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请选择所属区域"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.tradeID]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请选择商圈"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.lisenceImageUrl]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请上传营业执照"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.txtCode.text]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请输入统一社会信用代码"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.txtShopName.text]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请输入门店名称"];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.txtAddress.text forKey:@"address"];
    [params setValue:self.lisenceImageUrl forKey:@"businessLicense"];
    [params setValue:self.areaID forKey:@"area"];
    [params setValue:self.cityID forKey:@"city"];
    [params setValue:self.txtCode.text forKey:@"creditCode"];
    [params setValue:self.provinceID forKey:@"province"];
    [params setValue:self.txtShopName.text forKey:@"storeName"];
    if (![self.tradeID isEqualToString:@""]) {
        [params setValue:self.tradeID forKey:@"tradeArea"];
    }
    [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"userId"];
    [params setValue:self.txtLegalName.text forKey:@"userName"];
    [params setValue:self.txtPhone.text forKey:@"userPhone"];
    if (self.dicShop) {
        [params setValue:self.dicShop[@"storeId"] forKey:@"storeId"];
    }
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_ShopRegister params:params successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDToolHelper delayMethodFourGCD:1.5 method:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//获取门店详情
-(void)getRegisterShopDetail{
    [MHNetworkManager postReqeustWithURL:URL_ShopRegisterDetail params:@{@"userId":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if ([returnData[@"data"] isKindOfClass:[NSString class]]) {
                if ([HDToolHelper StringIsNullOrEmpty:returnData[@"data"]]) {//未注册门店
                    self.checkStatus = @"";
                }
            }
            else{
                NSDictionary *dicInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
                self.dicShop = dicInfo;
                if([returnData[@"data"][@"auditStatus"] isEqualToString:@"wait"]){//审核中
                    self.checkStatus = @"2";
                }else if ([returnData[@"data"][@"auditStatus"] isEqualToString:@"success"]){//审核通过
                    self.checkStatus = @"1";
                }else if ([returnData[@"data"][@"auditStatus"] isEqualToString:@"refuse"]){//已拒绝
                    self.checkStatus = @"3";
                }
            }
        }
        [self.view addSubview:self.mainScrollView];
        [self.view addSubview:self.btnApply];
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//请求所有城市列表
-(void)getAreasRequest{
    [MHNetworkManager postReqeustWithURL:URL_AreasList params:@{} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arrProvice = returnData[@"data"];
            self.arrAreasData = arrProvice;
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark -- 加载控件

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        // 底部视图
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT+32+40+48,kSCREEN_WIDTH,32+40+48)];
        [_mainScrollView addSubview:footer];
        _mainScrollView.contentInset = UIEdgeInsetsMake(0, 0, 32+40+48, 0);
        
        UIView *viewText1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 36)];
        viewText1.backgroundColor = RGBBG;
        [_mainScrollView addSubview:viewText1];
        
        UILabel *lblText1 = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 12) title:@"基本信息" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewText1 addSubview:lblText1];
        
        // 法人
        [_mainScrollView addSubview:self.viewLegal];
        // 电话
        [_mainScrollView addSubview:self.viewPhone];
        // 代码
        [_mainScrollView addSubview:self.viewCode];
        // 营业执照
        [_mainScrollView addSubview:self.viewLicense];
        // 门店名称
        [_mainScrollView addSubview:self.viewShopName];
        // 门店地址
        [_mainScrollView addSubview:self.viewAddress];
        
        if ([self.checkStatus isEqualToString:@"1"]) {//已通过
            // 审核状态
            [_mainScrollView addSubview:self.viewCheckStatus];
            self.lblStatus.text = @"已通过";
            [self.btnApply setTitle:@"开始编辑" forState:UIControlStateNormal];
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewCheckStatus.bottom);
        }else if ([self.checkStatus isEqualToString:@"2"]){//审核中
            // 审核状态
            [_mainScrollView addSubview:self.viewCheckStatus];
            self.lblStatus.text = @"审核中";
            self.btnApply.hidden = YES;
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewCheckStatus.bottom);
        }else if ([self.checkStatus isEqualToString:@"3"]){//拒绝
            // 审核状态
            [_mainScrollView addSubview:self.viewCheckStatus];
            [_mainScrollView addSubview:self.viewReson];
            self.lblStatus.text = @"未通过";
            [self.btnApply setTitle:@"重新申请" forState:UIControlStateNormal];
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewReson.bottom);
        }else{
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewAddress.bottom);
        }
    }
    return _mainScrollView;
}

// 法人
-(UIView *)viewLegal{
    if (!_viewLegal) {
        _viewLegal = [[UIView alloc] initWithFrame:CGRectMake(0, 36, kSCREEN_WIDTH, 56)];
        _viewLegal.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 150, 14) title:@"法人姓名" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewLegal addSubview:lblText];
        lblText.centerY = _viewLegal.height/2;
        
        HDTextFeild *txtName = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblText.frame)-26, 14)];
        txtName.centerY = lblText.centerY;
        txtName.font = [UIFont systemFontOfSize:14];
        txtName.textColor = RGBTEXT;
        txtName.placeholder = @"请输入法人姓名";
        txtName.textAlignment = NSTextAlignmentRight;
        txtName.delegate = self;
        self.txtLegalName = txtName;
        [self.txtLegalName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        if (self.dicShop) {
            self.txtLegalName.text = self.dicShop[@"userName"];
        }
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            self.txtLegalName.userInteractionEnabled = NO;
        }
        [_viewLegal addSubview:txtName];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 55, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewLegal addSubview:line];
    }
    return _viewLegal;
}

// 电话
-(UIView *)viewPhone{
    if (!_viewPhone) {
        _viewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, _viewLegal.bottom, kSCREEN_WIDTH, 71)];
        _viewPhone.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 150, 14) title:@"联系电话" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewPhone addSubview:lblText];
        
        HDTextFeild *txtPhone = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblText.frame)-26, 14)];
        txtPhone.centerY = lblText.centerY;
        txtPhone.font = [UIFont systemFontOfSize:14];
        txtPhone.textColor = RGBTEXT;
        txtPhone.placeholder = @"请输入联系电话";
        txtPhone.textAlignment = NSTextAlignmentRight;
        txtPhone.delegate = self;
        txtPhone.keyboardType = UIKeyboardTypePhonePad;
        self.txtPhone = txtPhone;
        [self.txtPhone addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        if (self.dicShop) {
            self.txtPhone.text = self.dicShop[@"userPhone"];
        }
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            self.txtPhone.userInteractionEnabled = NO;
        }
        [_viewPhone addSubview:txtPhone];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 55, kSCREEN_WIDTH, 16)];
        line.backgroundColor = RGBBG;
        [_viewPhone addSubview:line];
    }
    return _viewPhone;
}

// 代码
-(UIView *)viewCode{
    if (!_viewCode) {
        _viewCode = [[UIView alloc] initWithFrame:CGRectMake(0, _viewPhone.bottom, kSCREEN_WIDTH, 56)];
        _viewCode.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 150, 14) title:@"统一社会信用代码" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewCode addSubview:lblText];
        
        HDTextFeild *txtCode = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblText.frame)-26, 14)];
        txtCode.centerY = lblText.centerY;
        txtCode.font = [UIFont systemFontOfSize:14];
        txtCode.textColor = RGBTEXT;
        txtCode.placeholder = @"请输入统一社会信用代码";
        txtCode.textAlignment = NSTextAlignmentRight;
        self.txtCode = txtCode;
        txtCode.delegate = self;
        [self.txtCode addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        if (self.dicShop) {
            self.txtCode.text = self.dicShop[@"creditCode"];
        }
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            self.txtCode.userInteractionEnabled = NO;
        }
        [_viewCode addSubview:txtCode];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 55, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewCode addSubview:line];
    }
    return _viewCode;
}

// 营业执照
-(UIView *)viewLicense{
    if (!_viewLicense) {
        _viewLicense = [[UIView alloc] initWithFrame:CGRectMake(0, _viewCode.bottom, kSCREEN_WIDTH, 170+48)];
        _viewLicense.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"营业执照" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewLicense addSubview:lblText];
        
        UIImageView *imageLicense = [[UIImageView alloc] initWithFrame:CGRectMake(16, lblText.bottom+16, 100, 100)];
        imageLicense.image = [UIImage imageNamed:@"add_photo"];
        [_viewLicense addSubview:imageLicense];
        self.imgLicense = imageLicense;
        if (self.dicShop) {
            self.lisenceImageUrl = self.dicShop[@"businessLicense"];
            [self.imgLicense sd_setImageWithURL:[NSURL URLWithString:self.dicShop[@"businessLicense"]]];
        }
        [_viewLicense addSubview:self.imgLicense];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLicenseAddAction:)];
        imageLicense.userInteractionEnabled = YES;
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            imageLicense.userInteractionEnabled = NO;
        }
        [imageLicense addGestureRecognizer:tap];
        
        UIView *viewText2 = [[UIView alloc] initWithFrame:CGRectMake(0, imageLicense.bottom+20, kSCREEN_WIDTH, 48)];
        [_viewLicense addSubview:viewText2];
        viewText2.backgroundColor = RGBBG;
        
        UILabel *lblText2 = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 20) title:@"点击上传营业执照原件/复印件，复印件需加盖公章" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewText2 addSubview:lblText2];
    }
    return _viewLicense;
}

// 门店名称
-(UIView *)viewShopName{
    if (!_viewShopName) {
        _viewShopName = [[UIView alloc] initWithFrame:CGRectMake(0, _viewLicense.bottom, kSCREEN_WIDTH, 90)];
        _viewShopName.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 150, 14) title:@"门店名称" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewShopName addSubview:lblText];
        
        HDTextFeild *txtShopName = [[HDTextFeild alloc] initWithFrame:CGRectMake(16, lblText.bottom+12, kSCREEN_WIDTH-32, 22)];
        txtShopName.font = [UIFont systemFontOfSize:14];
        txtShopName.textColor = RGBTEXT;
        txtShopName.placeholder = @"请输入门店名称";
        txtShopName.textAlignment = NSTextAlignmentLeft;
        self.txtShopName = txtShopName;
        txtShopName.delegate = self;
        [self.txtShopName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        if (self.dicShop) {
            self.txtShopName.text = self.dicShop[@"storeName"];
        }
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            self.txtShopName.userInteractionEnabled = NO;
        }
        [_viewShopName addSubview:txtShopName];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 89, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewShopName addSubview:line];
    }
    return _viewShopName;
}

// 门店地址
-(UIView *)viewAddress{
    if (!_viewAddress) {
        _viewAddress = [[UIView alloc] initWithFrame:CGRectMake(0, _viewShopName.bottom, kSCREEN_WIDTH, 214)];
        _viewAddress.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 150, 14) title:@"门店地址" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewAddress addSubview:lblText];
        
        [_viewAddress addSubview:self.viewCity];
        [_viewAddress addSubview:self.viewTradeArea];
        
        HDTextFeild *txtAddress = [[HDTextFeild alloc] initWithFrame:CGRectMake(16, _viewTradeArea.bottom+12, kSCREEN_WIDTH-32, 22)];
        txtAddress.font = [UIFont systemFontOfSize:14];
        txtAddress.textColor = RGBTEXT;
        txtAddress.placeholder = @"请输入门店地址";
        txtAddress.textAlignment = NSTextAlignmentLeft;
        self.txtAddress = txtAddress;
        txtAddress.delegate = self;
        [self.txtAddress addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        if (self.dicShop) {
            self.txtAddress.text = self.dicShop[@"address"];
        }
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            self.txtAddress.userInteractionEnabled = NO;
        }
        [_viewAddress addSubview:txtAddress];
        
        _viewAddress.height = _txtAddress.bottom+20;
    }
    return _viewAddress;
}

// 城市选择
-(UIView *)viewCity{
    if (!_viewCity) {
        _viewCity = [[UIView alloc] initWithFrame:CGRectMake(0, 46, kSCREEN_WIDTH, 57)];
        _viewCity.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, 100, 14) title:@"所在区域" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewCity addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewCity addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        // 城市
        UILabel *lblCity = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-24-16-CGRectGetMaxX(lblText.frame)-10, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblCity = lblCity;
        //详情
        if (self.dicShop) {
            self.lblCity.text = [NSString stringWithFormat:@"%@ %@ %@",self.dicShop[@"provinceName"],self.dicShop[@"cityName"],self.dicShop[@"areaName"]];
            self.provinceID = self.dicShop[@"province"];
            self.cityID = self.dicShop[@"city"];
            self.areaID = self.dicShop[@"area"];
        }
        lblCity.centerY = lblText.centerY;
        [_viewCity addSubview:self.lblCity];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 56, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewCity addSubview:line];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCityAction:)];
        _viewCity.userInteractionEnabled = YES;
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            _viewCity.userInteractionEnabled = NO;
            imageGo.hidden = YES;
            self.lblCity.width = kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10;
        }
        [_viewCity addGestureRecognizer:tap];

    }
    return _viewCity;
}

// 商圈选择
-(UIView *)viewTradeArea{
    if (!_viewTradeArea) {
        _viewTradeArea = [[UIView alloc] initWithFrame:CGRectMake(0, _viewCity.bottom, kSCREEN_WIDTH, 57)];
        _viewTradeArea.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, 100, 14) title:@"所处商圈" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewTradeArea addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewTradeArea addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        UILabel *lblTrade = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-24-16-CGRectGetMaxX(lblText.frame)-10, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblTrade = lblTrade;
        if (self.dicShop) {
            if (![HDToolHelper StringIsNullOrEmpty:self.dicShop[@"tradeAreaName"]]) {
                self.lblTrade.text = self.dicShop[@"tradeAreaName"];
            }else{
                self.lblTrade.text = @"暂无商圈";
            }
            if (![HDToolHelper StringIsNullOrEmpty:self.dicShop[@"tradeArea"]]) {
                self.tradeID = self.dicShop[@"tradeArea"];
            }
        }
        lblTrade.centerY = lblText.centerY;
        [_viewTradeArea addSubview:self.lblTrade];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 56, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewTradeArea addSubview:line];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTradeAction:)];
        _viewTradeArea.userInteractionEnabled = YES;
        //审核中和审核通过不能编辑
        if ([self.checkStatus isEqualToString:@"1"] || [self.checkStatus isEqualToString:@"2"]) {
            _viewTradeArea.userInteractionEnabled = NO;
            imageGo.hidden = YES;
            self.lblTrade.width = kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10;
        }
        [_viewTradeArea addGestureRecognizer:tap];

    }
    return _viewTradeArea;
}

// 审核状态
-(UIView *)viewCheckStatus{
    if (!_viewCheckStatus) {
        _viewCheckStatus = [[UIView alloc] initWithFrame:CGRectMake(0, _viewAddress.bottom+16, kSCREEN_WIDTH, 54)];
        _viewCheckStatus.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 150, 14) title:@"当前状态" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewCheckStatus addSubview:lblText];
        
        UILabel *lblStatus = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH-150-16, 20, 150, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblStatus = lblStatus;
        [_viewCheckStatus addSubview:lblStatus];
    }
    return _viewCheckStatus;
}

// 拒绝原因
-(UIView *)viewReson{
    if (!_viewReson) {
        _viewReson = [[UIView alloc] initWithFrame:CGRectMake(0, _viewCheckStatus.bottom, kSCREEN_WIDTH, 88)];
        _viewReson.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewReson addSubview:line];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 150, 14) title:@"原因" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewReson addSubview:lblText];
        
        UILabel *lblReason = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblText.bottom+12, kSCREEN_WIDTH-32, 42) title:@"营业执照已过期营业执照已过期营业执照已过期营业执照已过期营业执照已过期营业执照已过期" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblReson = lblReason;
        if (self.dicShop) {
            self.lblReson.text = self.dicShop[@"refuseDesc"];
        }
        lblReason.numberOfLines = 0;
        [lblReason sizeToFit];
        [_viewReson addSubview:self.lblReson];
        
        _viewReson.height = _lblReson.bottom+16;
    }
    return _viewReson;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"门店注册" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

// 申请
-(UIButton *)btnApply{
    if (!_btnApply) {
        _btnApply = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"申请" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnApply.layer.cornerRadius = 24;
        _btnApply.backgroundColor = RGBMAIN;
        
        [_btnApply addTarget:self action:@selector(applyAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnApply;
}

@end
