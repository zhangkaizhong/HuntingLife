//
//  PayManager.h
//  MeiLin
//
//  Created by niyisen on 2018/9/11.
//  Copyright © 2018年 Li Chuanliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayManager : NSObject

typedef void(^PayCallBack)(NSDictionary *result);

@property (nonatomic,copy)PayCallBack callback; //支付返回结果

+(PayManager *)shareInstance;

//alipay
-(void)paybyAlipayWithSign:(NSString *)key_sign callback:(void(^)(NSDictionary *resultDic))block;

//微信支付
-(void)weixinPayParam:(NSDictionary *)dic callback:(void(^)(NSDictionary *resultDic))block;

@end
