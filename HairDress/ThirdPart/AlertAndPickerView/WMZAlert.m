
//
//  WMZAlert.m
//  WMZAlert
//
//  Created by wmz on 2018/10/9.
//  Copyright © 2018年 wmz. All rights reserved.
//

#import "WMZAlert.h"

#define title_Font 16.0f
#define text_Font  13.0f
#define kDevice_Height [UIScreen mainScreen].bounds.size.height
#define kDevice_Width  [UIScreen mainScreen].bounds.size.width
#define NavigationBar_Height (([[UIApplication sharedApplication] statusBarFrame].size.height) + 44)
#define wmz_GetWNum(A)   (A)/2.0*(kDevice_Width/375)
#define wmz_GetHNum(B)   (B)/2.0*(kDevice_Height/667)
#define HEX_COLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface WMZAlert()<UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    dispatch_source_t timer;                                                      //定时器
}

@property (nonatomic, copy)   NavClickBlock leftButtonClickHandle;                //取消按钮回调

@property (nonatomic, assign) AlertType type;                                     //弹窗类型

@property (nonatomic, copy)   NavClickBlock rightButtonClickHandle;               //确定按钮回调

@property (nonatomic, strong) UIView *mainView;                                    //支付视图

@property (nonatomic, strong) UIView *shadowView;                                    //背景透明视图

@property (nonatomic, strong) UIView *otherMainView;                               //底部透明视图

@property (nonatomic, strong) UILabel *titleLabel;                                 //标题视图

@property (nonatomic, strong) UIView *passView;                                   //密码框视图

@property (nonatomic, strong) HDTextFeild *payField;                              //密码编辑框（不可见）

@property (nonatomic, strong) UITextView *alertTextView;                          //文本写入框

@property (nonatomic, strong) UILabel *mainText;                                  //主要文本

@property (nonatomic, strong) NSString *placeHolderText;                          //提示语内容

@property (nonatomic, strong) UIViewController *nowVC;                            //当前VC

@property (nonatomic, strong) UITableView *tableView;                             //tableView

@property (nonatomic, strong) NSArray *dataArr;                                   //选择器数据源

@property (nonatomic, strong) id selectID;                                        //选中的店员角色

@property (nonatomic, assign) CGFloat mainWidth;                                  //背景宽度

@property (nonatomic, strong) UIButton *cancelBtn;                                //取消按钮

@property (nonatomic, strong) UIButton *okBtn;                                    //确定按钮

@property (nonatomic, strong) UIButton *closeBtn;                                 //关闭按钮

@property (nonatomic, strong) UIView *leftLine;                                   //中间线

@property (nonatomic, strong) UIScrollView *shareView;                            //分享

@property (nonatomic, strong) NSArray *shareArr;                             //分享数据源


@property (nonatomic, strong) NSDictionary *paiduiInfoDic;                             //排队进度


@end

@implementation WMZAlert

//初始化
+ (instancetype)shareInstance{
    return [[self alloc]init];
}


//简单化弹窗没有回调
- (void)showAlertWithType:(AlertType)type
                textTitle:(id) text{
    
    [self showAlertWithType:type sueprVC:nil leftTitle:nil rightTitle:nil headTitle:nil textTitle:text headTitleColor:nil textTitleColor:nil backColor:nil okBtnColor:nil cancelBtnColor:nil leftHandle:nil rightHandle:nil];
    
}

//简单化弹窗带回调
- (void)showAlertWithType:(AlertType)type
                headTitle:(NSString*)title
                textTitle:(id) text
           viewController:(UIViewController *)VC
               leftHandle:(NavClickBlock)leftBlock
              rightHandle:(NavClickBlock)rightBlock{
    
    [self showAlertWithType:type sueprVC:VC leftTitle:nil rightTitle:nil headTitle:title textTitle:text headTitleColor:nil textTitleColor:nil backColor:nil okBtnColor:nil cancelBtnColor:nil leftHandle:leftBlock rightHandle:rightBlock];
    
}

//最全面弹窗可以设置按钮颜色等
-  (void)showAlertWithType:(AlertType)type
                   sueprVC:(UIViewController*)VC
                 leftTitle:(NSString*)leftText
                rightTitle:(NSString*)rightText
                 headTitle:(NSString*)title
                 textTitle:(id) text
            headTitleColor:(UIColor*)titleColor
            textTitleColor:(UIColor*)textColor
                 backColor:(UIColor*)backColor
                okBtnColor:(UIColor*)okColor
            cancelBtnColor:(UIColor*)cancelColor
                leftHandle:(NavClickBlock)leftBlock
               rightHandle:(NavClickBlock)rightBlock{
    
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.nowVC = VC;
    
    id addView = [self appearViewWithType:type sueprVC:VC leftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor leftHandle:leftBlock rightHandle:rightBlock];


    if (!addView) {
        
        return;
    }
    
    
   
    if ([addView isKindOfClass:[UIView class]]) {

        [self.view addSubview:addView];
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [VC presentViewController:self animated:YES completion:nil];
        
        if (type == AlertTypeAuto|| type == AlertTypeToast) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self closeView];
            });
        }
        
    }else{
        [VC presentViewController:addView animated:YES completion:nil];
    }

    
}

//添加阴影
- (void)addShadow{
    
    UIView *shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
    shadowView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:shadowView];
    shadowView.alpha = 0.4f;
    self.shadowView = shadowView;
}

