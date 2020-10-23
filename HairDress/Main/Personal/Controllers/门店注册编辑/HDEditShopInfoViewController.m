//
//  HDEditShopInfoViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDEditShopInfoViewController.h"

#import "HDChooseServicesViewController.h"
#import "HDNewPersonalViewController.h"
#import "ACMediaPickerManager.h"
#import "DateTimePickerView.h"
#import "HDShopEditChooseModel.h"
#import "ACMediaModel.h"

@interface HDEditShopInfoViewController ()<navViewDelegate,DateTimePickerViewDelegate,HDChooseServicesConfigDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) DateTimePickerView *datePickerView;
@property (nonatomic,copy) NSString *timeType;

// 营业周期
@property (nonatomic,strong) UIView *viewWeekDay;
@property (nonatomic,weak) UILabel *lblWeekDay;
// 开始时间
@property (nonatomic,strong) UIView *viewBegainTime;
@property (nonatomic,weak) UILabel *lblBegainTime;
// 结束时间
@property (nonatomic,strong) UIView *viewEndTime;
@property (nonatomic,weak) UILabel *lblEndTime;

// 特惠活动
@property (nonatomic,strong) UIView *viewTehui;
@property (nonatomic,weak) UILabel *lblTehui;
// 服务标准
@property (nonatomic,strong) UIView *viewService;
@property (nonatomic,weak) UILabel *lblService;

// 门店标志
@property (nonatomic,strong) UIView *viewShopCover;
@property (nonatomic,weak) UIImageView *imageCover;

// 门店环境
@property (nonatomic,strong) UIView *viewShopEnv;
@property (nonatomic,strong) UIView *viewImages;

@property (nonatomic,copy)  NSString *imageLogoUrl;//门店logo
@property (nonatomic,strong) NSMutableArray *arrLogoImages;// logo图片数组
@property (nonatomic,strong) NSMutableArray *arrImageUrls;//待上传图片URL

///需要先定义一个属性，防止临时变量被释放
@property (nonatomic, strong) ACMediaPickerManager *mgr;

@property (nonatomic,strong) UIButton *btnDone;// 完成

// 服务配置类型
@property (nonatomic,strong) NSMutableArray *arrConfigTypes;
/**
 working_day:工作日,
 service_standard:服务标准,
 service_item:服务项目,
 position:岗位,
 evaluate_label:评价标签,
 cancel_reason:取消原因,
 */

@property (nonatomic,strong) NSMutableArray *arrSelectService;//选择服务标准
@property (nonatomic,strong) NSMutableArray *arrSelectWorkdays;//选择服务周期

@end

@implementation HDEditShopInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrConfigTypes = [NSMutableArray new];
    self.arrSelectService = [NSMutableArray new];
    self.arrSelectWorkdays = [NSMutableArray new];
    self.arrImageUrls = [NSMutableArray new];
    self.arrLogoImages = [NSMutableArray new];
    self.view.backgroundColor = RGBBG;
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.btnDone];
    
    //获取门店编辑详情
    [self getEditShopDetail];
}

#pragma mark -- delegate / action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 完成
-(void)editDoneAction{
    [self editShopRequest];
}

#pragma mark ================== 点击添加门店标志图片 =====================
-(void)tapImageAddAction:(UIGestureRecognizer *)sender{
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
    if (self.arrLogoImages.count > 0) {
        self.mgr.seletedMediaArray = self.arrLogoImages;
    }
    __weak typeof(self) weakSelf = self;
    self.mgr.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {
        [weakSelf.arrLogoImages removeAllObjects];
        if (list.count>0) {
            [weakSelf.arrLogoImages addObjectsFromArray:list];
            ACMediaModel *model = list[0];
            [weakSelf uploadImageFile:model.image];
        }
    };
    [self.mgr picker];
}

#pragma mark ================== 选择服务标准 =====================
-(void)tapChooseServiceAction:(UIGestureRecognizer *)sender{
    HDChooseServicesViewController *service = [HDChooseServicesViewController new];
    service.chooseType = @"service_standard";
    service.delegate = self;
    service.arrSelects = self.arrSelectService;
    [self.navigationController pushViewController:service animated:YES];
}

