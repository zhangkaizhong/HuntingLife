//
//  HDTaoShareViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/22.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoShareViewController.h"
#import <CoreImage/CoreImage.h>

@interface HDTaoShareViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainSrollView;
@property (nonatomic,strong) UIScrollView *imagesSrollView;
@property (nonatomic,strong) UIView *viewShareInfo;
@property (nonatomic,strong) UIView *viewImagesInfo;
@property (nonatomic,strong) UIView *viewShareBtns;
@property (nonatomic,strong) UIView *viewTop;
@property (nonatomic,strong) UIImageView *QRImageV;
@property (nonatomic,strong) UIImageView *QRCodeImgV;

@property (nonatomic,strong) NSDictionary *infoDic;
@property (nonatomic,strong) NSMutableArray *imagesArr;
@property (nonatomic,strong) NSMutableArray *selImagesArr;
@property (nonatomic,strong) NSMutableArray *saveAlmArr;
@property (nonatomic,assign) BOOL isSaveAlm;

@end

@implementation HDTaoShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainSrollView];
    self.selImagesArr = [NSMutableArray new];
    self.saveAlmArr = [NSMutableArray new];
    self.imagesArr = [NSMutableArray new];
    [self.imagesArr addObjectsFromArray:self.detailModel.smallImagesArr];
    
    [self getShareInfo];
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//复制分享文案
-(void)shareContentCopyAction{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.infoDic[@"shareContent"];
    [SVHUDHelper showSuccessDoneMsg:@"文案已复制"];
}

//复制淘口令
-(void)shareModelCopyAction{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.infoDic[@"model"];
    [SVHUDHelper showSuccessDoneMsg:@"淘口令已复制"];
}

//选择图片
-(void)btnSelAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    NSMutableArray *arrSel = [NSMutableArray new];
    [self.selImagesArr removeAllObjects];
    for (int i=0; i<self.imagesArr.count; i++) {
        UIButton *button = (UIButton *)[self.imagesSrollView viewWithTag:2000+i];
        UIImageView *selImageV = (UIImageView *)[self.imagesSrollView viewWithTag:1000+i];
        if (button.selected) {
            [self.selImagesArr addObject:selImageV.image];
            [arrSel addObject:[NSString stringWithFormat:@"%d",1000+i]];
        }
    }
    
    UIView *viewPlace = (UIView *)[self.imagesSrollView viewWithTag:3000];
    if (arrSel.count>0) {
        viewPlace.hidden = NO;
        NSString *index0 = arrSel[0];
        UIImageView *imageV = (UIImageView *)[self.imagesSrollView viewWithTag:[index0 integerValue]];
        viewPlace.x = imageV.x;

        UIImage *image = self.selImagesArr[0];
        UIImageView *qrImageV = [self createQRImageV:image];
        UIImage *imageIndex0 = [self imageWithView:qrImageV];
        [self.selImagesArr removeObjectAtIndex:0];
        [self.selImagesArr insertObject:imageIndex0 atIndex:0];
    }else{
        viewPlace.hidden = YES;
    }
}

