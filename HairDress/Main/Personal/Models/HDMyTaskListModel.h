//
//  HDMyTaskListModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/5.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMyTaskListModel : NSObject

@property (nonatomic,copy) NSString *checkStatus;
@property (nonatomic,copy) NSString *checkTime;
@property (nonatomic,copy) NSString *sendTime;
@property (nonatomic,copy) NSString *updateTime;
@property (nonatomic,copy) NSString *invalidSecond;
@property (nonatomic,copy) NSString *invalidTime;
@property (nonatomic,copy) NSString *memberTaskId;
@property (nonatomic,copy) NSString *taskMoney;
@property (nonatomic,copy) NSString *taskName;
@property (nonatomic,copy) NSString *acceptTime;
@property (nonatomic,copy) NSString *taskImg;

@end

NS_ASSUME_NONNULL_END