//根据type添加不同的视图
-  (id)appearViewWithType:(AlertType)type
                  sueprVC:(UIViewController*)VC
                leftTitle:(NSString*)leftText
               rightTitle:(NSString*)rightText
                headTitle:(NSString*)title
                textTitle:(id) text
           headTitleColor:(UIColor*)titleColor
           textTitleColor:(UIColor*)textColor
                backColor:(UIColor*)backColor
               okBtnColor:(UIColor*)okColor
           cancelBtnColor:(UIColor*)cancelColor
               leftHandle:(NavClickBlock)leftBlock
              rightHandle:(NavClickBlock)rightBlock{
    self.leftButtonClickHandle = leftBlock;
    self.rightButtonClickHandle = rightBlock;
    self.type = type;
    
    switch (type) {
        case AlertTypeSystemPush:             //系统默认弹窗
        {
            return [self AlertTypeSystemPushViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeSystemSheet:            //系统底部弹窗
        {
            return [self AlertTypeSystemSheetViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeAuto:{                  //默认自动消失弹窗
            
           return [self AlertTypeAutoViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypePay:{                  //支付弹窗
            return [self AlertTypemainViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeToast:{                //吐丝弹窗显示在上部
           return [self AlertTypeToastViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
            
        }
            break;
        case AlertTypeWrite:{               //可输入内容的弹窗
           return [self AlertTypeWriteViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeTime:{               //倒计时弹窗
            return [self AlertTypeTimeViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeShare:{               //分享弹窗
            return [self AlertTypeShareViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
            
        #pragma mark ================================= 有用的 ====================================
        case AlertTypeNornal:                  //默认弹窗(提示)
        {
            return [self AlertTypeNornalViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeSelect:{               //设置店员角色的弹窗 (有用的)
            return [self AlertTypeSelectViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeTopay:{               //支付弹窗 (有用的)
            return [self AlertTypeTopayViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeYuyue:{               //理发已预约的弹窗（有用的）
            return [self AlertTypeYuyueViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeQueueCheck:{          //查看排队进度的弹窗 (有用的)
            return [self AlertTypeCheckQueueViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeAcceptTask:           //领取任务的弹窗(提示)
        {
            return [self AlertTypeAcceptTaskViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeShareWeixin:                  //去朋友圈分享(提示)
        {
            return [self AlertTypeShareWeixinViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        case AlertTypeTaoBao:                  //淘宝授权(提示)
        {
            return [self AlertTypeTaobaoViewWithLeftTitle:leftText rightTitle:rightText headTitle:title textTitle:text headTitleColor:titleColor textTitleColor:textColor backColor:backColor okBtnColor:okColor cancelBtnColor:cancelColor];
        }
            break;
        default:
            break;
    }
    
    return [UIView new];
}

//默认弹窗(删除店员弹窗)
- (id)AlertTypeNornalViewWithLeftTitle:(NSString*)leftText
                     rightTitle:(NSString*)rightText
                      headTitle:(NSString*)title
                      textTitle:(id) text
                 headTitleColor:(UIColor*)titleColor
                 textTitleColor:(UIColor*)textColor
                      backColor:(UIColor*)backColor
                     okBtnColor:(UIColor*)okColor
                 cancelBtnColor:(UIColor*)cancelColor{
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(270*2), wmz_GetHNum(266)) withRadius:7.0f];
    [self setTitleLabelWithTitle:title?:@"提示" WithTextColor:titleColor?:RGBTEXT WithNum:5 withFrame:CGRectMake(0, wmz_GetHNum(40), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(36)) isCenter:YES];
    [self setMaintextWithText:text WithTextColor:RGBTEXTINFO WithNum:25 withFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(32), self.mainWidth-wmz_GetWNum(40), wmz_GetHNum(44)) isCenter:YES withFont:[UIFont systemFontOfSize:text_Font]];
    
    UIView *line = [self getLineViewWithColor:RGBCOLOR(221, 221, 221) withFrame:CGRectMake(0, CGRectGetMaxY(self.mainText.frame)+wmz_GetHNum(32), self.mainWidth, 1.0f) withAlpha:1.0f];
    [self.mainView addSubview:line];

    if (self.leftButtonClickHandle) {
        [self setCancelBtnWithTextColor:RGBTEXT withTitle:leftText withFrame:CGRectMake(0, CGRectGetMaxY(line.frame), self.mainWidth/2-0.5, wmz_GetHNum(96))];
        [self.mainView addSubview:self.leftLine];
    }
    
    [self setOkBtnWithTextColor:RGBMAIN withTitle:rightText withFrame:CGRectMake(self.leftButtonClickHandle?CGRectGetMaxX(self.leftLine.frame):0, CGRectGetMaxY(line.frame), self.leftButtonClickHandle?self.mainWidth/2-0.5f:self.mainWidth, wmz_GetHNum(96))];
    
    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(270*2), CGRectGetMaxY(self.okBtn.frame))];
    
    return self.mainView;
}

//淘宝授权(弹窗)
- (id)AlertTypeTaobaoViewWithLeftTitle:(NSString*)leftText
                     rightTitle:(NSString*)rightText
                      headTitle:(NSString*)title
                      textTitle:(id) text
                 headTitleColor:(UIColor*)titleColor
                 textTitleColor:(UIColor*)textColor
                      backColor:(UIColor*)backColor
                     okBtnColor:(UIColor*)okColor
                 cancelBtnColor:(UIColor*)cancelColor{
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(270*2), wmz_GetHNum(266)) withRadius:7.0f];
    
    //图标
    UIImageView *imageApp = [[UIImageView alloc] initWithFrame:CGRectMake(0, wmz_GetHNum(40), wmz_GetWNum(100), wmz_GetWNum(100))];
    imageApp.image = [UIImage imageNamed:@"appicon_img"];
    imageApp.centerX = self.mainView.width/2;
    [self.mainView addSubview:imageApp];
    
    [self setTitleLabelWithTitle:title?:@"提示" WithTextColor:titleColor?:RGBTEXT WithNum:5 withFrame:CGRectMake(0, CGRectGetMaxY(imageApp.frame)+wmz_GetHNum(35), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(36)) isCenter:YES];
    [self setMaintextWithText:text WithTextColor:RGBTEXTINFO WithNum:25 withFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(32), self.mainWidth-wmz_GetWNum(40), wmz_GetHNum(44)) isCenter:YES withFont:[UIFont systemFontOfSize:text_Font]];
    
    UIView *line = [self getLineViewWithColor:RGBCOLOR(221, 221, 221) withFrame:CGRectMake(0, CGRectGetMaxY(self.mainText.frame)+wmz_GetHNum(32), self.mainWidth, 1.0f) withAlpha:1.0f];
    [self.mainView addSubview:line];

    if (self.leftButtonClickHandle) {
        [self setCancelBtnWithTextColor:RGBTEXT withTitle:leftText withFrame:CGRectMake(0, CGRectGetMaxY(line.frame), self.mainWidth/2-0.5, wmz_GetHNum(96))];
        [self.mainView addSubview:self.leftLine];
    }
    
    [self setOkBtnWithTextColor:RGBMAIN withTitle:rightText withFrame:CGRectMake(self.leftButtonClickHandle?CGRectGetMaxX(self.leftLine.frame):0, CGRectGetMaxY(line.frame), self.leftButtonClickHandle?self.mainWidth/2-0.5f:self.mainWidth, wmz_GetHNum(96))];
    
    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(270*2), CGRectGetMaxY(self.okBtn.frame))];
    
    return self.mainView;
}

//去朋友圈分享
- (id)AlertTypeShareWeixinViewWithLeftTitle:(NSString*)leftText
                     rightTitle:(NSString*)rightText
                      headTitle:(NSString*)title
                      textTitle:(id) text
                 headTitleColor:(UIColor*)titleColor
                 textTitleColor:(UIColor*)textColor
                      backColor:(UIColor*)backColor
                     okBtnColor:(UIColor*)okColor
                 cancelBtnColor:(UIColor*)cancelColor{
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(270*2), wmz_GetHNum(266)) withRadius:7.0f];
    [self setTitleLabelWithTitle:title?:@"提示" WithTextColor:titleColor?:RGBTEXT WithNum:5 withFrame:CGRectMake(0, wmz_GetHNum(40), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(36)) isCenter:YES];
    
    UIImageView *imageDone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_ic_selected"]];
    imageDone.x = 24;
    imageDone.y = self.titleLabel.bottom + 12;
    [self.mainView addSubview:imageDone];
    
    UILabel *lblShareText = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageDone.frame)+12, 0, self.mainView.width-CGRectGetMaxX(imageDone.frame)-24, 14) title:@"分享文案已自动复制" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [self.mainView addSubview:lblShareText];
    lblShareText.centerY = imageDone.centerY;
    
    UIImageView *imageDone1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_ic_selected"]];
    imageDone1.x = 24;
    imageDone1.y = imageDone.bottom + 12;
    [self.mainView addSubview:imageDone1];
    
    UILabel *lblShareText1 = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageDone1.frame)+12, 0, self.mainView.width-CGRectGetMaxX(imageDone1.frame)-24, 14) title:@"图片已保存至手机相册" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblShareText1.centerY = imageDone1.centerY;
    [self.mainView addSubview:lblShareText1];
    
    UIView *line = [self getLineViewWithColor:RGBCOLOR(221, 221, 221) withFrame:CGRectMake(0, CGRectGetMaxY(imageDone1.frame)+wmz_GetHNum(32), self.mainWidth, 1.0f) withAlpha:1.0f];
    [self.mainView addSubview:line];

    if (self.leftButtonClickHandle) {
        [self setCancelBtnWithTextColor:RGBTEXT withTitle:leftText withFrame:CGRectMake(0, CGRectGetMaxY(line.frame), self.mainWidth/2-0.5, wmz_GetHNum(96))];
        [self.mainView addSubview:self.leftLine];
    }
    
    [self setOkBtnWithTextColor:RGBMAIN withTitle:@"打开微信" withFrame:CGRectMake(self.leftButtonClickHandle?CGRectGetMaxX(self.leftLine.frame):0, CGRectGetMaxY(line.frame), self.leftButtonClickHandle?self.mainWidth/2-0.5f:self.mainWidth, wmz_GetHNum(96))];
    
    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(270*2), CGRectGetMaxY(self.okBtn.frame))];
    
    return self.mainView;
}

//领取任务提示弹窗
- (id)AlertTypeAcceptTaskViewWithLeftTitle:(NSString*)leftText
                     rightTitle:(NSString*)rightText
                      headTitle:(NSString*)title
                      textTitle:(id) text
                 headTitleColor:(UIColor*)titleColor
                 textTitleColor:(UIColor*)textColor
                      backColor:(UIColor*)backColor
                     okBtnColor:(UIColor*)okColor
                 cancelBtnColor:(UIColor*)cancelColor{
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(310*2), wmz_GetHNum(266)) withRadius:7.0f];
    [self setTitleLabelWithTitle:title?:@"提示" WithTextColor:titleColor?:RGBTEXT WithNum:5 withFrame:CGRectMake(0, wmz_GetHNum(40), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(36)) isCenter:YES];
    [self setMaintextWithText:text WithTextColor:RGBTEXTINFO WithNum:0 withFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(32), self.mainWidth-wmz_GetWNum(80), wmz_GetHNum(44)) isCenter:YES withFont:[UIFont systemFontOfSize:15]];
    
    [self setOkBtnWithTextColor:[UIColor whiteColor] withTitle:@"确认开始任务" withFrame:CGRectMake(20, CGRectGetMaxY(self.mainText.frame)+12, self.mainWidth-40, wmz_GetHNum(96))];
    self.okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    self.mainView.height = CGRectGetMaxY(self.okBtn.frame)+20;
    
    UIView *viewBigMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wmz_GetWNum(310*2), 100)];
    viewBigMain.backgroundColor = [UIColor clearColor];
    [viewBigMain addSubview:self.mainView];
    viewBigMain.height = self.mainView.height;
    
    UIButton *buttonCancel = [[UIButton alloc] initCommonWithFrame:CGRectMake(0, CGRectGetMaxY(self.mainView.frame)+16, 40, 40) btnTitle:@"" bgColor:[UIColor clearColor] titleColor:[UIColor clearColor] titleFont:0];
    buttonCancel.centerX = self.mainView.width/2;
    [viewBigMain addSubview:buttonCancel];
    [buttonCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonCancel setImage:[UIImage imageNamed:@"close-circle-fill-light"] forState:UIControlStateNormal];
    
    viewBigMain.height = buttonCancel.bottom + 16;
    
    viewBigMain.frame = CGRectMake(0, 0, wmz_GetWNum(310*2), self.mainView.height+72);
    viewBigMain.centerX = self.view.width/2;
    viewBigMain.centerY = self.view.height/2;
    
    return viewBigMain;
}

//已预约理发弹窗
- (id)AlertTypeYuyueViewWithLeftTitle:(NSString*)leftText
                     rightTitle:(NSString*)rightText
                      headTitle:(NSString*)title
                      textTitle:(id) text
                 headTitleColor:(UIColor*)titleColor
                 textTitleColor:(UIColor*)textColor
                      backColor:(UIColor*)backColor
                     okBtnColor:(UIColor*)okColor
                 cancelBtnColor:(UIColor*)cancelColor{
    if (![text isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(560), wmz_GetHNum(247*2)) withRadius:8.0f];
    [self setTitleLabelWithTitle:title?:@"提示" WithTextColor:titleColor?:RGBTEXT WithNum:5 withFrame:CGRectMake(0, wmz_GetHNum(24*2), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(28)) isCenter:YES];
    [self setMaintextWithText:text[@"num"] WithTextColor:textColor WithNum:25 withFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(32), self.mainWidth-wmz_GetWNum(32), wmz_GetHNum(48)) isCenter:YES withFont:[UIFont systemFontOfSize:24]];
    
    UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, CGRectGetMaxY(self.mainText.frame)+wmz_GetHNum(32), self.mainWidth, 16) title:[NSString stringWithFormat:@"%@-%@",text[@"startTimeDate"],text[@"endTimeDate"]] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
    [self.mainView addSubview:lblTime];
    
    UIView *line = [self getLineViewWithColor:HEX_COLOR(0xF1F1F1) withFrame:CGRectMake(0, CGRectGetMaxY(lblTime.frame)+wmz_GetHNum(48), self.mainWidth, 1) withAlpha:1];
    [self.mainView addSubview:line];
    
    UILabel *lblDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, line.bottom+wmz_GetHNum(32*2), self.mainWidth, 16) title:@"是否再次取号?" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
    [self.mainView addSubview:lblDesc];

    if (self.leftButtonClickHandle) {
        [self setCancelBtnWithTextColor:cancelColor withTitle:leftText withFrame:CGRectMake(14, CGRectGetMaxY(line.frame)+wmz_GetHNum(84*2), self.mainWidth/2-20, wmz_GetHNum(72))];
    }
    
    
    [self setOkBtnWithTextColor:okColor withTitle:rightText withFrame:CGRectMake(self.leftButtonClickHandle?CGRectGetMaxX(self.cancelBtn.frame)+12:0, CGRectGetMaxY(line.frame)+wmz_GetHNum(84*2), self.leftButtonClickHandle?self.mainWidth/2-20:self.mainWidth, wmz_GetHNum(72))];
    
    [self.cancelBtn setTitle:@"再次取号" forState:UIControlStateNormal];
    [self.okBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(560), CGRectGetMaxY(self.okBtn.frame)+wmz_GetHNum(48))];
    
    return self.mainView;
}

//查看排队进度
- (id)AlertTypeCheckQueueViewWithLeftTitle:(NSString*)leftText
                          rightTitle:(NSString*)rightText
                           headTitle:(NSString*)title
                           textTitle:(id) text
                      headTitleColor:(UIColor*)titleColor
                      textTitleColor:(UIColor*)textColor
                           backColor:(UIColor*)backColor
                          okBtnColor:(UIColor*)okColor
                      cancelBtnColor:(UIColor*)cancelColor{
    if (![text isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self.dataArr = [NSArray arrayWithArray:text[@"arr"]];
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(280*2), wmz_GetHNum(278*2)) withRadius:8.0f];
    
    //发型师资料
    NSDictionary *dicInfo = text[@"cutter"];
    self.paiduiInfoDic = dicInfo;
    UIView *viewCutter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mainView.width, wmz_GetHNum(108*2))];
    viewCutter.backgroundColor = [UIColor clearColor];
    [self.mainView addSubview:viewCutter];
    
    UIImageView *imageHead = [[UIImageView alloc] initWithFrame:CGRectMake(wmz_GetWNum(24*2), wmz_GetHNum(24*2), wmz_GetWNum(60*2), wmz_GetWNum(60*2))];
    [imageHead sd_setImageWithURL:[NSURL URLWithString:dicInfo[@"headImg"]]];
    [viewCutter addSubview:imageHead];
    
    UILabel *lblTonyName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageHead.frame)+wmz_GetWNum(12*2), imageHead.y+wmz_GetHNum(7*2), viewCutter.width-CGRectGetMaxX(imageHead.frame)-wmz_GetWNum(12*2)-10, wmz_GetHNum(16*2)) title:dicInfo[@"tonyName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewCutter addSubview:lblTonyName];
    
    UILabel *lblWaitNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageHead.frame)+wmz_GetWNum(12*2), lblTonyName.bottom+wmz_GetHNum(22*2), viewCutter.width-CGRectGetMaxX(imageHead.frame)-wmz_GetWNum(12*2)-10, wmz_GetHNum(14*2)) title:[NSString stringWithFormat:@"前面有%ld人",[dicInfo[@"waitNum"] integerValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewCutter addSubview:lblWaitNum];
    
    UIView *upLine = [self getLineViewWithColor:HEX_COLOR(0xF1F1F1) withFrame:CGRectMake(0, CGRectGetMaxY(viewCutter.frame), self.mainWidth, 1) withAlpha:1];
    [self.mainView addSubview:upLine];
    
    [self.mainView addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(upLine.frame)+wmz_GetHNum(24), self.mainWidth,self.dataArr.count>=8?8*wmz_GetHNum(36*2):self.dataArr.count*wmz_GetHNum(36*2));
    
    [self setOkBtnWithTextColor:okColor withTitle:rightText withFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame)+wmz_GetHNum(24*2), self.mainWidth, wmz_GetHNum(48*2))];
    [self.okBtn setTitle:@"我知道了" forState:UIControlStateNormal];

    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(280*2), CGRectGetMaxY(self.okBtn.frame))];
    
    return self.mainView;
}