#pragma mark ================== 选择特惠活动 =====================
-(void)tapChooseTehuiAction:(UIGestureRecognizer *)sender{
//    HDChooseServicesViewController *service = [HDChooseServicesViewController new];
//    service.chooseType = @"tehui";
//    [self.navigationController pushViewController:service animated:YES];
}

#pragma mark ================== 选择营业周期 =====================
-(void)tapChooseWeekDayAction:(UIGestureRecognizer *)sender{
    HDChooseServicesViewController *service = [HDChooseServicesViewController new];
    service.chooseType = @"working_day";
    service.delegate = self;
    service.arrSelects = self.arrSelectWorkdays;
    [self.navigationController pushViewController:service animated:YES];
}

// 选择开始时间
-(void)tapChooseBegainTimeAction:(UIGestureRecognizer *)sender{
    self.timeType = @"1";
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    self.datePickerView = pickerView;
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewTimeMode;
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

// 选择结束时间
-(void)tapChooseEndTimeAction:(UIGestureRecognizer *)sender{
    self.timeType = @"2";
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    self.datePickerView = pickerView;
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewTimeMode;
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

#pragma mark ================== 选择项目回调 =====================
-(void)chooseConfigList:(NSString *)type configs:(NSArray *)arrConfigs{
    if ([type isEqualToString:@"service_standard"]) {//服务标准
        [self.arrSelectService removeAllObjects];
        [self.arrSelectService addObjectsFromArray:arrConfigs];
        self.lblService.text = [NSString stringWithFormat:@"已选%lu项",(unsigned long)self.arrSelectService.count];
    }
    else if ([type isEqualToString:@"working_day"]){//工作日
        [self.arrSelectWorkdays removeAllObjects];
        [self.arrSelectWorkdays addObjectsFromArray:arrConfigs];
        [self.arrSelectWorkdays sortUsingComparator:^NSComparisonResult(HDShopEditChooseModel *obj1, HDShopEditChooseModel *obj2) {
            return [obj1.configValue compare:obj2.configValue];
        }];
        
        NSString *strWeekdays = @"";
        for (HDShopEditChooseModel *model in self.arrSelectWorkdays) {
            strWeekdays = [NSString stringWithFormat:@"%@ %@",strWeekdays,model.configName];
        }
        self.lblWeekDay.text = strWeekdays;
        [self.lblWeekDay sizeToFit];
        self.lblWeekDay.x = kSCREEN_WIDTH-self.lblWeekDay.width-24-16;
    }
}

#pragma mark ================== 编辑门店相关请求 =====================
//编辑门店
-(void)editShopRequest{
    if ([self.lblEndTime.text isEqualToString:@"请选择"]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请选择结束时间"];
        return;
    }
    if ([self.lblBegainTime.text isEqualToString:@"请选择"]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请选择开始时间"];
        return;
    }
    if (self.arrSelectService.count == 0) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请添加服务标准"];
        return;
    }
    if (self.arrSelectWorkdays.count == 0) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请选择营业周期"];
        return;
    }
    if (self.arrImageUrls.count == 0) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请上传门店环境图片"];
        return;
    }
    if (!self.imageLogoUrl || [self.imageLogoUrl isEqualToString:@""]) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请上传门店LOGO"];
        return;
    }
    //服务标准
    NSMutableArray *arrServices = [NSMutableArray new];
    for (HDShopEditChooseModel *model in self.arrSelectService) {
        [arrServices addObject:@{@"configName":model.configName,@"configValue":model.configValue}];
    }
    //工作日
    NSMutableArray *arrWorkdays = [NSMutableArray new];
    for (HDShopEditChooseModel *model in self.arrSelectWorkdays) {
        [arrWorkdays addObject:@{@"configName":model.configName,@"configValue":model.configValue}];
    }
    NSDictionary *params = @{
        @"endTime":self.lblEndTime.text,
        @"storeId":self.shop_id,
        @"imgList":self.arrImageUrls,
        @"logoImg":self.imageLogoUrl,
        @"serviceStandardList":arrServices,
        @"startTime":self.lblBegainTime.text,
        @"workingDayList":arrWorkdays
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_EditStore params:params successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDToolHelper delayMethodFourGCD:1.5 method:^{
                for (UIViewController *vieCon in [self.navigationController viewControllers]) {
                    if ([vieCon isKindOfClass:[HDNewPersonalViewController class]]) {
                        [weakSelf.navigationController popToViewController:vieCon animated:YES];
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//获取门店编辑详情
-(void)getEditShopDetail{
    if (!self.shop_id) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_EditStoreDetail params:@{@"storeId":self.shop_id} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *dic = [HDToolHelper nullDicToDic:returnData[@"data"]];
            if (![HDToolHelper StringIsNullOrEmpty:dic[@"startTime"]]) {
                self.lblBegainTime.text = dic[@"startTime"];
            }
            if (![HDToolHelper StringIsNullOrEmpty:dic[@"endTime"]]) {
                self.lblEndTime.text = dic[@"endTime"];
            }
            if (![HDToolHelper StringIsNullOrEmpty:dic[@"logoImg"]]) {
                self.imageLogoUrl = dic[@"logoImg"];
                [self.imageCover sd_setImageWithURL:[NSURL URLWithString:self.imageLogoUrl]];
            }
            //工作日
            [self.arrSelectWorkdays addObjectsFromArray:[HDShopEditChooseModel mj_objectArrayWithKeyValuesArray:dic[@"workingDayList"]]];
            if (self.arrSelectWorkdays.count > 0) {
                [self.arrSelectWorkdays sortUsingComparator:^NSComparisonResult(HDShopEditChooseModel *obj1, HDShopEditChooseModel *obj2) {
                    return [obj1.configValue compare:obj2.configValue];
                }];
                
                NSString *strWeekdays = @"";
                for (HDShopEditChooseModel *model in self.arrSelectWorkdays) {
                    strWeekdays = [NSString stringWithFormat:@"%@ %@",strWeekdays,model.configName];
                }
                self.lblWeekDay.text = strWeekdays;
            }
            //服务标准
            [self.arrSelectService addObjectsFromArray:[HDShopEditChooseModel mj_objectArrayWithKeyValuesArray:dic[@"serviceConfigList"]]];
            if (self.arrSelectService.count > 0) {
                self.lblService.text = [NSString stringWithFormat:@"已选%lu项",(unsigned long)self.arrSelectService.count];
            }
            
            //图片
            [self.arrImageUrls removeAllObjects];
            [self.arrImageUrls addObjectsFromArray:dic[@"imgList"]];
            if (self.arrImageUrls.count > 0) {
                [self createImageView];
            }
            
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- 上传多张图片请求
-(void)uploadImageRequest:(NSArray *)images{
    
    NSMutableArray *imagesArr = [NSMutableArray new];
    
    for (int i =0; i<images.count; i++) {
        ACMediaModel *model = images[i];
        [imagesArr addObject:model.image];
    }
    
    FGUploadImageManager *manager = [FGUploadImageManager new];
    [manager upLoadImageWithImageArray:imagesArr Completion:^(NSArray *imageUrls, BOOL isSuccess) {
        if (isSuccess) {
            [self.arrImageUrls addObjectsFromArray:imageUrls];
            [SVHUDHelper showInfoWithTimestamp:1 msg:@"图片上传成功"];
            [self createImageView];
        }
    }];
}

#pragma mark -- 上传单张图片
-(void)uploadImageFile:(UIImage *)image{
    
    [MHNetworkManager uploadFileWithURL:URL_UploadFile params:@{} imageFile:image successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.imageCover.image = image;
            self.imageLogoUrl = returnData[@"data"];
        }else{
            [SVHUDHelper showInfoWithTimestamp:0.5 msg:@"图片上传失败"];
        }
    } failureBlock:^(NSError *error) {
            
    } showHUD:YES];
}

// 添加门店环境
-(void)tapEnvImageAddAction:(UIGestureRecognizer *)sender{
    if (self.arrImageUrls.count >= 9) {
        [SVHUDHelper showDarkWarningMsg:@"环境图片最多添加9张"];
        return;
    }
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
    self.mgr.maxImageSelected = 9-self.arrImageUrls.count;
    __weak typeof(self) weakSelf = self;
    self.mgr.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {
        [weakSelf uploadImageRequest:list];
    };
    [self.mgr picker];
}

// 删除门店环境图片 单删
-(void)btnDelImageAction:(UIButton *)sender{
    NSInteger tag = sender.tag;
    [self.arrImageUrls removeObjectAtIndex:tag-200];
    [self createImageView];
}

// 创建图片展示视图
-(void)createImageView{
    
    for(UIView *view in [_viewImages subviews]){
        [view removeFromSuperview];
    }
    for (int i =0 ; i<self.arrImageUrls.count+1; i++) {
        CGFloat width_img = (kSCREEN_WIDTH-32-43)/3;
        
        UIImageView *imageInfo = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20+i*(100+16), width_img, width_img)];
        if (i==self.arrImageUrls.count) {
            imageInfo.image = [UIImage imageNamed:@"img_add_photo"];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEnvImageAddAction:)];
            imageInfo.userInteractionEnabled = YES;
            [imageInfo addGestureRecognizer:tap];
        }else{
            // 选中的视图
            [imageInfo sd_setImageWithURL:[NSURL URLWithString:self.arrImageUrls[i]]];
        }
        
        imageInfo.tag = 100 + i;
        
        UIView *imageLast = (UIView *)[_viewImages viewWithTag:100+i-1];
        
        if (i == 0) {
            imageInfo.x = 16;
            imageInfo.y = 20;
        }else{
            imageInfo.x = CGRectGetMaxX(imageLast.frame)+16;
            if (CGRectGetMaxX(imageInfo.frame)+16 > kSCREEN_WIDTH) {
                imageInfo.x = 16;
                imageInfo.y = CGRectGetMaxY(imageLast.frame)+16;
            }else{
                imageInfo.y = imageLast.y;
            }
        }
        
        [_viewImages addSubview:imageInfo];
        
        // 给每张图片添加删除按钮
        UIButton *btnDel = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(imageInfo.frame)-10, imageInfo.y-8, 20, 20) btnTitle:@"" btnImage:@"chahao" titleColor:[UIColor clearColor] titleFont:0];
        btnDel.tag = 200 + i;
        [btnDel addTarget:self action:@selector(btnDelImageAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i !=self.arrImageUrls.count) {
            [_viewImages addSubview:btnDel];
        }
       
        _viewImages.height = imageInfo.bottom;
        _viewShopEnv.height = _viewImages.bottom+20;
    }
    _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewShopEnv.bottom);
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
        
        // 营业时间
        [_mainScrollView addSubview:self.viewWeekDay];
        [_mainScrollView addSubview:self.viewBegainTime];
        [_mainScrollView addSubview:self.viewEndTime];
        
        // 特惠活动