//分享
-(void)tapShareBtnAction:(UIGestureRecognizer *)gesture{
    if (self.selImagesArr.count == 0) {
        [SVHUDHelper showDarkWarningMsg:@"请选择分享图片"];
        return;
    }

    UIImage *image = self.selImagesArr[0];
    
    NSInteger index = gesture.view.tag - 100;
    if (index == 0) {
        //批量存图
        self.isSaveAlm = YES;
        [self.saveAlmArr removeAllObjects];
        [self.saveAlmArr addObjectsFromArray:self.selImagesArr];
        [self saveNext];
    }
    if (index == 1) {
        //微信
        if (self.selImagesArr.count>1) {
            [self mq_share:self.selImagesArr];
        }
        else if (self.selImagesArr.count == 1) {
            [HDToolHelper shareImage:UMSocialPlatformType_WechatSession thumbImage:self.selImagesArr[0] shareImage:image controller:self];
        }
    }
    if (index == 2) {
        //朋友圈
        if (self.selImagesArr.count>1) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.infoDic[@"shareContent"];
            self.isSaveAlm = NO;
            [self.saveAlmArr removeAllObjects];
            [self.saveAlmArr addObjectsFromArray:self.selImagesArr];
            [self saveNext];
        }else{
            [HDToolHelper shareImage:UMSocialPlatformType_WechatTimeLine thumbImage:self.selImagesArr[0] shareImage:image controller:self];
        }
    }
    if (index == 3) {
        //QQ
        if (self.selImagesArr.count>1) {
            [self mq_share:self.selImagesArr];
        }else{
            [HDToolHelper shareImage:UMSocialPlatformType_QQ thumbImage:self.selImagesArr[0] shareImage:image controller:self];
        }
    }
    if (index == 4) {
        //QQ空间
        if (self.selImagesArr.count>1) {
            [self mq_share:self.selImagesArr];
        }else{
            [HDToolHelper shareImage:UMSocialPlatformType_Qzone thumbImage:self.selImagesArr[0] shareImage:image controller:self];
        }
    }
}

//批量保存图片到相册
-(void)saveNext{
    if (self.saveAlmArr.count > 0) {
        UIImage *image = [self.saveAlmArr objectAtIndex:0];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    else {
        if (self.isSaveAlm) {
            [SVHUDHelper showSuccessDoneMsg:@"图片已保存到相册"];
        }
        else{
            [[WMZAlert shareInstance] showAlertWithType:AlertTypeShareWeixin headTitle:@"去朋友圈分享" textTitle:@"" viewController:self leftHandle:^(id anyID) {
                //取消
            }rightHandle:^(id any) {
                //打开微信
                [self openWechat];
            }];
        }
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *message = @"";
    if (!error) {
        [self.saveAlmArr removeObjectAtIndex:0];
        [self saveNext];
    }else{
        message = [error description];
    }
}

-(void)openWechat{
    NSURL * url = [NSURL URLWithString:@"weixin://"];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
    //先判断是否能打开该url
    if (canOpen){
        //打开微信
        [[UIApplication sharedApplication] openURL:url];
    }else {
        [SVHUDHelper showDarkWarningMsg:@"您的设备未安装微信"];
    }
}

#pragma mark -- 数据请求
-(void)getShareInfo{
    NSDictionary *params = @{
        @"logo":self.detailModel.pictUrl,
        @"taoId":self.detailModel.taoId,
        @"text":self.detailModel.title,
        @"url":self.clickUrl,
        @"userId":[HDUserDefaultMethods getData:@"relationId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoGoodsCreateForShare params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.infoDic = returnData[@"data"];
            
            [self.mainSrollView addSubview:self.viewTop];
            [self.mainSrollView addSubview:self.viewShareInfo];
            [self.mainSrollView addSubview:self.viewImagesInfo];
            
            self.mainSrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.viewImagesInfo.bottom);
            
            [self.view addSubview:self.viewShareBtns];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== UI =====================
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"创建分享" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainSrollView{
    if (!_mainSrollView) {
        _mainSrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-110)];
        _mainSrollView.backgroundColor = [UIColor clearColor];
    }
    return _mainSrollView;
}

-(UIView *)viewTop{
    if (!_viewTop) {
        _viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
        _viewTop.backgroundColor = [UIColor whiteColor];
        UIView *view1 = [[UIView alloc] init];
        view1.frame = CGRectMake(16,12,kSCREEN_WIDTH-32,32);
        [_viewTop addSubview:view1];

        view1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        view1.layer.cornerRadius = 32/2;
        view1.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.06].CGColor;
        view1.layer.shadowOffset = CGSizeMake(0,6);
        view1.layer.shadowOpacity = 1;
        view1.layer.shadowRadius = 6;
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(16, 6, 20, 20)];
        image.image = [UIImage imageNamed:@"tab_ic_03_slected"];
        [view1 addSubview:image];
        
        UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(image.frame)+8, 0, _viewTop.width-CGRectGetMaxX(image.frame)-8-8, 32) title:@"分享后不要忘记复制黏贴【评论区文案】！！！" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentCenter isFit:YES];
        lbl.height = 32;
        [view1 addSubview:lbl];
        view1.width = CGRectGetMaxX(lbl.frame)+16;
        view1.centerX = kSCREEN_WIDTH/2;
        
        _viewTop.height = view1.bottom+12;
    }
    return _viewTop;
}

