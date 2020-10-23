//
//  HDTaskCompletingViewController.m
//  HairDress
//
//  Created by Apple on 2020/2/10.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaskCompletingViewController.h"

#import "ACMediaPickerManager.h"
#import "HDMyTaskDetailInfoModel.h"

#import "HDMyTaskListViewController.h"

@interface HDTaskCompletingViewController ()<navViewDelegate,UIScrollViewDelegate>
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}
@property (nonatomic,strong) HDBaseNavView *navView;
//头部背景图
@property (nonatomic,strong) UIImageView *imageHeadBack;
@property (nonatomic,strong) UIView *buttonView;
@property (nonatomic,strong) UIView *imagesView;
@property (nonatomic,strong) UIView *infoView;
@property (nonatomic,strong) UIView *uploadMsgView;
@property (nonatomic,weak) UITextView *textContent;//评论内容
@property (nonatomic,weak) UILabel *lblPlaceholder;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) ZXLGCDTimer *timer;
@property (nonatomic, strong) ACMediaPickerManager *mgr;

@property (nonatomic,weak) UILabel *lblRetime;

@property (nonatomic,strong) HDMyTaskDetailInfoModel *detailModel;
@property (nonatomic,strong) NSMutableArray *arrImageUrls;
@property (nonatomic,strong) NSMutableArray *arrImages;

@end

//倒计时总秒数
static NSInteger secondsCountDown = 0;

@implementation HDTaskCompletingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    
    self.arrImages = [NSMutableArray new];
    self.arrImageUrls = [NSMutableArray new];
    
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.buttonView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:nil];
    
    [self getTaskDetailScrollData];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DTLog(@"%s",__FUNCTION__);
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//提交审核
-(void)buttonDoneAction{
    if (self.arrImageUrls.count == 0) {
        [SVHUDHelper showDarkWarningMsg:@"请上传任务截图"];
        return;
    }
    if ([self.textContent.text isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"请输入提交信息"];
        return;
    }
    [self uploadCheckRequest];
}

//实现倒计时动作
-(void)countDownAction{
    //倒计时-1
    secondsCountDown--;
    
    if (secondsCountDown <=0) {
        self.lblRetime.text = [NSString stringWithFormat:@"剩余时间 00:00:00"];
        [self.lblRetime sizeToFit];
        self.lblRetime.x = _infoView.width - 12 - self.lblRetime.width;
        return;
    }

    //重新计算 时/分/秒
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",secondsCountDown/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(secondsCountDown%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",secondsCountDown%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    //修改倒计时标签及显示内容
    self.lblRetime.text = [NSString stringWithFormat:@"剩余时间 %@",format_time];

    [self.lblRetime sizeToFit];
    self.lblRetime.x = _infoView.width - 12 - self.lblRetime.width;
}

// 评论内容
- (void)textDidChange{
    // 有文字就隐藏
    if (self.textContent.text.length == 0) {
        self.lblPlaceholder.hidden = NO;
    }else{
        self.lblPlaceholder.hidden = YES;
    }
}

// 添加图片
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
    self.mgr.maxImageSelected = 9;
    if (self.arrImages.count > 0) {
        self.mgr.seletedMediaArray = self.arrImages;
    }
    __weak typeof(self) weakSelf = self;
    self.mgr.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {
        [weakSelf.arrImages removeAllObjects];
        [weakSelf.arrImageUrls removeAllObjects];
        [weakSelf.arrImages addObjectsFromArray:list];
        [weakSelf uploadImageRequest:list];
    };
    [self.mgr picker];
}

// 删除门店环境图片 单删
-(void)btnDelImageAction:(UIButton *)sender{
    NSInteger tag = sender.tag;
    [self.arrImages removeObjectAtIndex:tag-200];
    [self.arrImageUrls removeObjectAtIndex:tag-200];
    [self createImageView];
}

