//
//  HDToolHelper.h
//  HairDress
//
//  Created by Apple on 2020/1/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMShare/UMShare.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDToolHelper : NSObject

+(void)saveData:(NSDictionary *)userInfo;

//延迟执行
+(void)delayMethodFourGCD:(NSInteger)timestamp method:(void(^)(void))sele;

//主线程执行
+(void)runMainQueue:(void(^)(void))func;

#pragma 正则匹配手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber;
#pragma 正则匹配用户密码6-18位数字和字母组合
+ (BOOL)checkPassword:(NSString *) password;
#pragma 正则匹配用户姓名,20位的中文或英文
+ (BOOL)checkUserName : (NSString *) userName;
#pragma 正则匹配用户身份证号
+ (BOOL)checkUserIdCard: (NSString *) idCard;
#pragma 正则匹配URL
+ (BOOL)checkURL : (NSString *) url;

//判断空字符串
+(BOOL)StringIsNullOrEmpty:(NSString *)str;
//表情符号的判断
+(BOOL)stringContainsEmoji:(NSString *)string;
+(BOOL)hasEmoji:(NSString*)string;
//判断是不是九宫格
+(BOOL)isNineKeyBoard:(NSString *)string;
//将字典中null值转化为空字符串
+ (NSMutableDictionary *)nullDicToDic:(NSDictionary *)dic;
//将阿拉伯数字转换为中文数字
+(NSString *)translationArabicNum:(NSInteger)arabicNum;
//图片的Url转成UIImage
+(UIImage *)getImageFromURL:(NSString *)fileURL;
//银行卡号加入* 并四个一个空格
+ (NSString *)getNewBankNumWitOldBankNum:(NSString *)bankNum;
//判断输入的字符串是否全为数字
+(BOOL)isInputShouldBeNumber:(NSString *)str;
//计算字符串长度
+(NSUInteger)unicodeLengthOfString:(NSString *) text;
//字符串过滤空格
+(NSString *)filterString:(NSString *)string;
//获取当前屏幕显示的viewcontroller
+(UIViewController *)getCurrentVC;
//跳转登录页
+(void)preToLoginView;
//返回到首页
+(void)chooseToJumpHome:(UIViewController *)currentVC selectIndex:(NSInteger)index;
//创建分享
+(void)createShareUI:(NSDictionary *)sharMesDic controller:(UIViewController *)viewCon;
//分享图片
+(void)shareImage:(UMSocialPlatformType)platformType thumbImage:(UIImage *)thumbImage shareImage:(UIImage *)shareImage controller:(UIViewController *)viewCon;
//弹出第三方地图
+(void)showMapsWithLat:(NSString *)lat longt:(NSString *)lon;

@end

NS_ASSUME_NONNULL_END
