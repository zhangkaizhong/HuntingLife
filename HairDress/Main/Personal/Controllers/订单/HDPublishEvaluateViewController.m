//
//  HDPublishEvaluateViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/31.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPublishEvaluateViewController.h"
#import "HDEvaOrderDoneViewController.h"

#import "ACMediaPickerManager.h"
#import "DateTimePickerView.h"
#import "FGUploadImageManager.h"

#import "HDShopEditChooseModel.h"

@interface HDPublishEvaluateViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,strong) UIView *viewScore;//评分视图
@property (nonatomic,strong) UIView *viewFeature;//发型师特点视图

@property (nonatomic,strong) UIView *viewImagesContent;//上传图片
@property (nonatomic,strong) UIView *viewImages;//图片视图

//@property (nonatomic,strong) NSMutableArray *arrImages;// 图片数组
@property (nonatomic,strong) NSMutableArray *arrFeaturesMenu;// 特点
///需要先定义一个属性，防止临时变量被释放
@property (nonatomic, strong) ACMediaPickerManager *mgr;

@property (nonatomic,weak) UILabel *lblTotal;//总体
@property (nonatomic,copy) NSString *totalScore;//总体评分
@property (nonatomic,weak) UILabel *lblEnv;//环境
@property (nonatomic,copy) NSString *envScore;//环境评分
@property (nonatomic,weak) UILabel *lblService;//服务
@property (nonatomic,copy) NSString *serviceScore;//服务评分

@property (nonatomic,strong) NSMutableArray *arrCutterLabels;//发型师标签
@property (nonatomic,strong) NSMutableArray *arrImageUrls;//待上传图片URL

@property (nonatomic,strong) UIView *viewEvaContent;
@property (nonatomic,weak) UITextView *textEvaContent;//评论内容
@property (nonatomic,weak) UILabel *lblPlaceholder;

@end

@implementation HDPublishEvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrFeaturesMenu = [NSMutableArray new];
    self.arrImageUrls = [NSMutableArray new];
    self.arrCutterLabels = [NSMutableArray new];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:nil];
    
    [self getCutterLabelsRequest];
}

#pragma mark -- delegate / action

- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)navRightClicked{
    [self publishEvaRequest];
}

