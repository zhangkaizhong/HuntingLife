//
//  PersonViewModels.m
//  HairDress
//
//  Created by 张凯中 on 2020/5/27.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "PersonViewModels.h"

@implementation PersonViewModels

//获取用户信息
+(void)getMemberInfo:(void (^)(NSDictionary * _Nonnull))resultBlock{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_UserGetMemberInfo params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            resultBlock(userInfo);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//获取分享数据
+(void)getShareInfo:(void (^)(NSDictionary * _Nonnull))resultBlock{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_UserGetAppConfigInfo params:@{} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            resultBlock(returnData[@"data"]);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//获取用户收益数据
+(void)getPersonalProfitData:(void (^)(NSDictionary * _Nonnull))resultBlock{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        NSDictionary *dic = @{@"todayPredictFee":@"0",@"monthPredictFee":@"0",@"lastMonthSettledFee":@"0",@"canGetFee":@"0",@"totalPredictFee":@"0",};
        resultBlock(dic);
        return;
    }
    NSDictionary *params = @{
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_UserQueryMoneyInfo params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            resultBlock(returnData[@"data"]);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//获取店主发型师预约数量
+(void)getStoreOrderNumData:(void (^)(NewPersonInfoModel * _Nonnull))resultBlock{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        NewPersonInfoModel *model = [NewPersonInfoModel new];
        model.cancelOrderNum = @"0";
        model.finishOrderNum = @"0";
        model.queueOrderNum = @"0";
        model.serviceOrderNum = @"0";
        resultBlock(model);
        return;
    }
    NSDictionary *params = @{
        @"storeId":[HDUserDefaultMethods getData:@"storeId"],
        @"tonyId":[HDUserDefaultMethods getData:@"userId"],
    };
    [MHNetworkManager postReqeustWithURL:URL_StoreOrderNum params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            NewPersonInfoModel *model = [NewPersonInfoModel mj_objectWithKeyValues:returnData[@"data"]];
            resultBlock(model);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//获取用户理发订单数量
+(void)getUserOrderNumData:(void (^)(NewPersonInfoModel * _Nonnull))resultBlock{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        NewPersonInfoModel *model = [NewPersonInfoModel new];
        model.userCancelNum = @"0";
        model.userFinishNum = @"0";
        model.userPayNum = @"0";
        model.userServiceNum = @"0";
        model.userWaitOrQueueNum = @"0";
        resultBlock(model);
        return;
    }
    NSDictionary *params = @{
        @"userId":[HDUserDefaultMethods getData:@"userId"],
    };
    [MHNetworkManager postReqeustWithURL:URL_UserOrderNum params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            NewPersonInfoModel *model = [NewPersonInfoModel mj_objectWithKeyValues:returnData[@"data"]];
            resultBlock(model);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}


//获取新版个人中心数据
+(void)getNewPersonalInfoData:(void (^)(NewPersonInfoModel * _Nonnull))resultBlock{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        NewPersonInfoModel *model = [NewPersonInfoModel new];
        
        model.canGetFee = @"0";
        model.lastMonthSettledFee = @"0";
        model.monthPredictFee = @"0";
        model.taskIncome = @"0";
        model.todayPredictFee = @"0";
        
        model.identityName = @"";
        model.identityRank = @"L";
        model.isUpgrade = @"F";
        model.phone = @"";
        model.storePost = @"";
        model.taskNum = @"0";
        
        resultBlock(model);
        return;
    }
    NSDictionary *params = @{
        @"id":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_NewMemberCenterData params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            NewPersonInfoModel *model = [NewPersonInfoModel mj_objectWithKeyValues:returnData[@"data"]];
            resultBlock(model);
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}


@end
