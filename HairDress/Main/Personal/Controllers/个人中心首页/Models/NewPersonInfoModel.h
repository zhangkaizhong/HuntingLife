//
//  PersonInfoModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/5/27.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewPersonInfoModel : NSObject

@property (nonatomic, copy) NSString *canGetFee;
@property (nonatomic, copy) NSString *identityName;
@property (nonatomic, copy) NSString *identityRank;
@property (nonatomic, copy) NSString *isUpgrade;
@property (nonatomic, copy) NSString *iosIsShowTask;
@property (nonatomic, copy) NSString *lastMonthSettledFee;
@property (nonatomic, copy) NSString *monthPredictFee;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *storePost;
@property (nonatomic, copy) NSString *taskIncome;
@property (nonatomic, copy) NSString *taskNum;
@property (nonatomic, copy) NSString *todayPredictFee;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *cancelOrderNum;
@property (nonatomic, copy) NSString *finishOrderNum;
@property (nonatomic, copy) NSString *queueOrderNum;
@property (nonatomic, copy) NSString *serviceOrderNum;

@property (nonatomic, copy) NSString *userCancelNum;
@property (nonatomic, copy) NSString *userFinishNum;
@property (nonatomic, copy) NSString *userPayNum;
@property (nonatomic, copy) NSString *userServiceNum;
@property (nonatomic, copy) NSString *userWaitOrQueueNum;


@end

NS_ASSUME_NONNULL_END
