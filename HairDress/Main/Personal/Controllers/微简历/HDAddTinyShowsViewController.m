//
//  HDCreateHairProViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDAddTinyShowsViewController.h"

#import "ACMediaPickerManager.h"

@interface HDAddTinyShowsViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView * navView;  // 导航栏
@property (nonatomic,strong) UIScrollView * mainScrollView;  // 主视图
@property (nonatomic,strong) HDTextFeild * txtShowName;  // 门店名称
@property (nonatomic,strong) UIButton * btnComfirn;  // 确定

@property (nonatomic,weak) UILabel * lblHair;  //
@property (nonatomic,strong) UIView * viewWarn;  //
@property (nonatomic,strong) UIView * imagesView;  //
@property (nonatomic,strong) NSMutableArray *arrImages;// 图片数组
///需要先定义一个属性，防止临时变量被释放
@property (nonatomic, strong) ACMediaPickerManager *mgr;

@property (nonatomic,strong) UIImageView *addImageView;
@property (nonatomic,copy) NSString *imageUrl;

@end

@implementation HDAddTinyShowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrImages = [NSMutableArray new];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.btnComfirn];
}

#pragma mark ================== delegate /action =====================

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 确定
-(void)comfirnAction{
    [self addWorkShowRequest];
}

// 点击添加图片
-(void)tapAddAction:(UIGestureRecognizer *)sender{
    [self.txtShowName resignFirstResponder];
    
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
    if (self.arrImages.count > 0) {
        self.mgr.seletedMediaArray = self.arrImages;
    }
    __weak typeof(self) weakSelf = self;
    self.mgr.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {
        [weakSelf.arrImages removeAllObjects];
        if (list.count>0) {
            [weakSelf.arrImages addObjectsFromArray:list];
            ACMediaModel *model = list[0];
            [weakSelf uploadImageFile:model.image];
//            [weakSelf createImageView];
        }
    };
    [self.mgr picker];
        
}

#pragma mark -- 上传图片
-(void)uploadImageFile:(UIImage *)image{
    
    [MHNetworkManager uploadFileWithURL:URL_UploadFile params:@{} imageFile:image successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.addImageView.image = image;
            self.imageUrl = returnData[@"data"];
        }else{
            [SVHUDHelper showInfoWithTimestamp:0.5 msg:@"图片上传失败"];
        }
    } failureBlock:^(NSError *error) {
            
    } showHUD:NO];
}

#pragma mark ================== 创建作品请求 =====================
-(void)addWorkShowRequest{
    if ([self.txtShowName.text isEqualToString:@""]) {
        [SVHUDHelper showInfoWithTimestamp:0.5 msg:@"请添加作品名称"];
        return;
    }
    if ([HDToolHelper StringIsNullOrEmpty:self.imageUrl]) {
        [SVHUDHelper showInfoWithTimestamp:0.5 msg:@"请添加作品照片"];
        return;
    }
    NSDictionary *params = @{
        @"tonyId":[HDUserDefaultMethods getData:@"userId"],
        @"worksList":@[
                @{
                    @"imgUrl":self.imageUrl,
                    @"worksName":self.txtShowName.text
                }
        ]
    };
    [MHNetworkManager postReqeustWithURL:URL_TonyAddWorkShows params:params successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            [SVHUDHelper showWorningMsg:@"添加成功" timeInt:1];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshNewShowsList)]) {
                    [self.delegate refreshNewShowsList];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

// 创建图片展示视图
-(void)createImageView{
    
    for(UIView *view in [_imagesView subviews]){
        [view removeFromSuperview];
    }
    for (int i =0 ; i<self.arrImages.count; i++) {
        CGFloat width_img = (kSCREEN_WIDTH-32-43)/3;
        
        UIImageView *imageInfo = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16+i*(100+16), width_img, width_img)];
        if (i==self.arrImages.count) {
            imageInfo.image = [UIImage imageNamed:@"add_photo"];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddAction:)];
            imageInfo.userInteractionEnabled = YES;
            [imageInfo addGestureRecognizer:tap];
        }else{
            // 选中的视图
            ACMediaModel *model = self.arrImages[i];
            imageInfo.image = model.image;
        }
        
        
        imageInfo.tag = 100 + i;
        
        UIView *imageLast = (UIView *)[_imagesView viewWithTag:100+i-1];
        
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
        
        [_imagesView addSubview:imageInfo];
        _imagesView.height = imageInfo.bottom+16;
    }
    _viewWarn.y = _imagesView.bottom;
    _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewWarn.bottom+32+32+48);
}

#pragma mark ================== 加载视图 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        [self createHeaderView:CGRectMake(0, 0, kSCREEN_WIDTH, 160)];
        
        [_mainScrollView addSubview:self.imagesView];
        [_mainScrollView addSubview:self.viewWarn];
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewWarn.bottom+32+32+48);
    }
    return _mainScrollView;
}

// 创建cellView
-(UIView *)createHeaderView:(CGRect)frame{
    // 头部视图
    UIView *header = [[UIView alloc] initWithFrame:frame];
    [_mainScrollView addSubview:header];
    header.backgroundColor = [UIColor whiteColor];
    
    UILabel *lblShowName = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"作品名称" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [header addSubview:lblShowName];
    
    // 作品名称输入框
    self.txtShowName = [[HDTextFeild alloc] initWithFrame:CGRectMake(16, lblShowName.bottom+8, kSCREEN_WIDTH-32, 14)];
    _txtShowName.placeholder = @"请输入作品名称";
    _txtShowName.textAlignment = NSTextAlignmentLeft;
    _txtShowName.textColor = RGBTEXT;
    _txtShowName.font = [UIFont systemFontOfSize:14];
    [header addSubview:self.txtShowName];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, _txtShowName.bottom+8, kSCREEN_WIDTH, 8)];
    line1.backgroundColor = RGBLINE;
    [header addSubview:line1];
    
    UILabel *lblHair = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, line1.bottom+20, 100, 14) title:@"作品照片" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [header addSubview:lblHair];
    self.lblHair = lblHair;
    
    header.height = lblHair.bottom;
    
    return header;
}

// 图片视图
-(UIView *)imagesView{
    if (!_imagesView) {
        _imagesView = [[UIView alloc] initWithFrame:CGRectMake(0, _lblHair.bottom, kSCREEN_WIDTH, 200)];
        _imagesView.backgroundColor = [UIColor whiteColor];
        
        
        UIImageView *imageAdd = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, (kSCREEN_WIDTH-32-30)/3, (kSCREEN_WIDTH-32-30)/3)];
        imageAdd.image = [UIImage imageNamed:@"add_photo"];
        [_imagesView addSubview:imageAdd];
        self.addImageView = imageAdd;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddAction:)];
        imageAdd.userInteractionEnabled = YES;
        [imageAdd addGestureRecognizer:tap];
        
        _imagesView.height = imageAdd.bottom+20;
    }
    return _imagesView;
}

-(UIView *)viewWarn{
    if (!_viewWarn) {
        UIView *viewWarn = [[UIView alloc] initWithFrame:CGRectMake(0, _imagesView.bottom, kSCREEN_WIDTH, 30)];
        viewWarn.backgroundColor = [UIColor clearColor];
        _viewWarn = viewWarn;
        UILabel *lblWarn = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 20) title:@"点击上传作品照片" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewWarn addSubview:lblWarn];
    }
    return _viewWarn;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"添加作品" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
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
