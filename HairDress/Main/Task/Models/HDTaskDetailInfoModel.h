//
//  HDTaskDetailInfoModel.h
//  HairDress
//
//  Created by Apple on 2020/2/10.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTaskDetailInfoModel : NSObject

@property (nonatomic,copy) NSString *acceptNum;
@property (nonatomic,copy) NSString *checkHour;
@property (nonatomic,copy) NSString *finishNum;
@property (nonatomic,copy) NSString *overHour;
@property (nonatomic,copy) NSString *passRate;
@property (nonatomic,copy) NSString *taskDesc;
@property (nonatomic,copy) NSString *taskId;
@property (nonatomic,copy) NSString *taskMoney;
@property (nonatomic,copy) NSString *taskName;
@property (nonatomic,copy) NSString *taskTags;
@property (nonatomic,copy) NSString *topFlag;
@property (nonatomic,copy) NSString *userAcceptNum;
@property (nonatomic,copy) NSString *validTime;
@property (nonatomic,strong) NSArray *taskSteps;

@end

NS_ASSUME_NONNULL_END
