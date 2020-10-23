//
//  HDNewPersonalView.h
//  HairDress
//
//  Created by 张凯中 on 2020/4/30.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPersonInfoModel.h"

typedef enum : NSUInteger {
    FunctionTypeSet = 0,//设置
    FunctionTypeMsg,//消息
    FunctionTypeScan,//扫一扫
    FunctionTypePersonInfo,//个人信息
    FunctionTypeFans,//粉丝
    FunctionTypeWithdrew,//提现
    FunctionTypeTBOrders,//淘宝订单
    FunctionTypeOtherOrders,//其他订单
    FunctionTypeMemberGaikuang,//会员详情，查看概况
    FunctionTypeUpdateTuanzhang,//升级团长
    FunctionTypeCheckCutCalender,//查看剪发日历
    FunctionTypeCutOrdersMore,//我的剪发预约订单
    FunctionTypeCutOrdersWaitToPay,//待付款理发订单
    FunctionTypeCutOrdersWiatXiaofei,//待消费理发订单
    FunctionTypeCutOrdersService,//服务中理发订单
    FunctionTypeCutOrdersDone,//已完成理发订单
    FunctionTypeCutOrdersRefund,//退款过号理发订单
    FunctionTypeMyCutOrdersMore,//我的剪发订单
    FunctionTypeMyCutOrdersUnaccept,//待接单理发订单
    FunctionTypeMyCutOrdersAccepted,//已接单理发订单
    FunctionTypeMyCutOrdersDone,//已完成理发订单
    FunctionTypeMyCutOrdersRefund,//退款过号理发订单
    FunctionTypeSuperQuanyi,//超级权益
    FunctionTypeTaskMore,//查看更多任务
    FunctionTypeTaskCenter,//任务中心
    FunctionTypeMemberCenterInvite,//邀请好友
    FunctionTypeMemberCenterBeOwner,//成为店主
    FunctionTypeMemberCenterInviteWaiter,//招募店员
    FunctionTypeMemeberCenterNewerTeach,//新手教程
    FunctionTypeMyServiceAccount,//提现账户
    FunctionTypeMyServiceMaterial,//地推物料
    FunctionTypeMyServiceCollect,//收藏夹
    FunctionTypeMyServiceRules,//平台规则
    FunctionTypeMyServiceQuestion,//常见问题
    FunctionTypeMyServiceAbout,//关于潮流
    FunctionTypeMyServiceYuyueTime,//预约理发时段
    FunctionTypeMyServiceProfitTongji,//收益统计
    FunctionTypeMyServiceStoreInfo,//门店信息
    FunctionTypeMyServiceCountDetail,//服务项目
    FunctionTypeMyServiceWeijianli,//微简历
    FunctionTypeMyServiceWaiterInfo,//员工信息
    FunctionTypeMyServiceMyStoreWaiter,//我的店员
} PersonFunctionType;

@protocol HDNewPersonalViewDelegate <NSObject>

-(void)clickPersonFunciton:(PersonFunctionType)type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDNewPersonalView : UIView

-(instancetype)initWithFrame:(CGRect)frame type:(BOOL)logOut;

@property (nonatomic,assign) id<HDNewPersonalViewDelegate>delegate;

//刷新UI
-(void)reloadUIWithData:(NSDictionary *)memberInfo complete:(void(^)(void))block;

//刷新用户收益数据
-(void)reloadProfitData:(NewPersonInfoModel *)profitData;

//刷新订单数量
-(void)reloadOrderNumData:(NewPersonInfoModel *)orderNumData;

//刷新用户理发订单数量
-(void)reloadUserOrderNumData:(NewPersonInfoModel *)orderNumData;

@end

NS_ASSUME_NONNULL_END