//        [_mainScrollView addSubview:self.viewTehui];
        // 服务标准
        [_mainScrollView addSubview:self.viewService];
        
        // 门店标志
        [_mainScrollView addSubview:self.viewShopCover];
        // 门店环境
        [_mainScrollView addSubview:self.viewShopEnv];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewShopEnv.bottom);
    }
    return _mainScrollView;
}

// 营业周期
-(UIView *)viewWeekDay{
    if (!_viewWeekDay) {
        UIView *viewText = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 36)];
        viewText.backgroundColor = RGBBG;
        [_mainScrollView addSubview:viewText];
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 12) title:@"营业时间" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewText addSubview:lblText];
        
        _viewWeekDay = [[UIView alloc] initWithFrame:CGRectMake(0, viewText.bottom, kSCREEN_WIDTH, 57)];
        _viewWeekDay.backgroundColor = [UIColor whiteColor];
        
        // 添加点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChooseWeekDayAction:)];
        _viewWeekDay.userInteractionEnabled = YES;
        [_viewWeekDay addGestureRecognizer:tap];
        
        UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, 100, 14) title:@"营业周期" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewWeekDay addSubview:lbl];
        
        UILabel *lblWeekDay = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbl.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(lbl.frame)-5-24-16, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblWeekDay.centerY = lbl.centerY;
        self.lblWeekDay = lblWeekDay;
        [_viewWeekDay addSubview:lblWeekDay];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.x = kSCREEN_WIDTH-24-16;
        imageGo.centerY = lbl.centerY;
        [_viewWeekDay addSubview:imageGo];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 56, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewWeekDay addSubview:line];
    }
    return _viewWeekDay;
}