#pragma mark -- 请求发型师标签数据
-(void)getCutterLabelsRequest{
    [MHNetworkManager postReqeustWithURL:URL_ConfigList params:@{@"configType":@"tony_label"} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if([returnData[@"respCode"] integerValue] == 200){
            if ([returnData[@"data"] isKindOfClass:[NSArray class]]) {
                NSArray *arr = [HDShopEditChooseModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
                for (HDShopEditChooseModel *mode in arr) {
                    mode.select = @"0";
                    [self.arrFeaturesMenu addObject:mode];
                }
                
                [self.view addSubview:self.mainScrollView];
            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- 上传图片请求
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

#pragma mark -- 发表评价请求
-(void)publishEvaRequest{
    for (HDShopEditChooseModel *models in self.arrFeaturesMenu) {
        if ([models.select isEqualToString:@"1"]) {
            [self.arrCutterLabels addObject:models.configName];
        }
    }
    
    if ([HDToolHelper StringIsNullOrEmpty:self.totalScore]) {
        [SVHUDHelper showWorningMsg:@"请选择总体评分" timeInt:1];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.envScore]) {
        [SVHUDHelper showWorningMsg:@"请选择环境评分" timeInt:1];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.serviceScore]) {
        [SVHUDHelper showWorningMsg:@"请选择服务评分" timeInt:1];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.textEvaContent.text]) {
        [SVHUDHelper showWorningMsg:@"评价内容不能为空" timeInt:1];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.order_id forKey:@"orderId"];
    [params setValue:self.totalScore forKey:@"totalStars"];
    [params setValue:self.serviceScore forKey:@"serviceStars"];
    [params setValue:self.envScore forKey:@"environmentStars"];
    [params setValue:self.textEvaContent.text forKey:@"content"];
    if (self.arrImageUrls.count>0) {
        [params setValue:self.arrImageUrls forKey:@"imgList"];
    }
    if (self.arrCutterLabels.count>0) {
        [params setValue:self.arrCutterLabels forKey:@"labels"];
    }
    
    [MHNetworkManager postReqeustWithURL:URL_EvaAddEvaluate params:params successBlock:^(NSDictionary *returnData) {
        [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(publishEvaDelegate)]) {
                [self.delegate publishEvaDelegate];
            }
            HDEvaOrderDoneViewController *doneVC = [HDEvaOrderDoneViewController new];
            [self.navigationController pushViewController:doneVC animated:YES];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//评分
-(void)btnSelectScore:(UIButton *)sender{
    NSInteger viewTotalTag = 100;
    NSInteger viewEnvTag = 200;
    NSInteger viewServiceTag = 300;
    
    // 总体
    if (sender.tag-viewTotalTag <5) {
        UIButton *btn0 = (UIButton *)[_viewScore viewWithTag:viewTotalTag];;
        UIButton *btn1 = (UIButton *)[_viewScore viewWithTag:viewTotalTag+1];
        UIButton *btn2 = (UIButton *)[_viewScore viewWithTag:viewTotalTag+2];
        UIButton *btn3 = (UIButton *)[_viewScore viewWithTag:viewTotalTag+3];
        UIButton *btn4 = (UIButton *)[_viewScore viewWithTag:viewTotalTag+4];
        
        if (sender.tag -viewTotalTag == 0) {
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            
            self.lblTotal.text = @"很失望";
            self.totalScore = @"1";
        }
        if (sender.tag -viewTotalTag == 1) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblTotal.text = @"不满意";
            self.totalScore = @"2";
        }
        if (sender.tag -viewTotalTag == 2) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            
            self.lblTotal.text = @"一般";
            self.totalScore = @"3";
        }
        if (sender.tag -viewTotalTag == 3) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblTotal.text = @"满意";
            self.totalScore = @"4";
        }
        if (sender.tag -viewTotalTag == 4) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            
            self.lblTotal.text = @"超级满意";
            self.totalScore = @"5";
        }
    }
    // 环境
    if (sender.tag-viewEnvTag <5) {
        UIButton *btn0 = (UIButton *)[_viewScore viewWithTag:viewEnvTag];;
        UIButton *btn1 = (UIButton *)[_viewScore viewWithTag:viewEnvTag+1];
        UIButton *btn2 = (UIButton *)[_viewScore viewWithTag:viewEnvTag+2];
        UIButton *btn3 = (UIButton *)[_viewScore viewWithTag:viewEnvTag+3];
        UIButton *btn4 = (UIButton *)[_viewScore viewWithTag:viewEnvTag+4];
        
        if (sender.tag -viewEnvTag == 0) {
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblEnv.text = @"很失望";
            self.envScore = @"1";
        }
        if (sender.tag -viewEnvTag == 1) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblEnv.text = @"不满意";
            self.envScore = @"2";
        }
        if (sender.tag -viewEnvTag == 2) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblEnv.text = @"一般";
            self.envScore = @"3";
        }
        if (sender.tag -viewEnvTag == 3) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblEnv.text = @"满意";
            self.envScore = @"4";
        }
        if (sender.tag -viewEnvTag == 4) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            self.lblEnv.text = @"超级满意";
            self.envScore = @"5";
        }
    }
    // 服务
    if (sender.tag-viewServiceTag <5) {
        UIButton *btn0 = (UIButton *)[_viewScore viewWithTag:viewServiceTag];;
        UIButton *btn1 = (UIButton *)[_viewScore viewWithTag:viewServiceTag+1];
        UIButton *btn2 = (UIButton *)[_viewScore viewWithTag:viewServiceTag+2];
        UIButton *btn3 = (UIButton *)[_viewScore viewWithTag:viewServiceTag+3];
        UIButton *btn4 = (UIButton *)[_viewScore viewWithTag:viewServiceTag+4];
        
        if (sender.tag -viewServiceTag == 0) {
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblService.text = @"很失望";
            self.serviceScore = @"1";
        }
        if (sender.tag -viewServiceTag == 1) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblService.text = @"不满意";
            self.serviceScore = @"2";
        }
        if (sender.tag -viewServiceTag == 2) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblService.text = @"一般";
            self.serviceScore = @"3";
        }
        if (sender.tag -viewServiceTag == 3) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m"] forState:UIControlStateNormal];
            self.lblService.text = @"满意";
            self.serviceScore = @"4";
        }
        if (sender.tag -viewServiceTag == 4) {
            
            [btn0 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn1 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn2 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn3 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            [btn4 setImage:[UIImage imageNamed:@"evaluation_m_selected"] forState:UIControlStateNormal];
            self.lblService.text = @"超级满意";
            self.serviceScore = @"5";
        }
    }
}

