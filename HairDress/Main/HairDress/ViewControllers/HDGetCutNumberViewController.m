//
//  HDGetCutNumberViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/24.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDGetCutNumberViewController.h"
#import "HDGetNumSuccessViewController.h"

#import "HDChooseCutTimeViewController.h"

@interface HDGetCutNumberViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,strong) NSMutableArray *arrData;
@property (nonatomic,strong) NSDictionary *dicCutter;

@property (nonatomic,strong) UIView *cutterView;
@property (nonatomic,strong) UIImageView *cutterHeaderImage;
@property (nonatomic,strong) UILabel *lblCutterName;
@property (nonatomic,strong) UILabel *lblWaitNumber;

@property (nonatomic,strong) UIView *comfirnGeNoView;
@property (nonatomic,strong) UILabel *lblComfirnPrice;

@property (nonatomic,strong) NSDictionary *dicSelectService;

@property (nonatomic,assign) NSInteger selectIndex;

@end

@implementation HDGetCutNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray new];
    
    [self.view addSubview:self.navView];
    
    [self getNumRequest];
}

// 预约时段
-(void)comfirnGetAction{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    if (!self.dicSelectService) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:@"请选择服务项目"];
        return;
    }
    HDChooseCutTimeViewController *chooseVC = [HDChooseCutTimeViewController new];
    chooseVC.storeID = self.dicCutter[@"storeId"];
    chooseVC.dicSelectService = self.dicSelectService;
    chooseVC.cutterID = self.cutter_id;
    [self.navigationController pushViewController:chooseVC animated:YES];
}


#pragma mark ================== 请求数据 =====================
//取号页
-(void)getNumRequest{
    NSDictionary *params = @{
        @"tonyId":self.cutter_id
    };
    [MHNetworkManager postReqeustWithURL:URL_StoreTakeNum params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"URL_StoreTakeNum:%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.dicCutter = returnData[@"data"];
            [self.arrData addObjectsFromArray:self.dicCutter[@"itemVoList"]];
            
            [self.view addSubview:self.mainScrollView];
            [self.view addSubview:self.comfirnGeNoView];
            
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- delegate \ action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 选择服务项
-(void)tapViewContentAction:(UIGestureRecognizer *)gesture{
    NSInteger n = gesture.view.tag - 1000;
    
    for (int i = 0; i<self.arrData.count; i++) {
        if (1000+i != gesture.view.tag) {
            UIView *viewContent = (UIView *)[self.mainScrollView viewWithTag:1000+i];
            UIImageView *selectImage = (UIImageView *)[viewContent viewWithTag:200+i];
            selectImage.hidden = YES;
        }
    }
    if (self.selectIndex != n) {
        UIView *viewContent = (UIView *)[self.mainScrollView viewWithTag:gesture.view.tag];
        UIImageView *selectImage = (UIImageView *)[viewContent viewWithTag:200+n];
        selectImage.hidden = NO;
        
        self.dicSelectService = self.arrData[n];
        
        self.lblComfirnPrice.attributedText =  [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[self.arrData[n][@"amount"] floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
    }
    else{
        UIView *viewContent = (UIView *)[self.mainScrollView viewWithTag:gesture.view.tag];
        UIImageView *selectImage = (UIImageView *)[viewContent viewWithTag:200+n];
        if (selectImage.hidden == YES) {
            selectImage.hidden = NO;
            
            self.dicSelectService = self.arrData[n];
            
            self.lblComfirnPrice.attributedText =  [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[self.arrData[n][@"amount"] floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
            
        }else{
            selectImage.hidden = YES;
            self.dicSelectService = nil;
            self.lblComfirnPrice.text = @"请选择服务项目";
            self.lblComfirnPrice.textColor = RGBTEXTINFO;
        }
    }
    
    self.selectIndex = n;
    
}

#pragma mark -- 加载控件

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-KTarbarHeight)];
        _mainScrollView.backgroundColor = RGBBG;
        
        [_mainScrollView addSubview:self.cutterView];
        
        UIView *viewService = [[UIView alloc] initWithFrame:CGRectMake(0, _cutterView.bottom, kSCREEN_WIDTH, 38)];
        viewService.backgroundColor = RGBBG;
        [_mainScrollView addSubview:viewService];
        UILabel *lblService = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 14) title:@"服务项" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        lblService.centerY = viewService.height/2;
        lblService.centerX = viewService.width/2;
        [viewService addSubview:lblService];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(lblService.x-66-16, 0, 66, 0.5)];
        line1.backgroundColor = RGBLIGHT_TEXTINFO;
        line1.centerY = lblService.centerY;
        [viewService addSubview:line1];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblService.frame)+16, 0, 66, 0.5)];
        line2.backgroundColor = RGBLIGHT_TEXTINFO;
        line2.centerY = lblService.centerY;
        [viewService addSubview:line2];
        
        
        for (int i=0; i<self.arrData.count; i++) {
            UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, i*98+viewService.bottom, kSCREEN_WIDTH, 98)];
            viewContent.tag = 1000+i;
            viewContent.backgroundColor = [UIColor whiteColor];
            
            UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH, 14) title:self.arrData[i][@"linkName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            [viewContent addSubview:lblTitle];
            
            UILabel *lblContent = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblTitle.bottom+8, kSCREEN_WIDTH-16-119, viewContent.bottom-20) title:@"" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
            
            
            if (![HDToolHelper StringIsNullOrEmpty:self.arrData[i][@"configDesc"]]) {
                lblContent.text = self.arrData[i][@"configDesc"];
                lblContent.numberOfLines = 0;
                [lblContent sizeToFit];
                [viewContent addSubview:lblContent];
            }else{
                lblTitle.centerY = viewContent.height/2;
            }
            
            UILabel *lblPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 44, 100, 14) title:[NSString stringWithFormat:@"¥%.2f",[self.arrData[i][@"amount"] floatValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
            [lblPrice sizeToFit];
            lblPrice.x = kSCREEN_WIDTH-56-lblPrice.width;
            [viewContent addSubview:lblPrice];
            
            UIImageView *imgSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_ic_selected"]];
            imgSelect.centerY = lblPrice.centerY;
            imgSelect.x = kSCREEN_WIDTH-19-17;
            [viewContent addSubview:imgSelect];
            imgSelect.tag = 200+i;
            imgSelect.hidden = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewContentAction:)];
            viewContent.userInteractionEnabled = YES;
            [viewContent addGestureRecognizer:tap];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,97, kSCREEN_WIDTH, 1)];
            line.backgroundColor = RGBBG;
            [viewContent addSubview:line];
            
            
            [_mainScrollView addSubview:viewContent];
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, viewContent.bottom);
        }
    }
    return _mainScrollView;
}

