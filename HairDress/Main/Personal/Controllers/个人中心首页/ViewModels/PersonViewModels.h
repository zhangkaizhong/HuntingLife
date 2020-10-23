//
//  PersonViewModels.h
//  HairDress
//
//  Created by 张凯中 on 2020/5/27.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NewPersonInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PersonViewModels : NSObject

//获取用户信息
+(void)getMemberInfo:(void(^)(NSDictionary *result))resultBlock;

//获取分享数据
+(void)getShareInfo:(void(^)(NSDictionary *result))resultBlock;

//获取用户收益数据
+(void)getPersonalProfitData:(void(^)(NSDictionary *result))resultBlock;

//获取店主发型师预约数量
+(void)getStoreOrderNumData:(void(^)(NewPersonInfoModel *personModel))resultBlock;

//用户:我的订单数量
+(void)getUserOrderNumData:(void(^)(NewPersonInfoModel *personModel))resultBlock;

//新版个人中心用户数据
+(void)getNewPersonalInfoData:(void(^)(NewPersonInfoModel *personModel))resultBlock;

@end

NS_ASSUME_NONNULL_END