//支付方式弹窗
- (id)AlertTypeTopayViewWithLeftTitle:(NSString*)leftText
                          rightTitle:(NSString*)rightText
                           headTitle:(NSString*)title
                           textTitle:(id) text
                      headTitleColor:(UIColor*)titleColor
                      textTitleColor:(UIColor*)textColor
                           backColor:(UIColor*)backColor
                          okBtnColor:(UIColor*)okColor
                      cancelBtnColor:(UIColor*)cancelColor{
    if (![text isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self.dataArr = [NSArray arrayWithArray:text[@"dataArr"]];
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(280*2), wmz_GetHNum(276*2)) withRadius:8.0f];
    [self setTitleLabelWithTitle:title?:@"请选择" WithTextColor:titleColor?:[UIColor blackColor] WithNum:5 withFrame:CGRectMake(16, wmz_GetHNum(48), self.mainWidth-wmz_GetWNum(64), wmz_GetHNum(28)) isCenter:YES];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = HEX_COLOR(0x666666);
    
    UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    labelPrice.centerY = self.titleLabel.centerY;
    labelPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[text[@"payAmount"] floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
    [labelPrice sizeToFit];
    labelPrice.x = self.mainView.width - wmz_GetWNum(14*2) - labelPrice.width;
    [self.mainView addSubview:labelPrice];
    
    UIView *upLine = [self getLineViewWithColor:HEX_COLOR(0xF1F1F1) withFrame:CGRectMake(16, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(32), self.mainWidth-32, 1) withAlpha:1];
    [self.mainView addSubview:upLine];
    
    [self.mainView addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(upLine.frame), self.mainWidth,self.dataArr.count>=8?8*wmz_GetHNum(110):self.dataArr.count*wmz_GetHNum(110));
    
    [self setCancelBtnWithTextColor:cancelColor withTitle:leftText withFrame:CGRectMake(16, CGRectGetMaxY(self.tableView.frame)+56, self.mainWidth/2-16-5.5, wmz_GetHNum(72))];
    [self setOkBtnWithTextColor:okColor withTitle:rightText withFrame:CGRectMake(CGRectGetMaxX(self.cancelBtn.frame)+11, CGRectGetMaxY(self.tableView.frame)+56, self.mainWidth/2-16-5.5, wmz_GetHNum(72))];
    [self.okBtn setTitle:@"支付" forState:UIControlStateNormal];

    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(280*2), CGRectGetMaxY(self.okBtn.frame)+16)];
    
    return self.mainView;
}

