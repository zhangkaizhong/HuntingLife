//
//  HDMyTaskDetailInfoModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HDTaskDetailInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDMyTaskDetailInfoModel : NSObject

@property (nonatomic,copy) NSString *checkDesc;
@property (nonatomic,copy) NSString *checkStatus;
@property (nonatomic,copy) NSString *invalidSecond;
@property (nonatomic,copy) NSString *invalidTime;
@property (nonatomic,copy) NSString *memberTaskId;
@property (nonatomic,copy) NSString *updateTime;

@property (nonatomic,copy) NSDictionary *taskInfo;

@property (nonatomic,copy) HDTaskDetailInfoModel *taskInfoModel;

@end

NS_ASSUME_NONNULL_END