// 评论内容
- (void)textDidChange{
    // 有文字就隐藏
    if (self.textEvaContent.text.length == 0) {
        self.lblPlaceholder.hidden = NO;
    }else{
        self.lblPlaceholder.hidden = YES;
    }
}

// 添加评论图片
-(void)tapImageAddAction:(UIGestureRecognizer *)sender{
    if (self.arrImageUrls.count >= 9) {
        [SVHUDHelper showDarkWarningMsg:@"图片最多添加9张"];
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
        
        UIImageView *imageInfo = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16+i*(100+16), width_img, width_img)];
        if (i==self.arrImageUrls.count) {
            imageInfo.image = [UIImage imageNamed:@"add_photo"];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAddAction:)];
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
            imageInfo.y = 16;
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
        _viewImagesContent.height = _viewImages.bottom+16;
    }
    _viewFeature.y = _viewImagesContent.bottom +8;
    _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewFeature.bottom);
}

// 选择发型师特点
-(void)tapFeatureAction:(UIGestureRecognizer *)sender{

    UILabel *lbl = (UILabel *)sender.view;
    
    NSInteger index = sender.view.tag - 100;
    HDShopEditChooseModel *mode = self.arrFeaturesMenu[index];
    if ([mode.select isEqualToString:@"0"]) {
        mode.select = @"1";
        
        lbl.backgroundColor = RGBAlpha(245, 34, 45, 0.08);
        lbl.textColor = RGBMAIN;
    }else{
        mode.select = @"0";
        
        lbl.backgroundColor = RGBCOLOR(243, 243, 243);
        lbl.textColor = RGBTEXT;
    }
    
}

#pragma mark ================== 加载控件 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        [_mainScrollView addSubview:self.viewScore];
        [_mainScrollView addSubview:self.viewEvaContent];
        [_mainScrollView addSubview:self.viewImagesContent];
        [_mainScrollView addSubview:self.viewFeature];

        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewFeature.bottom);
    }
    return _mainScrollView;
}

//评分
-(UIView *)viewScore{
    if (!_viewScore) {
        _viewScore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 146)];
        _viewScore.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblScore = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 14) title:@"门店评价" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewScore addSubview:lblScore];
        
        UIView *viewTotal = [self createScoreBtns:CGRectMake(16, lblScore.bottom+24, 100, 20) viewTag:100 scoreTitle:@"总体"];
        [_viewScore addSubview: viewTotal];
        UIView *viewEnv = [self createScoreBtns:CGRectMake(16, viewTotal.bottom+10, 100, 20) viewTag:200 scoreTitle:@"环境"];
        [_viewScore addSubview: viewEnv];
        UIView *viewService = [self createScoreBtns:CGRectMake(16, viewEnv.bottom+10, 100, 20) viewTag:300 scoreTitle:@"服务"];
        [_viewScore addSubview: viewService];
        
        UILabel *lblTotal = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(viewTotal.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(viewTotal.frame)-5-16, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        [_viewScore addSubview:lblTotal];
        lblTotal.centerY = viewTotal.centerY;
        self.lblTotal = lblTotal;
        
        UILabel *lblEnv = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(viewEnv.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(viewEnv.frame)-5-16, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        [_viewScore addSubview:lblEnv];
        lblEnv.centerY = viewEnv.centerY;
        self.lblEnv = lblEnv;
        
        UILabel *lblService = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(viewService.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(viewService.frame)-5-16, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        [_viewScore addSubview:lblService];
        lblService.centerY = viewService.centerY;
        self.lblService = lblService;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 145, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewScore addSubview:line];
    }
    return _viewScore;
}

//评论内容
-(UIView *)viewEvaContent{
    if (!_viewEvaContent) {
        _viewEvaContent = [[UIView alloc] initWithFrame:CGRectMake(0, _viewScore.bottom, kSCREEN_WIDTH, 88)];
        _viewEvaContent.backgroundColor = [UIColor whiteColor];
        
        
        UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(10, 7, _viewEvaContent.width-32, 64)];
        [_viewEvaContent addSubview:txt];
        self.textEvaContent = txt;
        
        UILabel *placelbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, _viewEvaContent.width-32, 14) title:@"您的每一句悉心评价对其他用户都是很重要的参考哦~" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblPlaceholder = placelbl;
        [_viewEvaContent addSubview:self.lblPlaceholder];
        
    }
    return _viewEvaContent;
}