//系统默认弹窗
- (id)AlertTypeSystemPushViewWithLeftTitle:(NSString*)leftText
                            rightTitle:(NSString*)rightText
                             headTitle:(NSString*)title
                             textTitle:(id) text
                        headTitleColor:(UIColor*)titleColor
                        textTitleColor:(UIColor*)textColor
                             backColor:(UIColor*)backColor
                            okBtnColor:(UIColor*)okColor
                        cancelBtnColor:(UIColor*)cancelColor{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    __block WMZAlert *weakSelf = self;
    if (self.leftButtonClickHandle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:leftText?:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.leftButtonClickHandle) {
                weakSelf.leftButtonClickHandle(nil);
            }
        }];
        [alert addAction:cancelAction];
    }
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:rightText?:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.rightButtonClickHandle) {
            weakSelf.rightButtonClickHandle(nil);
        }
    }];
    [alert addAction:okAction];
    return alert;
}

//系统底部弹窗
- (id)AlertTypeSystemSheetViewWithLeftTitle:(NSString*)leftText
                            rightTitle:(NSString*)rightText
                             headTitle:(NSString*)title
                             textTitle:(id) text
                        headTitleColor:(UIColor*)titleColor
                        textTitleColor:(UIColor*)textColor
                             backColor:(UIColor*)backColor
                            okBtnColor:(UIColor*)okColor
                        cancelBtnColor:(UIColor*)cancelColor{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleActionSheet];
    
    __block WMZAlert *weakSelf = self;
    if (self.leftButtonClickHandle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:leftText?:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.leftButtonClickHandle) {
                weakSelf.leftButtonClickHandle(nil);
            }
        }];
        [alert addAction:cancelAction];
    }
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:rightText?:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.rightButtonClickHandle) {
            weakSelf.rightButtonClickHandle(nil);
        }
    }];
    [alert addAction:okAction];
    return alert;
}

//默认自动消失弹窗
- (id)AlertTypeAutoViewWithLeftTitle:(NSString*)leftText
                            rightTitle:(NSString*)rightText
                             headTitle:(NSString*)title
                             textTitle:(id) text
                        headTitleColor:(UIColor*)titleColor
                        textTitleColor:(UIColor*)textColor
                             backColor:(UIColor*)backColor
                            okBtnColor:(UIColor*)okColor
                        cancelBtnColor:(UIColor*)cancelColor{
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(480), wmz_GetHNum(267)) withRadius:8.0f];
    [self setMaintextWithText:text WithTextColor:textColor WithNum:30 withFrame:CGRectMake(0, wmz_GetHNum(30), self.mainWidth-wmz_GetWNum(40), wmz_GetHNum(23)) isCenter:YES withFont:[UIFont systemFontOfSize:text_Font]];
    
    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(480), CGRectGetMaxY(self.mainText.frame)+wmz_GetHNum(30))];
    
    return self.mainView;
}

//支付弹窗
- (id)AlertTypemainViewWithLeftTitle:(NSString*)leftText
                            rightTitle:(NSString*)rightText
                             headTitle:(NSString*)title
                             textTitle:(id) text
                        headTitleColor:(UIColor*)titleColor
                        textTitleColor:(UIColor*)textColor
                             backColor:(UIColor*)backColor
                            okBtnColor:(UIColor*)okColor
                        cancelBtnColor:(UIColor*)cancelColor{
    NSDictionary *dicMoney = text;
    //监听键盘出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(560), wmz_GetHNum(267)) withRadius:8.0f];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setImage:[UIImage imageNamed:@"login_ic_close"] forState:UIControlStateNormal];
    self.closeBtn.frame = CGRectMake(wmz_GetWNum(20), wmz_GetHNum(20), wmz_GetWNum(50), wmz_GetWNum(50));
    [self.mainView addSubview:self.closeBtn];
    
    
    [self setTitleLabelWithTitle:title?:@"请输入支付密码" WithTextColor:titleColor?:RGBTEXT WithNum:5 withFrame:CGRectMake(wmz_GetWNum(80), wmz_GetHNum(25), self.mainWidth-wmz_GetWNum(160), wmz_GetHNum(31)) isCenter:NO];

    UIView *upLine = [self getLineViewWithColor:HEX_COLOR(0xF1F1F1) withFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(25), self.mainWidth, 1) withAlpha:1];
    [self.mainView addSubview:upLine];
    
    [self setMaintextWithText:[NSString stringWithFormat:@"￥%@",dicMoney[@"balance"]] WithTextColor:textColor WithNum:1 withFrame:CGRectMake(0, CGRectGetMaxY(upLine.frame)+wmz_GetHNum(30), self.mainWidth, wmz_GetHNum(80)) isCenter:YES withFont:[UIFont fontWithName:@"PingFang SC" size:40.0f]];
    
    
//    UIView *downLine = [self getLineViewWithColor:HEX_COLOR(0x999999) withFrame:CGRectMake(wmz_GetWNum(15), CGRectGetMaxY(self.mainText.frame)+wmz_GetHNum(30), self.mainWidth-wmz_GetWNum(30), 0.5f) withAlpha:0.5f];
//    [self.mainView addSubview:downLine];
    
    UILabel *lblMinMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, self.mainText.bottom+10, self.mainView.width, 12) title:[NSString stringWithFormat:@"额外扣除¥%@手续费",dicMoney[@"minMoney"]] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
    [self.mainView addSubview:lblMinMoney];
    
    self.payField = [HDTextFeild new];
    self.payField.frame = CGRectMake(wmz_GetWNum(32), CGRectGetMaxY(lblMinMoney.frame)+wmz_GetHNum(48), self.mainWidth-wmz_GetWNum(64), 0);
    self.payField.delegate = self;
    self.payField.textColor = [UIColor clearColor];
    self.payField.tintColor = [UIColor clearColor];
    self.payField.borderStyle = UITextBorderStyleNone;
