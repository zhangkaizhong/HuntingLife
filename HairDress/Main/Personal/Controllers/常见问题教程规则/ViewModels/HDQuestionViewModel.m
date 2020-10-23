//
//  HDQuestionViewModel.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDQuestionViewModel.h"

#import "HDQuestionModel.h"

@implementation HDQuestionViewModel

//常见问题列表
+(void)getQuestionListData:(void (^)(NSDictionary * _Nonnull))resultBlock{
    [MHNetworkManager postReqeustWithURL:URL_QuestionList params:@{} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            
            NSArray *arr = [HDQuestionModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            for (HDQuestionModel *model in arr) {
                model.isSelect = @"0";
            }
            
            resultBlock(@{@"respCode":@(200),@"data":arr});
        }else{
            resultBlock(returnData);
        }
    } failureBlock:^(NSError *error) {
        resultBlock(@{@"respCode":@(0),@"respMsg":@"服务器请求出错"});
    } showHUD:YES];
}

//问题详情
+(void)getQuestionDetailDataWithID:(NSString *)qID compelete:(void (^)(NSDictionary * _Nonnull))resultBlock{
    [MHNetworkManager postReqeustWithURL:URL_QuestionDetail params:@{@"id":qID} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            resultBlock(@{@"respCode":@(200),@"data":returnData[@"data"]});
        }else{
            resultBlock(returnData);
        }
    } failureBlock:^(NSError *error) {
        resultBlock(@{@"respCode":@(0),@"respMsg":@"服务器请求出错"});
    } showHUD:YES];
}

//平台规则列表
+(void)getPlatRulesListData:(void (^)(NSDictionary * _Nonnull))resultBlock{
    [MHNetworkManager postReqeustWithURL:URL_PlatformRules params:nil successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *dic = [HDToolHelper nullDicToDic:returnData[@"data"]];
            resultBlock(@{@"respCode":@(200),@"data":dic});
        }else{
            resultBlock(returnData);
        }
    } failureBlock:^(NSError *error) {
        resultBlock(@{@"respCode":@(0),@"respMsg":@"服务器请求出错"});
    } showHUD:YES];
}

//超级权益
+(void)getSuperEquityListData:(void (^)(NSDictionary * _Nonnull))resultBlock{
    [MHNetworkManager postReqeustWithURL:URL_MemberSuperEquity params:nil successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            resultBlock(@{@"respCode":@(200),@"data":returnData[@"data"]});
        }else{
            resultBlock(returnData);
        }
    } failureBlock:^(NSError *error) {
        resultBlock(@{@"respCode":@(0),@"respMsg":@"服务器请求出错"});
    } showHUD:YES];
}

//新手教程
+(void)getUserTutorialListData:(void (^)(NSDictionary * _Nonnull))resultBlock{
    [MHNetworkManager postReqeustWithURL:URL_NewUserTutorialList params:nil successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            resultBlock(@{@"respCode":@(200),@"data":returnData[@"data"]});
        }else{
            resultBlock(returnData);
        }
    } failureBlock:^(NSError *error) {
        resultBlock(@{@"respCode":@(0),@"respMsg":@"服务器请求出错"});
    } showHUD:YES];
}

//获取查看升级团长指标及达成数据
+(void)getPartnerAchievementData:(void(^)(NSDictionary *result))resultBlock{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        return;
    }
    NSDictionary *params = @{
        @"id":[HDUserDefaultMethods getData:@"userId"]
    };
    
    [MHNetworkManager postReqeustWithURL:URL_QueryPartnerAchievement params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            resultBlock(@{@"respCode":@(200),@"data":returnData[@"data"]});
        }else{
            resultBlock(returnData);
        }
    } failureBlock:^(NSError *error) {
        resultBlock(@{@"respCode":@(0),@"respMsg":@"服务器请求出错"});
    } showHUD:YES];
}

//升级用户级别
+(void)getUpgradePartner:(void(^)(NSDictionary *result))resultBlock{
    
}

@end