// 评论图片
-(UIView *)viewImagesContent{
    if (!_viewImagesContent) {
        _viewImagesContent = [[UIView alloc] initWithFrame:CGRectMake(0, _viewEvaContent.bottom, kSCREEN_WIDTH, 200)];
        _viewImagesContent.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 8, kSCREEN_WIDTH-32, 12) title:@"上传图片" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewImagesContent addSubview:lblText];
        
        
        // 图片
        UIView *viewImages = [[UIView alloc] initWithFrame:CGRectMake(0, lblText.bottom, kSCREEN_WIDTH, 120)];
        self.viewImages = viewImages;
        [_viewImagesContent addSubview:self.viewImages];
        
        UIImageView *imageAdd = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 100, 100)];
        imageAdd.image = [UIImage imageNamed:@"add_photo"];
        [viewImages addSubview:imageAdd];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAddAction:)];
        imageAdd.userInteractionEnabled = YES;
        [imageAdd addGestureRecognizer:tap];
        
        _viewImagesContent.height = self.viewImages.bottom+16;
    }
    return _viewImagesContent;
}

// 发型师特点视图
-(UIView *)viewFeature{
    if (!_viewFeature) {
        _viewFeature = [[UIView alloc] initWithFrame:CGRectMake(0, _viewImagesContent.bottom+8, kSCREEN_WIDTH, 100)];
        _viewFeature.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 14) title:@"发型师特点" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewFeature addSubview:lblText];
        
        for (int i=0; i<self.arrFeaturesMenu.count; i++) {
            HDShopEditChooseModel *model = self.arrFeaturesMenu[i];
            UILabel *lblMenu = [[UILabel alloc] init];
            lblMenu.width = kSCREEN_WIDTH - 52;
            lblMenu.text = model.configName;
            lblMenu.backgroundColor = RGBCOLOR(243, 243, 243);
            lblMenu.textColor = RGBTEXT;
            lblMenu.layer.cornerRadius = 13;
            lblMenu.layer.masksToBounds = YES;
            lblMenu.font = [UIFont systemFontOfSize:12];
            lblMenu.textAlignment = NSTextAlignmentCenter;
            lblMenu.numberOfLines = 0;
            [lblMenu sizeToFit];
            
            lblMenu.width = lblMenu.width + 20;
            if (lblMenu.height < 26) {
                lblMenu.height = 26;
            }
            else{
                lblMenu.height = lblMenu.height +5;
            }
            lblMenu.tag = 100+i;
            
            UILabel *lblLast = (UILabel *)[_viewFeature viewWithTag:100+i-1];
            
            // 添加点击手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFeatureAction:)];
            lblMenu.userInteractionEnabled = YES;
            [lblMenu addGestureRecognizer:tap];
            
            if (i == 0) {
                lblMenu.x = 16;
                lblMenu.y = lblText.bottom+24;
            }else{
                lblMenu.x = CGRectGetMaxX(lblLast.frame)+16;
                if (CGRectGetMaxX(lblMenu.frame)+16 > kSCREEN_WIDTH) {
                    lblMenu.x = 16;
                    lblMenu.y = CGRectGetMaxY(lblLast.frame)+12;
                }else{
                    lblMenu.y = lblLast.y;
                }
            }
            
            [_viewFeature addSubview:lblMenu];
            _viewFeature.height = lblMenu.bottom+24;
        }
    }
    return _viewFeature;
}

//导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"发表评价" bgColor:RGBMAIN backBtn:YES rightBtn:@"发表" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}


//创建评分视图
-(UIView *)createScoreBtns:(CGRect)frame viewTag:(NSInteger)tagView scoreTitle:(NSString *)title{
    UIView *viewBtns = [[UIView alloc] initWithFrame:frame];
    
    UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 100, viewBtns.height) title:title bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lbl.height = viewBtns.height;
    [viewBtns addSubview:lbl];
    
    
    for (int i=0; i<5; i++) {
        UIButton *btnImage= [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(lbl.frame)+24+i*(20+12), 0, 20, viewBtns.height) btnTitle:@"" btnImage:@"evaluation_m" titleColor:[UIColor clearColor] titleFont:0];
        btnImage.tag = tagView+i;
        [viewBtns addSubview:btnImage];
        [btnImage addTarget:self action:@selector(btnSelectScore:) forControlEvents:UIControlEventTouchUpInside];
        
        viewBtns.width = CGRectGetMaxX(btnImage.frame);
    }
    
    return viewBtns;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DTLog(@"%s",__FUNCTION__);
}

@end