//    [self.mainView sendSubviewToBack:self.payField];
    self.payField.keyboardType = UIKeyboardTypeNumberPad;
    [self.payField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.passView = [UIView new];
    self.passView.backgroundColor = [UIColor whiteColor];
    self.passView.frame = CGRectMake(wmz_GetWNum(32), CGRectGetMaxY(lblMinMoney.frame)+wmz_GetHNum(48), self.mainWidth-wmz_GetWNum(64), (self.mainWidth-wmz_GetWNum(64))/6);
    [self.mainView addSubview:self.passView];
    CGFloat passViewWidth = self.passView.frame.size.width;
    
    self.payField.height = self.passView.frame.size.height;
    [self.mainView addSubview:self.payField];
    [self.payField becomeFirstResponder];
    
    UILabel *tempLabel = nil;
    for (int i = 0; i<6; i++) {
        UILabel *password = [UILabel new];
        password.layer.masksToBounds = YES;
        password.layer.borderColor = HEX_COLOR(0xF1F1F1).CGColor;
        password.tag = 100+i;
        password.layer.borderWidth = 1.0f;
        password.textColor = textColor?:[UIColor blackColor];
        password.textAlignment = NSTextAlignmentCenter;
        password.text = @"";
        [password setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0f]];
        if (!tempLabel) {
            password.frame = CGRectMake(0, 0, passViewWidth/6, self.passView.frame.size.height);
        }else{
            password.frame = CGRectMake(CGRectGetMaxX(tempLabel.frame), 0, passViewWidth/6, self.passView.frame.size.height);
        }
        tempLabel = password;
        [self.passView addSubview:password];
    }
    
    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(560), CGRectGetMaxY(self.passView.frame)+wmz_GetHNum(40))];

    return self.mainView;
}

//吐丝弹窗显示在上部
- (id)AlertTypeToastViewWithLeftTitle:(NSString*)leftText
                            rightTitle:(NSString*)rightText
                             headTitle:(NSString*)title
                             textTitle:(id) text
                        headTitleColor:(UIColor*)titleColor
                        textTitleColor:(UIColor*)textColor
                             backColor:(UIColor*)backColor
                            okBtnColor:(UIColor*)okColor
                        cancelBtnColor:(UIColor*)cancelColor{

    
    [self setMainViewWithColor:backColor?:[UIColor lightGrayColor] withFrame:CGRectMake(0, 0, kDevice_Width, wmz_GetHNum(267)) withRadius:0];
    
    
    //判断toust显示的y值
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat needHight = statusRect.size.height;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UINavigationController *na = [(UITabBarController *)rootViewController selectedViewController];
        if ([na visibleViewController]) {
            needHight = NavigationBar_Height;
        }
        
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]){
        needHight = NavigationBar_Height;
    }
    

    [self setMaintextWithText:text WithTextColor:textColor WithNum:3 withFrame:CGRectMake(wmz_GetWNum(10), wmz_GetHNum(20), self.mainWidth-wmz_GetWNum(20), wmz_GetHNum(23)) isCenter:YES withFont:[UIFont systemFontOfSize:text_Font]];
    
    self.mainView.frame = CGRectMake(0, needHight, kDevice_Width, CGRectGetMaxY(self.mainText.frame)+wmz_GetHNum(20));
    return self.mainView;
}

//可输入内容的弹窗
- (id)AlertTypeWriteViewWithLeftTitle:(NSString*)leftText
                            rightTitle:(NSString*)rightText
                             headTitle:(NSString*)title
                             textTitle:(id) text
                        headTitleColor:(UIColor*)titleColor
                        textTitleColor:(UIColor*)textColor
                             backColor:(UIColor*)backColor
                            okBtnColor:(UIColor*)okColor
                        cancelBtnColor:(UIColor*)cancelColor{
    //监听键盘出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(560), wmz_GetHNum(267)) withRadius:10.0f];
    [self setTitleLabelWithTitle:title?:@"请输入内容" WithTextColor:titleColor?:[UIColor blackColor] WithNum:5 withFrame:CGRectMake(0, wmz_GetHNum(20), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(31)) isCenter:YES];
    
    self.alertTextView = [UITextView new];
    self.alertTextView.layer.cornerRadius = 8.0f;
    self.alertTextView.layer.masksToBounds = YES;
    self.alertTextView.backgroundColor = backColor?:HEX_COLOR(0xe0e0e0);
    self.alertTextView.frame = CGRectMake(wmz_GetWNum(20), CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(20), self.mainWidth-wmz_GetWNum(40),wmz_GetHNum(200));
    self.alertTextView.font = [UIFont systemFontOfSize:text_Font];
    self.alertTextView.textColor = textColor?:[UIColor blackColor];
    self.alertTextView.delegate = self;
    [self.alertTextView becomeFirstResponder];
    [self.mainView addSubview:self.alertTextView];
    

    [self setMaintextWithText:text?:@"请输入内容" WithTextColor:titleColor?:[UIColor whiteColor] WithNum:4 withFrame:CGRectMake(wmz_GetWNum(15), wmz_GetWNum(15), self.mainWidth, wmz_GetHNum(30)) isCenter:NO withFont:[UIFont systemFontOfSize:text_Font]];
    
    self.placeHolderText = self.mainText.text;
    
    
    UIView *line = [self getLineViewWithColor:HEX_COLOR(0x999999) withFrame:CGRectMake(0, CGRectGetMaxY(self.alertTextView.frame)+wmz_GetHNum(20), self.mainWidth, 0.5f) withAlpha:0.5f];
    [self.mainView addSubview:line];
    
    if (self.leftButtonClickHandle) {
        [self setCancelBtnWithTextColor:cancelColor withTitle:leftText withFrame:CGRectMake(0, CGRectGetMaxY(line.frame), self.mainWidth/2-0.25f, wmz_GetHNum(88))];
        [self.mainView addSubview:self.leftLine];
    }
    
    
   [self setOkBtnWithTextColor:okColor withTitle:rightText withFrame:CGRectMake(self.leftButtonClickHandle?CGRectGetMaxX(self.leftLine.frame):0, CGRectGetMaxY(line.frame), self.leftButtonClickHandle?self.mainWidth/2-0.25f:self.mainWidth, wmz_GetHNum(88))];

    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(560), CGRectGetMaxY(self.okBtn.frame))];
    
    return self.mainView;
}

//倒计时弹窗
- (id)AlertTypeTimeViewWithLeftTitle:(NSString*)leftText
                           rightTitle:(NSString*)rightText
                            headTitle:(NSString*)title
                            textTitle:(id) text
                       headTitleColor:(UIColor*)titleColor
                       textTitleColor:(UIColor*)textColor
                            backColor:(UIColor*)backColor
                           okBtnColor:(UIColor*)okColor
                       cancelBtnColor:(UIColor*)cancelColor{
    
    if (text) {
        if ([text integerValue]<=0) {
            return nil;
        }
    }
    
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(480), wmz_GetHNum(267)) withRadius:8.0f];
    [self setTitleLabelWithTitle:title?:@"倒计时" WithTextColor:titleColor?:[UIColor blackColor] WithNum:5 withFrame:CGRectMake(0, wmz_GetHNum(20), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(31)) isCenter:YES];
    [self setMaintextWithText:text?[WMZAlert getMMSSFromSS:text]:@"00 : 00 : 00" WithTextColor:textColor WithNum:25 withFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(39), self.mainWidth-wmz_GetWNum(40), wmz_GetHNum(23)) isCenter:YES withFont:[UIFont fontWithName:@"Helvetica-Bold" size:22.0f]];
    
    UIView *line = [self getLineViewWithColor:HEX_COLOR(0x999999) withFrame:CGRectMake(0, CGRectGetMaxY(self.mainText.frame)+wmz_GetHNum(56), self.mainWidth, 0.5f) withAlpha:0.5f];
    [self.mainView addSubview:line];
    
    [self setOkBtnWithTextColor:okColor withTitle:rightText withFrame:CGRectMake(0, CGRectGetMaxY(line.frame), self.mainWidth, wmz_GetHNum(88))];
 
    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(480), CGRectGetMaxY(self.okBtn.frame))];
    
    [self createTimer:text?:@"0"];
    
    return self.mainView;
}