-(UIView *)viewShareInfo{
    if (!_viewShareInfo) {
        _viewShareInfo = [[UIView alloc] initWithFrame:CGRectMake(0, _viewTop.bottom, kSCREEN_WIDTH, 100)];
        _viewShareInfo.backgroundColor = [UIColor whiteColor];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(12, 12, kSCREEN_WIDTH-24, 100)];
        viewBack.backgroundColor = RGBCOLOR(249, 249, 249);
        [_viewShareInfo addSubview:viewBack];
        
        UILabel *lblInfo = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, 12, viewBack.width-24, 20) title:self.infoDic[@"shareContent"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblInfo.numberOfLines = 0;
        [lblInfo sizeToFit];
        [viewBack addSubview:lblInfo];
        viewBack.height = lblInfo.bottom+12;
        
        UIButton *btnShareContent = [[UIButton alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH/2-80-20, viewBack.bottom+16, 80, 18) btnTitle:@"复制分享文案" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:10];
        btnShareContent.layer.cornerRadius = 9;
        [btnShareContent addTarget:self action:@selector(shareContentCopyAction) forControlEvents:UIControlEventTouchUpInside];
        [_viewShareInfo addSubview:btnShareContent];
        
        UIButton *btnShareModel = [[UIButton alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH/2+20, viewBack.bottom+16, 80, 18) btnTitle:@"仅复制淘口令" bgColor:[UIColor whiteColor] titleColor:RGBMAIN titleFont:10];
        [btnShareModel addTarget:self action:@selector(shareModelCopyAction) forControlEvents:UIControlEventTouchUpInside];
        btnShareModel.layer.cornerRadius = 9;
        btnShareModel.layer.borderWidth = 1;
        btnShareModel.layer.borderColor = RGBMAIN.CGColor;
        [_viewShareInfo addSubview:btnShareModel];
        
        _viewShareInfo.height = btnShareModel.bottom+16;
    }
    return _viewShareInfo;
}

-(UIView *)viewImagesInfo{
    if (!_viewImagesInfo) {
        _viewImagesInfo = [[UIView alloc] initWithFrame:CGRectMake(0, _viewShareInfo.bottom, kSCREEN_WIDTH, 100)];
        _viewImagesInfo.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, 12, kSCREEN_WIDTH-24, 14) title:@"选择图片" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewImagesInfo addSubview:lblText];
        
        UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, lblText.bottom+12, kSCREEN_WIDTH, 120)];
        imageScroll.showsHorizontalScrollIndicator = NO;
        self.imagesSrollView = imageScroll;
        for (int i=0;i<self.imagesArr.count;i++) {
            UIImage *img = [HDToolHelper getImageFromURL:self.imagesArr[i]];
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(12+i*132, 0, 120, 120)];
            imageV.tag = 1000+i;
            imageV.layer.borderWidth = 1;
            imageV.layer.cornerRadius = 2;
            imageV.layer.borderColor = RGBBG.CGColor;
            imageV.image = img;
            imageV.userInteractionEnabled = YES;
            imageV.layer.masksToBounds = YES;
            [imageScroll addSubview:imageV];
            
            UIButton *btnSel = [[UIButton alloc] initSystemWithFrame:CGRectMake(12+120-6-20+i*132, 6, 20, 20) btnTitle:@"" btnImage:@"checkbox_default" titleColor:[UIColor clearColor] titleFont:0];
            [btnSel setImage:[UIImage imageNamed:@"checkbox_selected"] forState:UIControlStateSelected];
            [btnSel addTarget:self action:@selector(btnSelAction:) forControlEvents:UIControlEventTouchUpInside];
            btnSel.tag = 2000+i;
            [imageScroll addSubview:btnSel];
            
            if (i==0) {
                btnSel.selected = YES;

                UIImageView *qrImageV = [self createQRImageV:img];
                UIImage *imageIndex0 = [self imageWithView:qrImageV];
                [self.selImagesArr addObject:imageIndex0];
            }
            
            imageScroll.contentSize = CGSizeMake(CGRectGetMaxX(imageV.frame)+12, 120);
        }
        [_viewImagesInfo addSubview:imageScroll];
        _viewImagesInfo.height = imageScroll.bottom+16;
        
        //二维码推广图
        UIView *viewPlace = [[UIView alloc] initWithFrame:CGRectMake(12, 95, 120, 25)];
        viewPlace.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [imageScroll addSubview:viewPlace];
        viewPlace.tag = 3000;

        UILabel *lblPlace = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, viewPlace.width, 25) title:@"二维码推广图" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewPlace addSubview:lblPlace];
    }
    return _viewImagesInfo;
}

