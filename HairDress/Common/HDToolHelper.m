//
//  HDToolHelper.m
//  HairDress
//
//  Created by Apple on 2020/1/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDToolHelper.h"
#import "MHActionSheet.h"
#import <MapKit/MapKit.h>

@implementation HDToolHelper

+(void)saveData:(NSDictionary *)userInfo{
    [HDUserDefaultMethods saveData:userInfo[@"id"] andKey:@"userId"];
    [HDUserDefaultMethods saveData:userInfo[@"storePost"] andKey:@"storePost"];
    [HDUserDefaultMethods saveData:userInfo[@"storeId"] andKey:@"storeId"];
    [HDUserDefaultMethods saveData:userInfo[@"userToken"] andKey:@"userToken"];
    [HDUserDefaultMethods saveData:userInfo[@"gender"] andKey:@"gender"];
    [HDUserDefaultMethods saveData:userInfo[@"historyBalance"] andKey:@"historyBalance"];
    [HDUserDefaultMethods saveData:userInfo[@"parentId"] andKey:@"parentId"];
    [HDUserDefaultMethods saveData:userInfo[@"parentTree"] andKey:@"parentTree"];
    [HDUserDefaultMethods saveData:userInfo[@"accessToken"] andKey:@"accessToken"];
    [HDUserDefaultMethods saveData:userInfo[@"accessTokenTime"] andKey:@"accessTokenTime"];
    [HDUserDefaultMethods saveData:userInfo[@"account"] andKey:@"account"];
    [HDUserDefaultMethods saveData:userInfo[@"authTime"] andKey:@"authTime"];
    [HDUserDefaultMethods saveData:userInfo[@"balance"] andKey:@"balance"];
    [HDUserDefaultMethods saveData:userInfo[@"bankName"] andKey:@"bankName"];
    [HDUserDefaultMethods saveData:userInfo[@"bankNo"] andKey:@"bankNo"];
    [HDUserDefaultMethods saveData:userInfo[@"createTime"] andKey:@"createTime"];
    [HDUserDefaultMethods saveData:userInfo[@"equipmentNo"] andKey:@"equipmentNo"];
    [HDUserDefaultMethods saveData:userInfo[@"expireTime"] andKey:@"expireTime"];
    [HDUserDefaultMethods saveData:userInfo[@"fatherPhone"] andKey:@"fatherPhone"];
    [HDUserDefaultMethods saveData:userInfo[@"feature"] andKey:@"feature"];
    [HDUserDefaultMethods saveData:userInfo[@"graFatherPhone"] andKey:@"graFatherPhone"];
    [HDUserDefaultMethods saveData:userInfo[@"graParentId"] andKey:@"graParentId"];
    [HDUserDefaultMethods saveData:userInfo[@"headImg"] andKey:@"headImg"];
    [HDUserDefaultMethods saveData:userInfo[@"imToken"] andKey:@"imToken"];
    [HDUserDefaultMethods saveData:userInfo[@"isLimit"] andKey:@"isLimit"];
    [HDUserDefaultMethods saveData:userInfo[@"isOldMember"] andKey:@"isOldMember"];
    [HDUserDefaultMethods saveData:userInfo[@"isPartner"] andKey:@"isPartner"];
    [HDUserDefaultMethods saveData:userInfo[@"isRegister"] andKey:@"isRegister"];
    [HDUserDefaultMethods saveData:userInfo[@"isSuperPartner"] andKey:@"isSuperPartner"];
    [HDUserDefaultMethods saveData:userInfo[@"jdPid"] andKey:@"jdPid"];
    [HDUserDefaultMethods saveData:userInfo[@"nickName"] andKey:@"nickName"];
    [HDUserDefaultMethods saveData:userInfo[@"oldParentId"] andKey:@"oldParentId"];
    [HDUserDefaultMethods saveData:userInfo[@"password"] andKey:@"password"];
    [HDUserDefaultMethods saveData:userInfo[@"payPassword"] andKey:@"payPassword"];
    [HDUserDefaultMethods saveData:userInfo[@"pddPid"] andKey:@"pddPid"];
    [HDUserDefaultMethods saveData:userInfo[@"phone"] andKey:@"phone"];
    [HDUserDefaultMethods saveData:userInfo[@"pid"] andKey:@"pid"];
    [HDUserDefaultMethods saveData:userInfo[@"registerTime"] andKey:@"registerTime"];
    [HDUserDefaultMethods saveData:userInfo[@"relationAuthUrl"] andKey:@"relationAuthUrl"];
    [HDUserDefaultMethods saveData:userInfo[@"relationId"] andKey:@"relationId"];
    [HDUserDefaultMethods saveData:userInfo[@"sid"] andKey:@"sid"];
    [HDUserDefaultMethods saveData:userInfo[@"status"] andKey:@"status"];
    [HDUserDefaultMethods saveData:userInfo[@"storeStartTime"] andKey:@"storeStartTime"];
    [HDUserDefaultMethods saveData:userInfo[@"taoId"] andKey:@"taoId"];
    [HDUserDefaultMethods saveData:userInfo[@"taoNick"] andKey:@"taoNick"];
    [HDUserDefaultMethods saveData:userInfo[@"teamNum"] andKey:@"teamNum"];
    [HDUserDefaultMethods saveData:userInfo[@"unionId"] andKey:@"unionId"];
    [HDUserDefaultMethods saveData:userInfo[@"userLevel"] andKey:@"userLevel"];
    [HDUserDefaultMethods saveData:userInfo[@"userName"] andKey:@"userName"];
    [HDUserDefaultMethods saveData:userInfo[@"userTag"] andKey:@"userTag"];
    [HDUserDefaultMethods saveData:userInfo[@"userType"] andKey:@"userType"];
    [HDUserDefaultMethods saveData:userInfo[@"openId"] andKey:@"openId"];
    [HDUserDefaultMethods saveData:userInfo[@"webOpenId"] andKey:@"webOpenId"];
    [HDUserDefaultMethods saveData:userInfo[@"wxImg"] andKey:@"wxImg"];
    [HDUserDefaultMethods saveData:userInfo[@"wxNo"] andKey:@"wxNo"];
    [HDUserDefaultMethods saveData:userInfo[@"serviceTenet"] andKey:@"serviceTenet"];
}