-(UIView *)cutterView{
    if (!_cutterView) {
        _cutterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
        _cutterView.backgroundColor = [UIColor whiteColor];
        
        [_cutterView addSubview:self.cutterHeaderImage];
        [_cutterView addSubview:self.lblCutterName];
        [_cutterView addSubview:self.lblWaitNumber];
    }
    return _cutterView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"取号" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIImageView *)cutterHeaderImage{
    if (!_cutterHeaderImage) {
        _cutterHeaderImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 60, 60)];
        _cutterHeaderImage.layer.cornerRadius = 4;
        _cutterHeaderImage.layer.masksToBounds = YES;
        
        if (self.dicCutter) {
            [_cutterHeaderImage sd_setImageWithURL:[NSURL URLWithString:self.dicCutter[@"headImg"]] placeholderImage:[UIImage imageNamed:@"getnumber_avatar"]];
        }
    }
    return _cutterHeaderImage;
}

-(UILabel *)lblCutterName{
    if (!_lblCutterName) {
        _lblCutterName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_cutterHeaderImage.frame)+12, 28, kSCREEN_WIDTH-CGRectGetMaxX(_cutterHeaderImage.frame)-12-16, 20) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:20 textAlignment:NSTextAlignmentLeft isFit:NO];
        if (self.dicCutter) {
            _lblCutterName.text = self.dicCutter[@"userName"];
        }
        _lblCutterName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 20);
    }
    return _lblCutterName;
}

-(UILabel *)lblWaitNumber{
    if (!_lblWaitNumber) {
        _lblWaitNumber = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_cutterHeaderImage.frame)+12, _lblCutterName.bottom+18, kSCREEN_WIDTH-CGRectGetMaxX(_cutterHeaderImage.frame)-12-16, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        if (self.dicCutter) {
            _lblWaitNumber.text = [NSString stringWithFormat:@"前面有%@人，约等待%@分钟",self.dicCutter[@"queueNumber"],self.dicCutter[@"waitTime"]];
        }
    }
    return _lblWaitNumber;
}

// 确认取号
-(UIView *)comfirnGeNoView{
    if (!_comfirnGeNoView) {
        _comfirnGeNoView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-49*SCALE, kSCREEN_WIDTH, 49*SCALE)];
        
        [_comfirnGeNoView addSubview:self.lblComfirnPrice];
        
        UIButton *btnComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16*SCALE-148*SCALE, 0, 148*SCALE, 32*SCALE) btnTitle:@"预约时段" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        btnComfirn.backgroundColor = RGBMAIN;
        btnComfirn.centerY = _comfirnGeNoView.height/2;
        btnComfirn.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
        btnComfirn.layer.cornerRadius = 6;
        [_comfirnGeNoView addSubview:btnComfirn];
        [btnComfirn addTarget:self action:@selector(comfirnGetAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.lblComfirnPrice.centerY = btnComfirn.centerY;
    }
    return _comfirnGeNoView;
}

// 价格
-(UILabel *)lblComfirnPrice{
    if (!_lblComfirnPrice) {
        _lblComfirnPrice = [[UILabel alloc] init];
        _lblComfirnPrice.frame = CGRectMake(16,14,150,20);
        _lblComfirnPrice.text = @"请选择服务项目";
        _lblComfirnPrice.textColor = RGBTEXTINFO;
        _lblComfirnPrice.font = [UIFont systemFontOfSize:14];
    }
    return _lblComfirnPrice;
}

@end
