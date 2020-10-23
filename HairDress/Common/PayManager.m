//
//  PayManager.m
//  MeiLin
//
//  Created by niyisen on 2018/9/11.
//  Copyright © 2018年 Li Chuanliang. All rights reserved.
//

#import "PayManager.h"
#import "WXApi.h"     //微信支付
#import <AlipaySDK/AlipaySDK.h>

@implementation PayManager
#pragma mark - 单例创建
static PayManager *instance = nil;

//单例
+(PayManager *)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc]init];
    });
    return instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

-(id)copyWithZone:(NSZone *)zone{
    return instance;
}


-(void)paybyAlipayWithSign:(NSString *)key_sign callback:(void(^)(NSDictionary *resultDic))block{
    self.callback = block;
    [[AlipaySDK defaultService] payOrder:key_sign fromScheme:@"clalipay" callback:block];
}

-(void)weixinPayParam:(NSDictionary *)dic callback:(void(^)(NSDictionary *resultDic))block{
    self.callback = block;
#if !TARGET_IPHONE_SIMULATOR
    PayReq *req = [[PayReq alloc] init];
    req.openID = dic[@"appid"];
    req.partnerId = dic[@"partnerid"];
    req.prepayId = dic[@"prepayid"];
    req.package = dic[@"package"];
    req.nonceStr = dic[@"noncestr"];
    req.timeStamp = [dic[@"timestamp"] intValue];
    req.sign = dic[@"sign"];
    [WXApi sendReq:req completion:nil];
#endif
}

@end