//延迟执行
+(void)delayMethodFourGCD:(NSInteger)timestamp method:(void(^)(void))sele{
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timestamp * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        if (sele) {
            sele();
        }
    });
}

//主线程执行
+(void)runMainQueue:(void(^)(void))func{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (func) {
            func();
        }
    });
}

#pragma 正则匹配手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber
{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}


#pragma 正则匹配用户密码6-18位数字和字母组合
+ (BOOL)checkPassword:(NSString *) password
{
//    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,32}";
    NSString *pattern = @"^(?![a-zA-Z]+$)[a-zA-Z0-9]{6,32}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

#pragma 正则匹配用户姓名,20位的中文或英文
+ (BOOL)checkUserName : (NSString *) userName
{
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5]{1,20}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:userName];
    return isMatch;
}


#pragma 正则匹配用户身份证号15或18位
+ (BOOL)checkUserIdCard: (NSString *) idCard
{
    NSString *pattern = @"(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:idCard];
    return isMatch;
}

#pragma 正则匹员工号,12位的数字
+ (BOOL)checkEmployeeNumber : (NSString *) number
{
    NSString *pattern = @"^[0-9]{12}";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:number];
    return isMatch;
    
}

#pragma 正则匹配URL
+ (BOOL)checkURL : (NSString *) url
{
    NSString *pattern = @"^[0-9A-Za-z]{1,50}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:url];
    return isMatch;
}