#pragma mark ================== 数据请求 =====================
//任务详情
-(void)getTaskDetailScrollData{
    NSDictionary *params = @{
        @"id":self.memberTaskId
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryUserTaskDetail params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.detailModel = [HDMyTaskDetailInfoModel mj_objectWithKeyValues:returnData[@"data"]];
            
            [weakSelf.mainScrollView addSubview:self.infoView];
            [weakSelf.mainScrollView addSubview:self.imagesView];
            [weakSelf.mainScrollView addSubview:self.uploadMsgView];
            weakSelf.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, weakSelf.uploadMsgView.bottom+16);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//提交审核请求
-(void)uploadCheckRequest{
    NSDictionary *params = @{
        @"finishDesc":self.textContent.text,
        @"imgs":self.arrImageUrls,
        @"memberTaskId":self.memberTaskId
    };
    [MHNetworkManager postReqeustWithURL:URL_TaskSendCheck params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            for (UIViewController *viewCon in [self.navigationController viewControllers]) {
                if ([viewCon isKindOfClass:[HDMyTaskListViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMyTaskList" object:nil];
                    [self.navigationController popToViewController:viewCon animated:YES];
                }
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
        DTLog(@"%@",imageUrls);
        if (isSuccess) {
            [self.arrImageUrls removeAllObjects];
            [self.arrImageUrls addObjectsFromArray:imageUrls];
            [SVHUDHelper showInfoWithTimestamp:1 msg:@"图片上传成功"];
            [self createImageView];
        }
    }];
}

#pragma mark -- delegate datasource
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //当前y轴偏移量
    CGFloat currentOffsetY  = scrollView.contentOffset.y;
    if (currentOffsetY <= NAVHIGHT) {//下拉，隐藏 navView
        _navView.backgroundColor = [RGBMAIN colorWithAlphaComponent:0];
        // 背景拉伸
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        initialFrame.origin.y = - offsetY * 1;
        initialFrame.size.height = defaultViewHeight + offsetY;
        _imageHeadBack.frame = initialFrame;
    }else if(currentOffsetY > NAVHIGHT){//移动过程
        _navView.backgroundColor = [RGBMAIN colorWithAlphaComponent:1];
    }
}

#pragma mark -- UI
//导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"提交审核" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
        _navView.backgroundColor = [UIColor clearColor];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64)];
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        _mainScrollView.delegate = self;
        [_mainScrollView addSubview:self.imageHeadBack];
        
        initialFrame       = _imageHeadBack.frame;
        defaultViewHeight  = initialFrame.size.height;
    }
    return _mainScrollView;
}

//任务信息视图
-(UIView *)infoView{
    if (!_infoView) {
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(12, NAVHIGHT+12, kSCREEN_WIDTH-24, 96)];
        _infoView.layer.borderWidth = 1;
        _infoView.layer.borderColor = RGBCOLOR(245, 245, 245).CGColor;
        _infoView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        _infoView.layer.cornerRadius = 4;
        _infoView.layer.shadowColor = RGBAlpha(0, 0, 0, 0.03).CGColor;
        _infoView.layer.shadowOffset = CGSizeMake(0,6);
        _infoView.layer.shadowOpacity = 1;
        _infoView.layer.shadowRadius = 6;
        
        //任务奖励
        UILabel *lblMoenyText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 24, 100, 12) title:@"可赚" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_infoView addSubview:lblMoenyText];
        
        UILabel *lblMoeny = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblMoenyText.bottom+8, 100, 12) title:[NSString stringWithFormat:@"%.2f",[self.detailModel.taskInfoModel.taskMoney floatValue]] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:28 textAlignment:NSTextAlignmentLeft isFit:YES];
        lblMoeny.height = 28;
        [_infoView addSubview:lblMoeny];
        
        UILabel *lblYuan = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblMoeny.frame)+2, 0, 100, 12) title:@"元" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblYuan.bottom = lblMoeny.bottom-2;
        [_infoView addSubview:lblYuan];
        
        //剩余时间
        UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(_infoView.width-100, 0, 100, 16) title:@"" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblRetime = lblTime;
        self.lblRetime.centerY = _infoView.height/2;
        [_infoView addSubview:lblTime];
        
        secondsCountDown = [self.detailModel.invalidSecond integerValue];
        //设置定时器
        if (!self.timer) {
            self.timer = [[ZXLGCDTimer alloc] initWithTimeInterval:1 target:self selector:@selector(countDownAction) parameter:0];
        }
        //重新计算 时/分/秒
        NSString *str_hour = [NSString stringWithFormat:@"%02ld",secondsCountDown/3600];
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(secondsCountDown%3600)/60];
        NSString *str_second = [NSString stringWithFormat:@"%02ld",secondsCountDown%60];
        NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
        //修改倒计时标签及显示内容
        self.lblRetime.text = [NSString stringWithFormat:@"剩余时间 %@",format_time];
        
        [self.lblRetime sizeToFit];
        self.lblRetime.x = _infoView.width - 12 - self.lblRetime.width;
    }
    return _infoView;
}

-(UIView *)imagesView{
    if (!_imagesView) {
        _imagesView = [[UIView alloc] initWithFrame:CGRectMake(0, _infoView.bottom+20, kSCREEN_WIDTH, 100)];
        
        UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, 0, kSCREEN_WIDTH-24, 16) title:@"提交信息" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_imagesView addSubview:lblTitle];
        
        UILabel *lblDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, lblTitle.bottom+12, kSCREEN_WIDTH-24, 20) title:@"完成实名认证并截图提交" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_imagesView addSubview:lblDesc];
        
        UIImageView *imageAdd = [[UIImageView alloc] initWithFrame:CGRectMake(12, lblDesc.bottom+6, 100, 100)];
        imageAdd.image = [UIImage imageNamed:@"add_photo"];
        [_imagesView addSubview:imageAdd];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAddAction:)];
        imageAdd.userInteractionEnabled = YES;
        [imageAdd addGestureRecognizer:tap];
        
        _imagesView.height = imageAdd.bottom;
    }
    return _imagesView;
}