//选择器弹窗
- (id)AlertTypeSelectViewWithLeftTitle:(NSString*)leftText
                          rightTitle:(NSString*)rightText
                           headTitle:(NSString*)title
                           textTitle:(id) text
                      headTitleColor:(UIColor*)titleColor
                      textTitleColor:(UIColor*)textColor
                           backColor:(UIColor*)backColor
                          okBtnColor:(UIColor*)okColor
                      cancelBtnColor:(UIColor*)cancelColor{
    if (![text isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self.dataArr = [NSArray arrayWithArray:text[@"arr"]];
    self.selectID = text[@"select"];
    [self addShadow];
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, wmz_GetWNum(686), wmz_GetHNum(278*2)) withRadius:8.0f];
    [self setTitleLabelWithTitle:title?:@"请选择" WithTextColor:titleColor?:[UIColor blackColor] WithNum:5 withFrame:CGRectMake(16, wmz_GetHNum(48), self.mainWidth-wmz_GetWNum(64), wmz_GetHNum(28)) isCenter:YES];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = HEX_COLOR(0xF5222D);
    UIView *upLine = [self getLineViewWithColor:HEX_COLOR(0xF1F1F1) withFrame:CGRectMake(16, CGRectGetMaxY(self.titleLabel.frame)+wmz_GetHNum(32), self.mainWidth-32, 1) withAlpha:1];
    [self.mainView addSubview:upLine];
    
    [self.mainView addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(upLine.frame), self.mainWidth,self.dataArr.count>=8?8*wmz_GetHNum(110):self.dataArr.count*wmz_GetHNum(110));
    
    [self setCancelBtnWithTextColor:cancelColor withTitle:leftText withFrame:CGRectMake(16, CGRectGetMaxY(self.tableView.frame)+56, self.mainWidth/2-16-5.5, wmz_GetHNum(72))];
    [self setOkBtnWithTextColor:okColor withTitle:rightText withFrame:CGRectMake(CGRectGetMaxX(self.cancelBtn.frame)+11, CGRectGetMaxY(self.tableView.frame)+56, self.mainWidth/2-16-5.5, wmz_GetHNum(72))];

    [self reSetMainViewFrame:CGRectMake(0, 0, wmz_GetWNum(686), CGRectGetMaxY(self.okBtn.frame)+16)];
    
    return self.mainView;
}


//分享弹窗
- (id)AlertTypeShareViewWithLeftTitle:(NSString*)leftText
                            rightTitle:(NSString*)rightText
                             headTitle:(NSString*)title
                             textTitle:(id) text
                        headTitleColor:(UIColor*)titleColor
                        textTitleColor:(UIColor*)textColor
                             backColor:(UIColor*)backColor
                            okBtnColor:(UIColor*)okColor
                        cancelBtnColor:(UIColor*)cancelColor{
    if (![text isKindOfClass:[NSArray class]]) {
        return nil;
    }
    self.shareArr = text;
    [self addShadow];
    //透明层添加点击事件
    UITapGestureRecognizer *tapShadow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    self.shadowView.userInteractionEnabled = YES;
    [self.shadowView addGestureRecognizer:tapShadow];
    
    [self setMainViewWithColor:backColor withFrame:CGRectMake(0, 0, kDevice_Width, wmz_GetHNum(84*2)) withRadius:0.0f];
//    [self setTitleLabelWithTitle:@"邀请好友" WithTextColor:RGBTEXT WithNum:5 withFrame:CGRectMake(wmz_GetWNum(15), wmz_GetHNum(20), self.mainWidth-wmz_GetWNum(30), wmz_GetHNum(31)) isCenter:NO];
    
    //title
    UILabel *titleLbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 16, self.mainView.width, 16) title:@"邀请好友" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
    [self.mainView addSubview:titleLbl];
    
    [self.mainView addSubview:self.shareView];
    self.shareView.frame = CGRectMake(0,CGRectGetMaxY(titleLbl.frame)+16, self.mainWidth , wmz_GetHNum(84*2));
    
    UIView *tempView = nil;
    for (int i = 0; i<self.shareArr.count; i++) {
        NSDictionary *dicIcon = self.shareArr[i];
        UIView *iconView = nil;
        if (i==0) {
           iconView =  [self shareListIconWithText:dicIcon[@"title"] WithImage:dicIcon[@"image"] withFrame:CGRectMake(0, 0, self.shareView.width/self.shareArr.count, wmz_GetHNum(60)) withTag:i+1000];
        }else{
         iconView =  [self shareListIconWithText:dicIcon[@"title"] WithImage:dicIcon[@"image"] withFrame:CGRectMake(CGRectGetMaxX(tempView.frame), tempView.y, self.shareView.width/self.shareArr.count, wmz_GetHNum(60)) withTag:i+1000];
        }
        tempView = iconView;
        [self.shareView addSubview:iconView];
        
        self.shareView.contentSize = CGSizeMake(CGRectGetMaxX(iconView.frame),wmz_GetHNum(84*2));
    }
    
    self.mainView.frame = CGRectMake(0, kDevice_Height-CGRectGetMaxY(self.shareView.frame), kDevice_Width, CGRectGetMaxY(self.shareView.frame));
    
    return self.mainView;
}

//取消按钮点击事件
- (void)cancelAction:(UIButton*)btn{
    if (self.leftButtonClickHandle) {
        self.leftButtonClickHandle(self);
    }
    [self closeView];
    
}

//确定按钮点击事件
- (void)okAction:(UIButton*)btn{
    if (self.rightButtonClickHandle) {
        if (self.type==AlertTypeWrite) {
            
            if (self.alertTextView.text.length>0) {
                self.rightButtonClickHandle(self.alertTextView.text);
            }else{
                NSLog(@"输入不能为空");
            }
        }else if (self.type==AlertTypeSelect){
            self.rightButtonClickHandle(self.selectID);
        }
        else if (self.type==AlertTypeTopay){
            self.rightButtonClickHandle(self.selectID);
        }
        else{
            self.rightButtonClickHandle(self);
        }
    }
    [self closeView];
}

//关闭按钮点击事件
- (void)closeAction:(UIButton*)btn{
    [self closeView];
    
}

//消失的处理
- (void)closeView{
    if ([self.payField isFirstResponder]) {
        [self.payField resignFirstResponder];
    }
    if ([self.alertTextView isFirstResponder]) {
        [self.alertTextView resignFirstResponder];
    }
    if (timer) {
         dispatch_source_cancel(timer);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//textField代理方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.type==AlertTypePay) {
     if ([NSString stringWithFormat:@"%@%@",textField.text,string].length<=6) {
        return YES;
     }
     return NO;
    }
    return YES;
}

//textField文字改变时的方法
-(void)textField1TextChange:(UITextField *)textField{
    
    for (int i = 0; i<[self.passView subviews].count; i++) {
        UILabel *la = [self.passView subviews][i];
        la.text = @"";
    }
    for (int i = 0; i<textField.text.length; i++) {
        UILabel *la = [self.passView viewWithTag:100+i];
        la.text = @"●";
    }
    if (textField.text.length==6) {
        if (self.rightButtonClickHandle) {
            //此处可以加上正则判断是否都数字
            self.rightButtonClickHandle(textField.text);
        }
        [self closeAction:nil];
    }
}

//textVie的代理方法
-(void)textViewDidChange:(UITextView*)textView
{
    
    if([textView.text length] == 0){
        
        self.mainText.text = self.placeHolderText;
        
    }else{
        
        self.mainText.text = @"";//这里给空
        
    }
}

