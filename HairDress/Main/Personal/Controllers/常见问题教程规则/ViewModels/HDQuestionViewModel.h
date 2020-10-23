//
//  HDQuestionViewModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/6/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDQuestionViewModel : NSObject

//获取常见问题列表数据
+(void)getQuestionListData:(void(^)(NSDictionary *result))resultBlock;

//获取问题详情
+(void)getQuestionDetailDataWithID:(NSString *)qID compelete:(void (^)(NSDictionary *result))resultBlock;

//获取平台规则列表数据
+(void)getPlatRulesListData:(void(^)(NSDictionary *result))resultBlock;

//获取超级权益列表数据
+(void)getSuperEquityListData:(void(^)(NSDictionary *result))resultBlock;

//获取新手教程列表数据
+(void)getUserTutorialListData:(void(^)(NSDictionary *result))resultBlock;

//获取查看升级团长指标及达成数据
+(void)getPartnerAchievementData:(void(^)(NSDictionary *result))resultBlock;

//升级用户级别
+(void)getUpgradePartner:(void(^)(NSDictionary *result))resultBlock;

@end

NS_ASSUME_NONNULL_END