//判断空字符串
+(BOOL)StringIsNullOrEmpty:(NSString *)str
{
    return (str == nil || [str isKindOfClass:[NSNull class]] || str.length == 0 || [str isEqualToString:@"<null>"] ||[[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0);
}

//表情符号的判断
+(BOOL)stringContainsEmoji:(NSString *)string {
   
   __block BOOL returnValue = NO;
   [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
    ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
            
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
   
   return returnValue;
}
/**
*  判断字符串中是否存在emoji
* @param string 字符串
* @return YES(含有表情)
*/
+(BOOL)hasEmoji:(NSString*)string{
   NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
   NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
   BOOL isMatch = [pred evaluateWithObject:string];
   return isMatch;
}
/**
判断是不是九宫格
@param string  输入的字符
@return YES(是九宫格拼音键盘)
*/
+(BOOL)isNineKeyBoard:(NSString *)string{
   NSString *other = @"➋➌➍➎➏➐➑➒";
   int len = (int)string.length;
   for(int i=0;i<len;i++)
   {
       if(!([other rangeOfString:string].location != NSNotFound))
           return NO;
   }
   return YES;
}

//将字典中null值转化为空字符串
+ (NSMutableDictionary *)nullDicToDic:(NSDictionary *)dic{
    
    NSMutableDictionary *resultDic = [@{} mutableCopy];
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return resultDic;
    }
    for (NSString *key in [dic allKeys]) {
        id obj = (id)[dic objectForKey:key];
        if ([obj isKindOfClass:[NSNull class]]) {
            [resultDic setValue:@"" forKey:key];
        }else{
            [resultDic setValue:[dic objectForKey:key] forKey:key];
        }
    }
    return resultDic;
}

/**
 *  将阿拉伯数字转换为中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum
{
    NSString *arabicNumStr = [NSString stringWithFormat:@"%ld",(long)arabicNum];
    NSArray *arabicNumeralsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chineseNumeralsArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chineseNumeralsArray forKeys:arabicNumeralsArray];
    
    if (arabicNum < 20 && arabicNum > 9) {
        if (arabicNum == 10) {
            return @"十";
        }else{
            NSString *subStr1 = [arabicNumStr substringWithRange:NSMakeRange(1, 1)];
            NSString *a1 = [dictionary objectForKey:subStr1];
            NSString *chinese1 = [NSString stringWithFormat:@"十%@",a1];
            return chinese1;
        }
    }else{
        NSMutableArray *sums = [NSMutableArray array];
        for (int i = 0; i < arabicNumStr.length; i ++)
        {
            NSString *substr = [arabicNumStr substringWithRange:NSMakeRange(i, 1)];
            NSString *a = [dictionary objectForKey:substr];
            NSString *b = digits[arabicNumStr.length -i-1];
            NSString *sum = [a stringByAppendingString:b];
            if ([a isEqualToString:chineseNumeralsArray[9]])
            {
                if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
                {
                    sum = b;
                    if ([[sums lastObject] isEqualToString:chineseNumeralsArray[9]])
                    {
                        [sums removeLastObject];
                    }
                }else
                {
                    sum = chineseNumeralsArray[9];
                }
                
                if ([[sums lastObject] isEqualToString:sum])
                {
                    continue;
                }
            }
            
            [sums addObject:sum];
        }
        NSString *sumStr = [sums  componentsJoinedByString:@""];
        NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
        return chinese;
    }
}

//将图片URL转化成UIImage
+(UIImage *)getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

//银行卡号加入* 并四个一个空格
+ (NSString *)getNewBankNumWitOldBankNum:(NSString *)bankNum{
    NSMutableString *mutableStr;
    if (bankNum.length) {
    mutableStr = [NSMutableString stringWithString:bankNum];
    for (int i = 0 ; i < mutableStr.length; i ++) {
        if (i>2&&i<mutableStr.length - 3) {
            [mutableStr replaceCharactersInRange:NSMakeRange(i, 1) withString:@"*"];
        }
    }
    NSString *text = mutableStr;
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *newString = @"";
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, 4)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 4) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 4)];
    }
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    return newString;
  }
   return bankNum;
}

//字符串过滤空格
+(NSString *)filterString:(NSString *)string{
    //过滤字符串前后的空格
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //过滤中间空格
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

//判断输入的字符串是否全为数字
+(BOOL)isInputShouldBeNumber:(NSString *)str{
   if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

//按照中文两个字符，英文数字一个字符计算字符数
+(NSUInteger) unicodeLengthOfString: (NSString *) text {
     NSUInteger asciiLength = 0;
     for (NSUInteger i = 0; i < text.length; i++) {
     unichar uc = [text characterAtIndex: i];
     asciiLength += isascii(uc) ? 1 : 2;
     }
     return asciiLength;
}

//获取当前屏幕显示的viewcontroller
+(UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *rootVC = window.rootViewController;
    do {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)rootVC;
            UIViewController *vc = [navi.viewControllers lastObject];
            result = vc;
            rootVC = vc.presentedViewController;
            continue;
        } else if([rootVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)rootVC;
            result = tab;
            rootVC = [tab.viewControllers objectAtIndex:tab.selectedIndex];
            continue;
        } else if([rootVC isKindOfClass:[UIViewController class]]) {
            result = rootVC;
            rootVC = nil;
        }
    } while (rootVC != nil);
    return result;
}

//跳转登录页
+(void)preToLoginView{
    dispatch_async(dispatch_get_main_queue(), ^{
        HDBaseNavViewController *preloginVC = [[HDBaseNavViewController alloc] initWithRootViewController:[HDPreLoginViewController new]];
        preloginVC.modalPresentationStyle = 0;
        UIViewController *currentVC = [HDToolHelper getCurrentVC];
        [currentVC presentViewController:preloginVC animated:YES completion:nil];
    });
}

//返回到首页
+(void)chooseToJumpHome:(UIViewController *)currentVC selectIndex:(NSInteger)index{
    
    UITabBarController *rootTab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    rootTab.selectedIndex = index;
    
//    UIViewController *currentVC = [self getCurrentVC];
    if (currentVC.presentingViewController) {
       [currentVC dismissViewControllerAnimated:NO completion:^{
            // 此处为注意点，处理当前界面是先push再modal出来而显示的控制器（处理方式：先dismiss，再pop）如果获取的currentVC.presentingViewController是UITabBarController，则无法进行pop操作了。
            if ([currentVC.presentingViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navi = (UINavigationController *)currentVC.presentingViewController;
                [navi popToRootViewControllerAnimated:NO];
            }
        }];
    } else {
        [currentVC.navigationController popToRootViewControllerAnimated:NO];
    }
}

//创建分享
+(void)createShareUI:(NSDictionary *)sharMesDic controller:(UIViewController *)viewCon{
    NSArray *sharePlates = @[
                            @{@"title":@"微信",@"image":@"share_ic_wechat"},
                            @{@"title":@"朋友圈",@"image":@"share_ic_friends"},
                            @{@"title":@"QQ",@"image":@"share_ic_qq"},
                            @{@"title":@"QQ空间",@"image":@"share_ic_qqzone"}
                            ];
    [[WMZAlert shareInstance] showAlertWithType:AlertTypeShare headTitle:@"邀请好友" textTitle:sharePlates viewController:viewCon leftHandle:^(id anyID) {

    } rightHandle:^(id anyID) {
        if ([anyID isEqualToString:@"微信"]) {
            [self shareAction:UMSocialPlatformType_WechatSession withSharDic:sharMesDic controller:viewCon];
        }
        if ([anyID isEqualToString:@"朋友圈"]) {
            [self shareAction:UMSocialPlatformType_WechatTimeLine withSharDic:sharMesDic controller:viewCon];
        }
        if ([anyID isEqualToString:@"QQ"]) {
            [self shareAction:UMSocialPlatformType_QQ withSharDic:sharMesDic controller:viewCon];
        }
        if ([anyID isEqualToString:@"QQ空间"]) {
            [self shareAction:UMSocialPlatformType_Qzone withSharDic:sharMesDic controller:viewCon];
        }
    }];
}

//分享
+(void)shareAction:(UMSocialPlatformType)platformType withSharDic:(NSDictionary *)dic controller:(UIViewController *)viewCon{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:dic[@"title"] descr:dic[@"shareTitle"] thumImage:dic[@"subImage"]];
    //设置网页地址
    shareObject.webpageUrl = dic[@"url"];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
//    UMShareImageObject *iamgeO = [[UMShareImageObject alloc] init];
//    [iamgeO setShareImage:[UIImage imageNamed:@""]];
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewCon completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            [SVHUDHelper showDarkWarningMsg:@"分享失败"];
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}

+(void)shareImage:(UMSocialPlatformType)platformType thumbImage:(UIImage *)thumbImage shareImage:(UIImage *)shareImage controller:(UIViewController *)viewCon{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    shareObject.thumbImage = thumbImage;
    [shareObject setShareImage:shareImage];
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewCon completion:^(id result, NSError *error) {
        if (error) {
            [SVHUDHelper showDarkWarningMsg:@"分享失败"];
        }else{
            [SVHUDHelper showDarkWarningMsg:@"分享成功"];
        }
    }];
}

//弹出第三方地图
+(void)showMapsWithLat:(NSString *)lat longt:(NSString *)lon{
    NSMutableArray *arrMaps = [NSMutableArray new];
    NSArray *arr = [self getInstalledMapAppWithEndLocationWithLat:lat longt:lon];
    for (NSDictionary *dic in arr) {
        [arrMaps addObject:dic[@"title"]];
    }
    MHActionSheet *actionSheet = [[MHActionSheet alloc] initSheetWithTitle:nil style:MHSheetStyleWeiChat itemTitles:arrMaps];
        [actionSheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
            if ([title isEqualToString:@"苹果地图"]) {
                [self navAppleMapWithLat:lat longt:lon];
            }else{
                NSDictionary*dic = arr[index];
                NSString *urlString = dic[@"url"];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString:urlString]];
            }
    }];
}

//获取第三方地图
+(NSArray*)getInstalledMapAppWithEndLocationWithLat:(NSString *)lat longt:(NSString *)lon{
    NSMutableArray*maps = [NSMutableArray array];
    //苹果地图
    NSMutableDictionary*iosMapDic = [NSMutableDictionary dictionary];
    iosMapDic[@"title"] =@"苹果地图";
    [maps addObject:iosMapDic];
    //百度地图
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSMutableDictionary*baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] =@"百度地图";
        NSString*urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=北京&mode=driving&coord_type=gcj02",[lat floatValue], [lon floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        baiduMapDic[@"url"] = urlString;

        [maps addObject:baiduMapDic];
    }

    //高德地图
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSMutableDictionary*gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[@"title"] =@"高德地图";
        NSString*urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"导航功能",@"nav123456",[lat floatValue], [lon floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        gaodeMapDic[@"url"] = urlString;
        [maps addObject:gaodeMapDic];
    }

    //谷歌地图
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {

        NSMutableDictionary*googleMapDic = [NSMutableDictionary dictionary];
        googleMapDic[@"title"] =@"谷歌地图";
        NSString*urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"导航测试",@"nav123456",[lat floatValue], [lon floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        googleMapDic[@"url"] = urlString;

        [maps addObject:googleMapDic];
    }

    //腾讯地图
    if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {

        NSMutableDictionary*qqMapDic = [NSMutableDictionary dictionary];
        qqMapDic[@"title"] =@"腾讯地图";
        NSString*urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=终点&coord_type=1&policy=0",[lat floatValue], [lon floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        qqMapDic[@"url"] = urlString;
        [maps addObject:qqMapDic];
    }
    return maps;
}


//苹果地图
+(void)navAppleMapWithLat:(NSString *)lat longt:(NSString *)lon
{
    CLLocationCoordinate2D gps = CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]);
    MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:gps addressDictionary:nil]];
    NSArray *items = @[currentLoc,toLocation];
    NSDictionary *dic = @{
                          MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                          MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                          MKLaunchOptionsShowsTrafficKey : @(YES)
                          };
    
    [MKMapItem openMapsWithItems:items launchOptions:dic];
}

@end