//tableview代理
# pragma  mark tableView 代理
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.type == AlertTypeSelect) {
        [cell.contentView addSubview:[self createChangeWaiterPositionView:CGRectMake(0, 0, self.mainView.width, wmz_GetHNum(110)) title:self.dataArr[indexPath.row] indexPath:indexPath]];
    }
    if (self.type == AlertTypeQueueCheck) {
        [cell.contentView addSubview:[self createCheckQueueView:CGRectMake(0, 0, self.mainView.width, wmz_GetHNum(72)) infoDic:self.dataArr[indexPath.row] waitTimeDic:self.paiduiInfoDic indexPath:indexPath]];
    }
    if (self.type == AlertTypeTopay) {
        [cell.contentView addSubview:[self createPayCellView:CGRectMake(0, 0, self.mainView.width, wmz_GetHNum(120)) title:self.dataArr[indexPath.row] indexPath:indexPath]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == AlertTypeQueueCheck) {
        return wmz_GetHNum(72);
    }
    return wmz_GetHNum(110);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == AlertTypeSelect) {
        self.selectID = self.dataArr[indexPath.row];
        
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        for (int i=0; i<self.dataArr.count; i++) {
            UIImageView *image = (UIImageView *)[self.tableView viewWithTag:100+i];
            image.hidden = YES;
        }
        UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:100+indexPath.row];
        image.hidden = NO;
    }
    if (self.type == AlertTypeQueueCheck) {
        self.selectID = self.dataArr[indexPath.row];
        for (int i=0; i<self.dataArr.count; i++) {
            //背景图
            UIView *viewBack = (UIView *)[self.tableView viewWithTag:1000+i];
            viewBack.hidden = YES;
            //名字
            UILabel *lblName = (UILabel *)[self.tableView viewWithTag:2000+i];
            lblName.hidden = YES;
            //性别标志图片
            UIImageView *imageSex = (UIImageView *)[self.tableView viewWithTag:3000+i];
            imageSex.x = 24;
            //label服务中
            UILabel *lblText = (UILabel *)[self.tableView viewWithTag:4000+i];
            lblText.x = CGRectGetMaxX(imageSex.frame)+7;
        }
        //背景图
        UIView *viewBack = (UIView *)[self.tableView viewWithTag:1000+indexPath.row];
        viewBack.hidden = NO;
        //名字
        UILabel *lblName = (UILabel *)[self.tableView viewWithTag:2000+indexPath.row];
        lblName.hidden = NO;
        lblName.x = 24;
        //性别标志图片
        UIImageView *imageSex = (UIImageView *)[self.tableView viewWithTag:3000+indexPath.row];
        imageSex.x = CGRectGetMaxX(lblName.frame)+4;
        //label服务中
        UILabel *lblText = (UILabel *)[self.tableView viewWithTag:4000+indexPath.row];
        lblText.x = CGRectGetMaxX(imageSex.frame)+7;
    }
    if (self.type == AlertTypeTopay) {
        self.selectID = self.dataArr[indexPath.row];
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        for (int i=0; i<self.dataArr.count; i++) {
            UIImageView *image = (UIImageView *)[self.tableView viewWithTag:100+i];
            image.image = [UIImage imageNamed:@"pay_ic_checkbox"];
        }
        UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:100+indexPath.row];
        image.image = [UIImage imageNamed:@"pay_ic_checkbox_selected"];
    }
}

//键盘将要出现
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        switch (self.type) {
            case AlertTypePay:
            case AlertTypeWrite:
            {

                self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, kDevice_Height-(endFrame.size.height+wmz_GetHNum(70)+self.mainView.frame.size.height), self.mainView.frame.size.width, self.mainView.frame.size.height);

            }
                break;
                
            default:
                break;
        }
}

//返回文本的size 根据文本的width
+ (CGSize)returnSizeWithLabel:(UILabel*)label withRowHeight:(CGFloat)row{
    
    CGSize titleSize = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, label.numberOfLines==0?CGFLOAT_MAX:label.numberOfLines*(row+text_Font/3)) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size;
    return titleSize;
    
}


//传入 秒  得到 xx:xx:xx
+ (NSString *)getMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue];

    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];

    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];

    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];

    NSString *format_time = [NSString stringWithFormat:@"%@ : %@ : %@",str_hour,str_minute,str_second];
    
    return format_time;
    
}

//创建计时器
- (void)createTimer:(NSString *)totalTime{
    __block NSInteger seconds = [totalTime integerValue];
     __weak typeof(self)weakSelf = self;
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        seconds --;
        
        if (seconds<=0) {
            dispatch_source_cancel(self->timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf closeView];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.mainText.text = [WMZAlert getMMSSFromSS:[NSString stringWithFormat:@"%ld",seconds]];
            });
        }
    });
    dispatch_resume(timer);
    
    //如果需要进入后台 定时器也运行的话需要在AppDelegate的enterBackGoround里添加代码 看本项目手动添加
}

//懒加载taleview
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView =  [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.sectionFooterHeight = 56;
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

//标题
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:title_Font];
        _titleLabel.numberOfLines = 5;

    }
    return _titleLabel;
}

//背景
- (UIView *)mainView{
    if (!_mainView) {
        _mainView = [UIView new];
    }
    return _mainView;
}

//背景宽度
- (CGFloat)mainWidth{
    if (!_mainWidth) {
        _mainWidth = self.mainView.frame.size.width;
    }
    return _mainWidth;
}

//主体文本
- (UILabel *)mainText{
    if (!_mainText) {
        _mainText = [UILabel new];
        _mainText.textAlignment = NSTextAlignmentCenter;
    }
    return _mainText;
}

//取消按钮
- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _cancelBtn;
}

//确定按钮
- (UIButton *)okBtn{
    if (!_okBtn) {
        _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _okBtn;
}


//中间线
- (UIView *)leftLine{
    if (!_leftLine) {
        _leftLine = [UIView new];
        _leftLine.alpha = 1;
        _leftLine.backgroundColor = RGBCOLOR(221, 221, 221);
        _leftLine.frame = CGRectMake(CGRectGetMaxX(self.cancelBtn.frame), CGRectGetMinY(self.cancelBtn.frame), 1.0f, wmz_GetHNum(96));
    }
    return _leftLine;
}

//分享视图
- (UIScrollView *)shareView{
    if (!_shareView) {
        _shareView = [UIScrollView new];
        _shareView.showsVerticalScrollIndicator = NO;
        _shareView.showsHorizontalScrollIndicator = NO;
    }
    return _shareView;
}

//titleLabel 赋值各自属性
- (void)setTitleLabelWithTitle:(NSString*)title WithTextColor:(UIColor*)titleColor WithNum:(NSInteger)num withFrame:(CGRect)frame isCenter:(BOOL)center{
    self.titleLabel.textColor = titleColor?:[UIColor blackColor];
    self.titleLabel.text = title;
    self.titleLabel.font = [UIFont systemFontOfSize:title_Font];
    self.titleLabel.numberOfLines = num;
    self.titleLabel.frame = frame;
    CGSize labelSize = [WMZAlert returnSizeWithLabel:self.titleLabel withRowHeight:frame.size.height];
    self.titleLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, labelSize.height);
    if (center) {
        self.titleLabel.center = CGPointMake(self.mainView.center.x, self.titleLabel.center.y);
    }
    [self.mainView addSubview:self.titleLabel];
}


//mainView赋值属性
- (void)setMainViewWithColor:(UIColor*)backColor withFrame:(CGRect)frame withRadius:(CGFloat)num{
    self.mainView.layer.cornerRadius = num;
    self.mainView.layer.masksToBounds = YES;
    self.mainView.frame = frame;
    self.mainView.backgroundColor = backColor?:[UIColor whiteColor];
}

//mainText赋值
- (void)setMaintextWithText:(NSString*)text WithTextColor:(UIColor*)textColor WithNum:(NSInteger)num withFrame:(CGRect)frame isCenter:(BOOL)center withFont:(UIFont*)font{
    self.mainText.textColor = textColor?:[UIColor blackColor];
    self.mainText.text = text;
    self.mainText.font = font;
    self.mainText.numberOfLines = num;
    self.mainText.frame = frame;
    if (num!=1) {
        CGSize LabelSize = [WMZAlert returnSizeWithLabel:self.mainText withRowHeight:frame.size.height];
        self.mainText.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, LabelSize.height);
    }
    if (center) {
         self.mainText.center = CGPointMake(self.mainView.center.x, self.mainText.center.y);
    }
    if (self.type==AlertTypeWrite) {
        [self.alertTextView addSubview:self.mainText];
        self.mainText.textAlignment = NSTextAlignmentLeft;
    }else if(self.type == AlertTypeAcceptTask){
        [self.mainView addSubview:self.mainText];
        self.mainText.textAlignment = NSTextAlignmentLeft;
    }else{
        [self.mainView addSubview:self.mainText];
    }
}

