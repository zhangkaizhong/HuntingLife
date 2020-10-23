//
//  HDStoreOrderListModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/4.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDStoreOrderListModel : NSObject

@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *finishTime;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *orderStatus;
@property (nonatomic,copy) NSString *queueNum;
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *signTime;
@property (nonatomic,copy) NSString *tonyName;
@property (nonatomic,copy) NSString *totalAmount;

@end

NS_ASSUME_NONNULL_END
