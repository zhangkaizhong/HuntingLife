//
//  AppDelegate+ThirdParty.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "AppDelegate+ThirdParty.h"

@implementation AppDelegate (ThirdParty)

-(void)regiterWX{
    [WXApi registerApp:WXAPP_ID universalLink:@"https://cl.chaoliuapp.com/clapp/"];
    
    [UMConfigure initWithAppkey:UMAPP_KEY channel:@"App Store"];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WXAPP_ID appSecret:WXAPP_SECRET redirectURL:@"https://www.umeng.com/social"];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAPP_ID appSecret:QQAPP_KEY redirectURL:@"https://www.umeng.com/social"];
    
    [UMSocialGlobal shareInstance].universalLinkDic = @{
        @(UMSocialPlatformType_QQ):UNIVERSAL_LINKS,
        @(UMSocialPlatformType_WechatSession):@"https://cl.chaoliuapp.com/clapp/"
    };
}

//七鱼
-(void)registerQiYu{
    [[QYSDK sharedSDK] registerAppId:QIYU_APP_KEY appName:@"巢流"];
}

//阿里百川
-(void)setupAlibc{
//    [[AlibcTradeSDK sharedInstance] setDebugLogOpen:YES];
//    [[AlibcTradeSDK sharedInstance] setIsvAppName:@"baichuanDemo"];
//    [[AlibcTradeSDK sharedInstance] setIsvVersion:@"2.2.2"];
    [[AlibcTradeSDK sharedInstance] asyncInitWithSuccess:^{
        DTLog(@"百川SDK初始化成功");
    } failure:^(NSError *error) {
        DTLog(@"百川SDK初始化失败");
    }];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if (@available(iOS 9.0, *)) {
        __unused BOOL isHandledByALBBSDK=[[AlibcTradeSDK sharedInstance] application:app openURL:url options:options];
        DTLog(@"阿里淘宝授权成功");
    } else {
        // Fallback on earlier versions
    }//处理其他app跳转到自己的app，如果百川处理过会返回YES
   if ([url.host isEqualToString:@"oauth"]){//微信登录
         return [WXApi handleOpenURL:url delegate:self];
   }
   if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([PayManager shareInstance].callback) {
                [PayManager shareInstance].callback(resultDic);
                [PayManager shareInstance].callback = nil;
            }
        }];
    }
//    if ([[AlibcTradeSDK sharedInstance] application:app openURL:url options:options]) {
//        DTLog(@"阿里淘宝授权成功");
//    }
    
    
//    if ([url.host isEqualToString:@"pay"]){ //微信支付的回调
//        NSString *result = [url absoluteString];
//        NSArray *array = [result componentsSeparatedByString:@"="];
//        NSString *resultNumber = [array lastObject];
//        if ([resultNumber integerValue] == 0){ //成功
//            //发送支付成功的通知
//            [SVHUDHelper showDarkWarningMsg:@"支付成功"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_TYPE_WXPAYSUCCESS object:nil];
//        }else if ([resultNumber integerValue] == -1) { //错误
//            //发送支付失败的通知
//            [SVHUDHelper showDarkWarningMsg:@"支付失败"];
////            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_TYPE_WXPAYFAIL object:nil];
//        }else if ([resultNumber integerValue] == -2){ //用户取消
//            //发送支付取消的通知
//            [SVHUDHelper showDarkWarningMsg:@"支付取消"];
////            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_TYPE_WXPAYCANCEL object:nil];
//        }
//    }
    return YES;
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    // 如果百川处理过会返回YES
    if (![[AlibcTradeSDK sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation]) {
        // 处理其他app跳转到自己的app
        DTLog(@"阿里淘宝授权成功");
    }
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([PayManager shareInstance].callback) {
                [PayManager shareInstance].callback(resultDic);
                [PayManager shareInstance].callback = nil;
            }
        }];
        
        return YES;
    }
    
    return [WXApi handleOpenURL:url delegate:self];
}

//微信回调代理
- (void)onResp:(BaseResp *)resp{
    // =============== 获得的微信登录授权回调 ============
    if ([resp isMemberOfClass:[SendAuthResp class]])  {
        
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode != 0 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVHUDHelper showDarkWarningMsg:@"微信授权失败"];
            });
            return;
        }
        //授权成功获取 OpenId
        NSString *code = aresp.code;
        [self getWeiXinOpenId:code];
    }
    // =============== 获得的微信支付回调 ============
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        if (resp.errCode == 0){ //成功
            //发送支付成功的通知
            [SVHUDHelper showDarkWarningMsg:@"支付成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_TYPE_WXPAYSUCCESS object:nil];
        }else if (resp.errCode == -1) { //错误
            //发送支付失败的通知
            [SVHUDHelper showDarkWarningMsg:@"支付失败"];
        }else if (resp.errCode == -2){ //用户取消
            //发送支付取消的通知
            [SVHUDHelper showDarkWarningMsg:@"支付取消"];
        }
    }
}

//通过code获取access_token，openid，unionid
- (void)getWeiXinOpenId:(NSString *)code{
    /*
     appid 应用唯一标识，在微信开放平台提交应用审核通过后获得
     secret 应用密钥AppSecret，在微信开放平台提交应用审核通过后获得
     code  填写第一步获取的code参数
     grant_type authorization_code
     */
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WXAPP_ID,WXAPP_SECRET,code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data1 = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        
        if (!data1) {
            [SVHUDHelper showDarkWarningMsg:@"微信授权失败"];
            return ;
        }
        
        // 授权成功，获取token、openID字典
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableContainers error:nil];
        DTLog(@"token、openID字典===%@",dic);
        NSString *access_token = dic[@"access_token"];
        NSString *openid= dic[@"openid"];
        
        //获取微信用户信息
        [self getUserInfoWithAccessToken:access_token WithOpenid:openid];
        
    });
}

-(void)getUserInfoWithAccessToken:(NSString *)access_token WithOpenid:(NSString *)openid{
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",access_token,openid];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 获取用户信息失败
            if (!data) {
                [SVHUDHelper showDarkWarningMsg:@"微信授权失败"];
                return ;
            }
            // 获取用户信息字典
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //用户信息中没有access_token 我将其添加在字典中
            [dic setValue:access_token forKey:@"token"];
            DTLog(@"微信用户信息字典:===%@",dic);
            if ([[HDUserDefaultMethods getData:@"isBindWX"] isEqualToString:@"1"]) {
                //微信返回信息后,会跳到绑定页面,添加通知进行其他逻辑操作
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_TYPE_WXBINDSUCCESS object:nil userInfo:dic];
            }else{
                //微信返回信息后,会跳到登录页面,添加通知进行其他逻辑操作
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_TYPE_WXLOGINSUCCESS object:nil userInfo:dic];
            }
        });
    });
    
}

@end