// 开始时间
-(UIView *)viewBegainTime{
    if (!_viewBegainTime) {
        _viewBegainTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewWeekDay.bottom, kSCREEN_WIDTH, 57)];
        _viewBegainTime.backgroundColor = [UIColor whiteColor];
        
        // 添加点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChooseBegainTimeAction:)];
        _viewBegainTime.userInteractionEnabled = YES;
        [_viewBegainTime addGestureRecognizer:tap];
        
        UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, 100, 14) title:@"开始时间" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewBegainTime addSubview:lbl];
        
        UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbl.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(lbl.frame)-5-24-16, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblTime.centerY = lbl.centerY;
        self.lblBegainTime = lblTime;
        [_viewBegainTime addSubview:lblTime];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.x = kSCREEN_WIDTH-24-16;
        imageGo.centerY = lbl.centerY;
        [_viewBegainTime addSubview:imageGo];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 56, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewBegainTime addSubview:line];
    }
    return _viewBegainTime;
}

// 结束时间
-(UIView *)viewEndTime{
    if (!_viewEndTime) {
        _viewEndTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewBegainTime.bottom, kSCREEN_WIDTH, 57)];
        _viewEndTime.backgroundColor = [UIColor whiteColor];
        
        // 添加点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChooseEndTimeAction:)];
        _viewEndTime.userInteractionEnabled = YES;
        [_viewEndTime addGestureRecognizer:tap];
        
        UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, 100, 14) title:@"结束时间" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewEndTime addSubview:lbl];
        
        UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbl.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(lbl.frame)-5-24-16, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblTime.centerY = lbl.centerY;
        self.lblEndTime = lblTime;
        [_viewEndTime addSubview:lblTime];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.x = kSCREEN_WIDTH-24-16;
        imageGo.centerY = lbl.centerY;
        [_viewEndTime addSubview:imageGo];
    }
    return _viewEndTime;
}

