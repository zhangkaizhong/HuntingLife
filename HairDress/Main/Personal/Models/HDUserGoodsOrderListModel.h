//
//  HDUserGoodsOrderListModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  商品订单模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDUserGoodsOrderListModel : NSObject

@property (nonatomic,copy) NSString *alipayTotalPrice;
@property (nonatomic,copy) NSString *itemImg;
@property (nonatomic,copy) NSString *lastUpdateTime;
@property (nonatomic,copy) NSString *orderType;
@property (nonatomic,copy) NSString *pubSharePreFee;
@property (nonatomic,copy) NSString *settlementStatus;
@property (nonatomic,copy) NSString *showOrderStatus;
@property (nonatomic,copy) NSString *showPayTime;
@property (nonatomic,copy) NSString *showSettlementStatus;
@property (nonatomic,copy) NSString *tkCreateTime;
@property (nonatomic,copy) NSString *tkEarningTime;
@property (nonatomic,copy) NSString *tkPaidTime;
@property (nonatomic,copy) NSString *tkStatus;
@property (nonatomic,copy) NSString *tradeId;

@end

NS_ASSUME_NONNULL_END
