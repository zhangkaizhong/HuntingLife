//
//  HDUserOrderListModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/10.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  普通用户理发订单模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDUserOrderListModel : NSObject

@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *serviceId;
@property (nonatomic,copy) NSString *storeId;
@property (nonatomic,copy) NSString *tonyId;
@property (nonatomic,copy) NSString *payAmount;
@property (nonatomic,copy) NSString *queueNum;
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *storeName;
@property (nonatomic,copy) NSString *tonyName;
@property (nonatomic,copy) NSString *orderStatus;

@end

NS_ASSUME_NONNULL_END