//赋值cancelBtn
- (void)setCancelBtnWithTextColor:(UIColor*)cancelColor  withTitle:(NSString*)leftText withFrame:(CGRect)frame{
    [self.cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn setTitle:leftText?:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:cancelColor?:HEX_COLOR(0xF5222D) forState:UIControlStateNormal];
    self.cancelBtn.backgroundColor = [UIColor whiteColor];
    self.cancelBtn.frame = frame;
    if (_type != AlertTypeNornal && _type != AlertTypeShareWeixin && _type != AlertTypeTaoBao) {
        self.cancelBtn.layer.cornerRadius = 2;
        self.cancelBtn.layer.borderColor = HEX_COLOR(0xF5222D).CGColor;
        self.cancelBtn.layer.borderWidth = 1;
    }
    
    [self.mainView addSubview:self.cancelBtn];
}

//赋值okbtn
- (void)setOkBtnWithTextColor:(UIColor*)okColor withTitle:(NSString*)rightText withFrame:(CGRect)frame{
    self.okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.okBtn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.okBtn setTitle:rightText?:@"确定" forState:UIControlStateNormal];
    [self.okBtn setTitleColor:okColor?:HEX_COLOR(0xFFFFFF) forState:UIControlStateNormal];
    if (_type != AlertTypeNornal && _type != AlertTypeShareWeixin && _type != AlertTypeTaoBao) {
        self.okBtn.backgroundColor = HEX_COLOR(0xF5222D);
        self.okBtn.layer.cornerRadius = 2;
    }else{
        self.okBtn.backgroundColor = [UIColor whiteColor];
    }
    
    self.okBtn.frame = frame;
    [self.mainView addSubview:self.okBtn];
}

//line
- (UIView*)getLineViewWithColor:(UIColor*)lineColor withFrame:(CGRect)frame withAlpha:(CGFloat)alpha{
    UIView *line = [UIView new];
    line.alpha = alpha;
    line.backgroundColor = lineColor;
    line.frame = frame;
    return line;
}

//分享子视图
- (UIView*)shareListIconWithText:(NSString*)text WithImage:(NSString*)image withFrame:(CGRect)frame withTag:(NSInteger)tag{
    UIView *backView = [UIView new];
    backView.frame = frame;
    backView.backgroundColor = [UIColor clearColor];
    backView.tag = tag;
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageAction:)];
    [backView addGestureRecognizer:tap];
    
    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake(0, 0, wmz_GetWNum(80), wmz_GetWNum(80));
    imageView.image = [UIImage imageNamed:image];
    imageView.centerX = backView.width/2;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = (imageView.size.width)/2;
    imageView.clipsToBounds = YES;
    [backView addSubview:imageView];
    
    UILabel *la = [UILabel new];
    la.textAlignment = NSTextAlignmentCenter;
    la.font = [UIFont systemFontOfSize:12];
    la.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+wmz_GetHNum(16), backView.width, wmz_GetHNum(24));
    la.text = text;
    [backView addSubview:la];
    
    return backView;
}

//重新设置mainView的frame
- (void)reSetMainViewFrame:(CGRect)frame{
    self.mainView.frame = frame;
    self.mainView.center = self.view.center;
}

//分享视图图片点击
- (void)imageAction:(UITapGestureRecognizer*)sender{
    if (self.rightButtonClickHandle) {
        UIImageView *image = (UIImageView*)sender.view;
        for (int i = 0; i<self.shareArr.count; i++) {
            if (image.tag-1000==i) {
                self.rightButtonClickHandle(self.shareArr[i][@"title"]);
                [self closeView];
                break;
            }
        }
        
    }
}


#pragma mark ================== 自定义cell视图 =====================
//修改店员岗位cellview
-(UIView *)createChangeWaiterPositionView:(CGRect)frame title:(NSString *)title indexPath:(NSIndexPath *)indexPath{
    UIView *viewPosition = [[UIView alloc] initWithFrame:frame];
    viewPosition.backgroundColor = [UIColor clearColor];
    UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 150, 14) title:title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewPosition addSubview:lbltext];
    lbltext.centerY = wmz_GetHNum(110)/2;
    
    UIImageView *imageSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_ic_selected"]];
    imageSelect.centerY = 55/2;
    imageSelect.x = self.tableView.width-20-20;
    imageSelect.tag = 100+indexPath.row;
    imageSelect.hidden = YES;
    if ([title isEqualToString:self.selectID]) {
        imageSelect.hidden = NO;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, self.tableView.width-32, 1)];
    line.backgroundColor = RGBCOLOR(241, 241, 241);
    
    [viewPosition addSubview:line];
    [viewPosition addSubview:imageSelect];
    
    return viewPosition;
}

//查看排队进度cellview
-(UIView *)createCheckQueueView:(CGRect)frame infoDic:(NSDictionary *)dic waitTimeDic:(NSString *)dicWait indexPath:(NSIndexPath *)indexPath{
    UIView *viewPosition = [[UIView alloc] initWithFrame:frame];
    viewPosition.backgroundColor = [UIColor clearColor];
    
    
    UIView *viewback = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, wmz_GetHNum(72))];
    viewback.backgroundColor = RGBAlpha(239, 247, 249, 1);
    [viewPosition addSubview:viewback];
    viewback.tag = 1000+indexPath.row;
    viewback.hidden = YES;
    
    UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, 40, 12) title:dic[@"userName"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewPosition addSubview:lblName];
    lblName.tag = 2000+indexPath.row;
    lblName.centerY = wmz_GetHNum(72)/2;
    lblName.hidden = YES;
    
    UIImageView *imageSex = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sex_ic_male"]];
    imageSex.centerY = wmz_GetHNum(72)/2;
    imageSex.x = 24;
    imageSex.tag = 3000+indexPath.row;
    [viewPosition addSubview:imageSex];
    
    NSString *serviceStr = @"服务中";
    NSString *waitTimeStr = [NSString stringWithFormat:@"预计花费%ld分钟",[self.paiduiInfoDic[@"serviceTime"] integerValue]];
    if ([dic[@"orderStatus"] isEqualToString:@"queue"]) {
        serviceStr = @"排队中";
        waitTimeStr = [NSString stringWithFormat:@"预计等待%ld分钟",[self.paiduiInfoDic[@"queueTime"] integerValue]];
    }
    UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageSex.frame)+7, 0, 150, 12) title:serviceStr bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewPosition addSubview:lbltext];
    lbltext.tag = 4000+indexPath.row;
    lbltext.centerY = wmz_GetHNum(72)/2;
    
    UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(self.tableView.width-24-150, 0, 150, 12) title:waitTimeStr bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
    [viewPosition addSubview:lblTime];
    [lblTime sizeToFit];
    lblTime.x = self.tableView.width-24-lblTime.width;
    lblTime.centerY = wmz_GetHNum(72)/2;
    lblTime.tag = 4000+indexPath.row;
    
    return viewPosition;
}

//创建支付视图
-(UIView *)createPayCellView:(CGRect)frame title:(NSString *)title indexPath:(NSIndexPath *)indexPath{
    UIView *viewPay = [[UIView alloc] initWithFrame:frame];
    viewPay.backgroundColor = [UIColor clearColor];
    
    NSString *strPayimg = @"pay_ic_alipay";
    if ([title isEqualToString:@"微信支付"]) {
        strPayimg = @"pay_ic_wechat";
    }
    UIImageView *imagePay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strPayimg]];
    imagePay.centerY = wmz_GetHNum(120)/2;
    imagePay.x = wmz_GetWNum(32);
    [viewPay addSubview:imagePay];
    
    UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imagePay.frame)+8, 0, 150, 14) title:title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewPay addSubview:lbltext];
    lbltext.centerY = imagePay.centerY;
    
    NSString *selimgStr = @"pay_ic_checkbox_selected";
    self.selectID = self.dataArr[0];
    if (indexPath.row != 0) {
        selimgStr = @"pay_ic_checkbox";
    }
    UIImageView *imageSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:selimgStr]];
    imageSelect.centerY = 55/2;
    imageSelect.x = self.tableView.width-20-20;
    imageSelect.tag = 100+indexPath.row;
    [viewPay addSubview:imageSelect];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, wmz_GetHNum(120)-1, self.tableView.width-32, 1)];
    line.backgroundColor = RGBCOLOR(241, 241, 241);
    [viewPay addSubview:line];
    
    if (indexPath.row + 1 == self.dataArr.count) {
        line.x = 0;
        line.width = self.tableView.width;
    }
    
    return viewPay;
}


@end
