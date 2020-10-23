//
//  Macro.h
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

//常量
#define KLoadDataBase @"ReloadNewDataNotice"

#pragma mark - 尺寸

#define KEYWINDOW [UIApplication sharedApplication].keyWindow

//弱引用
#define WeakSelf  __weak __typeof(&*self)weakSelf = self

//是否是IPhone_x
#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kDevice_Is_iPhoneX kSCREEN_WIDTH >=375.0f && kSCREEN_HEIGHT >=812.0f&& kIs_iphone
//缩放比例系数
#define SCALE (kSCREEN_WIDTH/375.0)
#define HEIGHT_SCALE (kSCREEN_HEIGHT/667.0)

//#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//数字字体
#define NUMFONT(f) [UIFont fontWithName:@"DINAlternate-Bold" size:f]
//标题字体
#define TEXT_SC_TFONT(a,f) [UIFont fontWithName:a size:f]

#define TEXT_SC_Semibold @"PingFangSC-Semibold"
#define TEXT_SC_Regular @"PingFangSC-Regular"
#define TEXT_SC_Medium @"PingFangSC-Medium"


//状态栏高度
#define STATUSBARHIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

//导航栏高度
#define NAVHIGHT (STATUSBARHIGHT + 44.0)

//屏宽
#ifndef kSCREEN_WIDTH
#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif

//屏高
#ifndef kSCREEN_HEIGHT
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif

//tarbar高度
#define KTarbarHeight  (kDevice_Is_iPhoneX ? 83 : 49)

//TarBar高度
#define KTabbarSafeBottomMargin  (kDevice_Is_iPhoneX ? 34 : 0)

//间距
#define GAP 20

#pragma mark - 颜色

#define RGB16(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define RGB16(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

//HEX颜色命名
#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

//自定义颜色
#define RGBAlpha(r, g, b, a)     [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

//遮罩层颜色
#define RGBSHADE [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];

//灰色线条颜色
#define RGBLINE HexRGBAlpha(0xF9F9F9, 1)//灰色线条颜色
//按钮layer线条
#define RGBBtnLayer HexRGBAlpha(0xD8D8D8, 1)//灰色线条颜色

//浅色线条颜色
#define RGBLIGHTLINE [UIColor colorWithRed:(210 / 255.0) green:(210 / 255.0) blue:(210 / 255.0) alpha:0.3]

//主颜色 红色
#define RGBMAIN HexRGBAlpha(0xE21A43,1)
//#define RGBMAIN HexRGBAlpha(0xF5222D,1)

//背景颜色 灰色
#define RGBBG [UIColor colorWithRed:(249 / 255.0) green:(249 / 255.0) blue:(249 / 255.0) alpha:1]

//副标题/不可点击文字
#define RGBSUBTITLE HexRGBAlpha(0x999999,1)

//可点击文字
#define RGBCLICKTEXT HexRGBAlpha(0xA3B4BF,1)

//重要信息文字
#define RGBIMPTEXT HexRGBAlpha(0x3A464E,1)

//灰色字体颜色
#define RGBTEXT     [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]

//浅灰色字体颜色
#define RGBTEXTINFO     [UIColor colorWithRed:(153 / 255.0) green:(153 / 255.0) blue:(153 / 255.0) alpha:1]
//浅灰色字体颜色
#define RGBLIGHT_TEXTINFO     [UIColor colorWithRed:(102 / 255.0) green:(102 / 255.0) blue:(102 / 255.0) alpha:1]


#ifdef DEBUG
#   define DTLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
#   define DTLog(...)
#endif

//是否可升级团长：T是，F否
#define IS_UPGRADE @"isUpgrade"

//通知类型
#define NOTICE_TYPE_ALIPAYSUCCESS @"alipaysuccess"//支付宝支付成功通知
#define NOTICE_TYPE_WXPAYSUCCESS @"wxpaysuccess"//微信支付成功通知
#define NOTICE_TYPE_WXPAYCANCEL @"wxpaycancel"//微信支付取消通知
#define NOTICE_TYPE_WXPAYFAIL @"wxpayfail"//微信支付失败通知
#define NOTICE_TYPE_WXBINDSUCCESS @"weiChatBindOK"//微信绑定成功通知
#define NOTICE_TYPE_WXLOGINSUCCESS @"weiChatLoginOK"//微信登录成功通知

// 第三方配置
//腾讯地图
#define TencentMapKey @"LLVBZ-VOKKX-DRO4Q-ZS5FF-4X2UE-LCB66"
//阿里百川
#define ALIBC_APPKEY @"28454625"
//微信
#define WXAPP_ID @"wx62f832be5230a7be"
#define WXAPP_SECRET @"cbb8eabeae1bd2f5dd6e05f6a7e3042e"
//QQ
#define QQAPP_ID @"101858679"
#define QQAPP_KEY @"e79aeec8047ecc8f2f51371b50c153de"

//友盟
#define UMAPP_KEY @"5e43b6de4ca357bee2000029"

//七鱼
#define QIYU_APP_KEY @"8b21276e1520313881f93d2818595e28"

//极光
#define JPUSH_APP_KEY @"1c928d1b426262ccf3487004"
#define JPUSH_REGID @"jpushID"

//
#define UNIVERSAL_LINKS @"https://cl.chaoliuapp.com/"


#endif /* Macro_h */