-(UIView *)viewShareBtns{
    if (!_viewShareBtns) {
        _viewShareBtns = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-110, kSCREEN_WIDTH, 110)];
        _viewShareBtns.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 12, kSCREEN_WIDTH, 14) title:@"分享图片" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_viewShareBtns addSubview:lblText];
        
        NSArray *arrBtns = @[@{@"title":@"批量存图",@"icon":@"share_ic_photo"},@{@"title":@"微信",@"icon":@"share_ic_wechat"},@{@"title":@"朋友圈",@"icon":@"share_ic_friends"},@{@"title":@"QQ",@"icon":@"share_ic_qq"},@{@"title":@"QQ空间",@"icon":@"share_ic_qqzone"}];
        for (int i=0; i<arrBtns.count; i++) {
            UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/arrBtns.count, lblText.bottom+12, kSCREEN_WIDTH/arrBtns.count, 60)];
            btnView.tag = 100+i;
            UIImageView *imageBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            imageBtn.centerX = btnView.width/2;
            imageBtn.image = [UIImage imageNamed:arrBtns[i][@"icon"]];
            
            [btnView addSubview:imageBtn];
            
            //tap
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShareBtnAction:)];
            btnView.userInteractionEnabled = YES;
            [btnView addGestureRecognizer:tap];
            
            UILabel *lblBtn = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageBtn.bottom+8, btnView.width, 12) title:arrBtns[i][@"title"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
            [btnView addSubview:lblBtn];
            
            [_viewShareBtns addSubview:btnView];
        }
        
        _viewShareBtns.height = lblText.bottom+12+60+12;
        _viewShareBtns.y = kSCREEN_HEIGHT - _viewShareBtns.height;
    }
    return _viewShareBtns;
}