//提交文字信息视图
-(UIView *)uploadMsgView{
    if (!_uploadMsgView) {
        _uploadMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, _imagesView.bottom+20, kSCREEN_WIDTH, 100)];
        
        UILabel *lblImgText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, 0, kSCREEN_WIDTH-24, 16) title:@"示例图片" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_uploadMsgView addSubview:lblImgText];
        
        UIImageView *imageExam = [[UIImageView alloc] initWithFrame:CGRectMake(12, lblImgText.bottom+12, (kSCREEN_WIDTH-32-24)/3, (kSCREEN_WIDTH-32-24)/3)];
        imageExam.image = [UIImage imageNamed:@"ima_invite"];
        [_uploadMsgView addSubview:imageExam];
        
        UILabel *lblImgDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, imageExam.bottom+20, kSCREEN_WIDTH-24, 16) title:@"*点击后会调起手机浏览器打开，在任务过程中如遇任何问题可切换到本应用，对照任务步骤进行操作" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblImgDesc.numberOfLines = 0;
        [lblImgDesc sizeToFit];
        [_uploadMsgView addSubview:lblImgDesc];
        
        UILabel *lblInfoText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, lblImgDesc.bottom+20, kSCREEN_WIDTH-24, 16) title:@"提交信息" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_uploadMsgView addSubview:lblInfoText];
        
        UILabel *lblInfoDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, lblInfoText.bottom+12, kSCREEN_WIDTH-24, 20) title:@"提交注册的手机号和昵称" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_uploadMsgView addSubview:lblInfoDesc];
        
        UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(12, lblInfoDesc.bottom+6, kSCREEN_WIDTH-24, 160)];
        txt.backgroundColor = RGBCOLOR(246, 246, 246);
        [_uploadMsgView addSubview:txt];
        self.textContent = txt;
        
        UILabel *placelbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(18, lblInfoDesc.bottom+14, kSCREEN_WIDTH-32, 14) title:@"请根据要求输入相关信息" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblPlaceholder = placelbl;
        [_uploadMsgView addSubview:self.lblPlaceholder];
        
        UILabel *lblExmText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, self.textContent.bottom+20, kSCREEN_WIDTH-24, 16) title:@"示例文本" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_uploadMsgView addSubview:lblExmText];
        
        UILabel *lblExmDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, lblExmText.bottom+12, kSCREEN_WIDTH-24, 20) title:@"例如：13812345678+张三" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_uploadMsgView addSubview:lblExmDesc];
        
        _uploadMsgView.height = lblExmDesc.bottom;
    }
    return _uploadMsgView;
}

// 创建图片展示视图
-(void)createImageView{
    
    for(UIView *view in [_imagesView subviews]){
        if ([view isKindOfClass:[UIImageView class]] || [view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    for (int i =0 ; i<self.arrImageUrls.count+1; i++) {
        CGFloat width_img = (kSCREEN_WIDTH-32-24)/3;
        
        UIImageView *imageInfo = [[UIImageView alloc] initWithFrame:CGRectMake(12, 54 + i*(100+16), width_img, width_img)];
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
        
        UIView *imageLast = (UIView *)[_imagesView viewWithTag:100+i-1];
        
        if (i == 0) {
            imageInfo.x = 12;
            imageInfo.y = 54;
        }else{
            imageInfo.x = CGRectGetMaxX(imageLast.frame)+12;
            if (CGRectGetMaxX(imageInfo.frame)+12 > kSCREEN_WIDTH) {
                imageInfo.x = 12;
                imageInfo.y = CGRectGetMaxY(imageLast.frame)+16;
            }else{
                imageInfo.y = imageLast.y;
            }
        }
        
        [_imagesView addSubview:imageInfo];
        
        // 给每张图片添加删除按钮
        UIButton *btnDel = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(imageInfo.frame)-10, imageInfo.y-8, 20, 20) btnTitle:@"" btnImage:@"chahao" titleColor:[UIColor clearColor] titleFont:0];
        btnDel.tag = 200 + i;
        [btnDel addTarget:self action:@selector(btnDelImageAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i !=self.arrImageUrls.count) {
            [_imagesView addSubview:btnDel];
        }
       
        _imagesView.height = imageInfo.bottom;
    }
    _uploadMsgView.y = _imagesView.bottom+20;
    _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _uploadMsgView.bottom+16);
}

//顶部背景图
-(UIImageView *)imageHeadBack{
    if (!_imageHeadBack) {
        _imageHeadBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 156)];
        _imageHeadBack.image = [UIImage imageNamed:@"task_nav_bg"];
    }
    return _imageHeadBack;
}

//提交按钮
-(UIView *)buttonView{
    if (!_buttonView) {
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-64, kSCREEN_WIDTH, 64)];
        _buttonView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBBG;
        [_buttonView addSubview:line];
        
        UIButton *button = [[UIButton alloc] initSystemWithFrame:CGRectMake(12, 8, kSCREEN_WIDTH-24, 48) btnTitle:@"立即提交" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        button.backgroundColor = RGBMAIN;
        button.layer.cornerRadius = 2;
        [_buttonView addSubview:button];
        [button addTarget:self action:@selector(buttonDoneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonView;
}

@end