// 特惠活动
-(UIView *)viewTehui{
    if (!_viewTehui) {
        UIView *viewText = [[UIView alloc] initWithFrame:CGRectMake(0, _viewEndTime.bottom, kSCREEN_WIDTH, 36)];
        viewText.backgroundColor = RGBBG;
        [_mainScrollView addSubview:viewText];
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 12) title:@"特惠活动" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewText addSubview:lblText];
        
        _viewTehui = [[UIView alloc] initWithFrame:CGRectMake(0, viewText.bottom, kSCREEN_WIDTH, 57)];
        _viewTehui.backgroundColor = [UIColor whiteColor];
        
        // 添加点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChooseTehuiAction:)];
        _viewTehui.userInteractionEnabled = YES;
        [_viewTehui addGestureRecognizer:tap];
        
        UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, 100, 14) title:@"特惠活动" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewTehui addSubview:lbl];
        
        UILabel *lblTehui = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbl.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(lbl.frame)-5-24-16, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblTehui.centerY = lbl.centerY;
        self.lblTehui = lblTehui;
        [_viewTehui addSubview:self.lblTehui];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.x = kSCREEN_WIDTH-24-16;
        imageGo.centerY = lbl.centerY;
        [_viewTehui addSubview:imageGo];
    }
    return _viewTehui;
}