//创建二维码推广图
-(UIImageView *)createQRImageV:(UIImage *)img{
    _QRImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 120)];
    _QRImageV.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageGoods = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_WIDTH)];
    imageGoods.image = img;
    [_QRImageV addSubview:imageGoods];
    
    UIImageView *imageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appicon_img"]];
    imageIcon.x = 16;
    imageIcon.y = 16;
    imageIcon.layer.cornerRadius = 4;
    imageIcon.layer.masksToBounds = YES;
    [_QRImageV addSubview:imageIcon];
    
    UIImageView *QRCodeImgV = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-24-82, imageGoods.bottom+12, 82, 82)];
    QRCodeImgV.image = [self generateQRCodeWithString:self.infoDic[@"shareContentWx"] Size:82];
    [_QRImageV addSubview:QRCodeImgV];
    self.QRCodeImgV = QRCodeImgV;
    
    UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(QRCodeImgV.x-12, QRCodeImgV.bottom+8, QRCodeImgV.width+24, 12) title:@"长按识别二维码" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
    [_QRImageV addSubview:lblText];
    
    //商品标题
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, imageGoods.bottom+24, kSCREEN_WIDTH-72-36, 20)];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.detailModel.title attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: RGBTEXT}];
    lblTitle.attributedText = string;
    [_QRImageV addSubview:lblTitle];
    
    //现价
    UILabel *lblCurrentPrice = [[UILabel alloc] initWithFrame:CGRectMake(12, lblTitle.bottom+12, 100, 18)];
    lblCurrentPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥ %.2f",[self.detailModel.quanhouJiage floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
    [lblCurrentPrice sizeToFit];
    [_QRImageV addSubview:lblCurrentPrice];
    
    //原价
    UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblCurrentPrice.frame)+8, 0, 100, 10) title:self.detailModel.size bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentLeft isFit:NO];
    [lblOldPrice sizeToFit];
    lblOldPrice.bottom = lblCurrentPrice.bottom-3;
    [_QRImageV addSubview:lblOldPrice];
    
    UIView *linePrice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 1)];
    linePrice.centerY = lblOldPrice.height/2;
    linePrice.backgroundColor = RGBTEXTINFO;
    [lblOldPrice addSubview:linePrice];
    
    //优惠券
    UIImageView *imageCouponView = [[UIImageView alloc] initWithFrame:CGRectMake(12, lblCurrentPrice.bottom+12, 32, 14)];
    [_QRImageV addSubview:imageCouponView];

    UILabel *lblQuan = [[UILabel alloc] initCommonWithFrame:CGRectMake(imageCouponView.width-18, 0, 16, 14) title:@"券" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
    [imageCouponView addSubview:lblQuan];

    UILabel *lblCouponPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(7, 0, 80, 14) title:[NSString stringWithFormat:@"¥%@",self.detailModel.couponInfoMoney] bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
    [lblCouponPrice sizeToFit];
    lblCouponPrice.height = 14;
    [imageCouponView addSubview:lblCouponPrice];
    imageCouponView.width = 7+lblCouponPrice.width+16;
    lblQuan.x = imageCouponView.width-16;
    
    //调整优惠券图片的大小
    UIImage *imgCoupon = [UIImage imageNamed:@"coupon_bg"];
    CGFloat imageWidth = imgCoupon.size.width;
    CGFloat imageHeight = imgCoupon.size.height;
    CGPoint centerPoint = CGPointMake(imageWidth*0.5, imageHeight*0.5);
    UIEdgeInsets insets = UIEdgeInsetsMake(centerPoint.y, centerPoint.x, imageHeight - centerPoint.y - 1, imageWidth - centerPoint.y - 1);
    imgCoupon = [imgCoupon resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    imageCouponView.image = imgCoupon;
    
    _QRImageV.height = QRCodeImgV.bottom+36;
    return _QRImageV;
}

//将ImageView上的控件合成image用于服务器上传
//这个方法就是讲ImageView控件画在上面（自己的理解，不懂的可以去看看API）
- (UIImage *)imageWithView:(UIImageView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);//图形以选项开始图像上下文
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();//*图像从当前图像上下文获取图像
    UIGraphicsEndImageContext();//结束图像上下文
    return img;
}

//生成二维码
- (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size
{
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //过滤器恢复默认
    [filter setDefaults];
    //给过滤器添加数据<字符串长度893>
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    //获取二维码过滤器生成二维码
    CIImage *image = [filter outputImage];
    UIImage *img = [self createNonInterpolatedUIImageFromCIImage:image WithSize:size];
    return img;
}

//二维码清晰
- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image WithSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

/** 分享 */
-(void)mq_share:(NSArray *)items{
    if (items.count == 0) {
        return;
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    if (@available(iOS 11.0, *)) {//UIActivityTypeMarkupAsPDF是在iOS 11.0 之后才有的
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypeOpenInIBooks,UIActivityTypeMarkupAsPDF];
    } else if (@available(iOS 9.0, *)) {//UIActivityTypeOpenInIBooks是在iOS 9.0 之后才有的
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypeOpenInIBooks];
    }else {
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage,UIActivityTypeMail];
    }
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            DTLog(@">>>>>success");
            
        }else {
            DTLog(@">>>>>faild");
            
        }
    };
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
