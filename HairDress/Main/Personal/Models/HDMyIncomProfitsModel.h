//
//  HDMyIncomProfitsModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/16.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMyIncomProfitsModel : NSObject

@property (nonatomic,copy) NSString *changeAmount;
@property (nonatomic,copy) NSString *changeStatus;
@property (nonatomic,copy) NSString *changeType;
@property (nonatomic,copy) NSString *childNickName;
@property (nonatomic,copy) NSString *clickTime;
@property (nonatomic,copy) NSString *lastUpdateTime;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *orderTime;
@property (nonatomic,copy) NSString *orderType;
@property (nonatomic,copy) NSString *settleStatus;
@property (nonatomic,copy) NSString *showOrderTime;
@property (nonatomic,copy) NSString *showSettleTime;
@property (nonatomic,copy) NSString *tkEarningTime;
@property (nonatomic,copy) NSString *tkStatus;

@end

NS_ASSUME_NONNULL_END