// 服务标准
-(UIView *)viewService{
    if (!_viewService) {
        UIView *viewText = [[UIView alloc] initWithFrame:CGRectMake(0, _viewEndTime.bottom, kSCREEN_WIDTH, 36)];
        viewText.backgroundColor = RGBBG;
        [_mainScrollView addSubview:viewText];
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 12) title:@"服务标准" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewText addSubview:lblText];
        
        _viewService = [[UIView alloc] initWithFrame:CGRectMake(0, viewText.bottom, kSCREEN_WIDTH, 56+16)];
        _viewService.backgroundColor = [UIColor whiteColor];
        
        // 添加点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChooseServiceAction:)];
        _viewService.userInteractionEnabled = YES;
        [_viewService addGestureRecognizer:tap];
        
        UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, 100, 14) title:@"服务标准" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewService addSubview:lbl];
        
        UILabel *lblService = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbl.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(lbl.frame)-5-24-16, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblService.centerY = lbl.centerY;
        self.lblService = lblService;
        [_viewService addSubview:self.lblService];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imageGo.x = kSCREEN_WIDTH-24-16;
        imageGo.centerY = lbl.centerY;
        [_viewService addSubview:imageGo];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 56, kSCREEN_WIDTH, 16)];
        line.backgroundColor = RGBBG;
        [_viewService addSubview:line];
    }
    return _viewService;
}

// 门店标志
-(UIView *)viewShopCover{
    if (!_viewShopCover) {
        _viewShopCover = [[UIView alloc] initWithFrame:CGRectMake(0, _viewService.bottom, kSCREEN_WIDTH, 170+48)];
        _viewShopCover.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"门店标志" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewShopCover addSubview:lblText];
        
        UIImageView *imageShop = [[UIImageView alloc] initWithFrame:CGRectMake(16, lblText.bottom+16, 100, 100)];
        imageShop.image = [UIImage imageNamed:@"img_add_photo"];
        [_viewShopCover addSubview:imageShop];
        self.imageCover = imageShop;
        [_viewShopCover addSubview:self.imageCover];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAddAction:)];
        imageShop.userInteractionEnabled = YES;
        [imageShop addGestureRecognizer:tap];
        
        UIView *viewText2 = [[UIView alloc] initWithFrame:CGRectMake(0, imageShop.bottom+20, kSCREEN_WIDTH, 48)];
        [_viewShopCover addSubview:viewText2];
        viewText2.backgroundColor = RGBBG;
        
        UILabel *lblText2 = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 40) title:@"点击更改门店标志图片(建议尺寸216*216像素，大小2M以下，JPEG/PNG格式图片)" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblText2.numberOfLines = 0;
        [lblText2 sizeToFit];
        [viewText2 addSubview:lblText2];
        viewText2.height = lblText2.bottom+16;
        
        _viewShopCover.height = viewText2.bottom;
    }
    return _viewShopCover;
}

// 门店环境
-(UIView *)viewShopEnv{
    if (!_viewShopEnv) {
        _viewShopEnv = [[UIView alloc] initWithFrame:CGRectMake(0, _viewShopCover.bottom, kSCREEN_WIDTH, 200)];
        _viewShopEnv.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"门店环境" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewShopEnv addSubview:lblText];
        
        
        // 图片
        UIView *viewImages = [[UIView alloc] initWithFrame:CGRectMake(0, lblText.bottom, kSCREEN_WIDTH, 120)];
        self.viewImages = viewImages;
        [_viewShopEnv addSubview:self.viewImages];
        
        UIImageView *imageAdd = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 100, 100)];
        imageAdd.image = [UIImage imageNamed:@"img_add_photo"];
        [viewImages addSubview:imageAdd];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEnvImageAddAction:)];
        imageAdd.userInteractionEnabled = YES;
        [imageAdd addGestureRecognizer:tap];
        
        _viewShopEnv.height = self.viewImages.bottom+20;
    }
    return _viewShopEnv;
}

// 完成
-(UIButton *)btnDone{
    if (!_btnDone) {
        _btnDone = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"完成" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnDone.layer.cornerRadius = 24;
        _btnDone.backgroundColor = RGBMAIN;
        
        [_btnDone addTarget:self action:@selector(editDoneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDone;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"编辑门店信息" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
