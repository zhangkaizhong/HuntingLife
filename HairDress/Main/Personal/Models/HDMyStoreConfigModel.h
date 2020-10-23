//
//  HDMyStoreConfigModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  门店配置数据模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMyStoreConfigModel : NSObject

@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *configDesc;
@property (nonatomic,copy) NSString *defaultFlag;
@property (nonatomic,copy) NSString *linkId;
@property (nonatomic,copy) NSString *linkName;
@property (nonatomic,copy) NSString *linkType;
@property (nonatomic,copy) NSString *storeConfigId;
@property (nonatomic,copy) NSString *storeId;

@end

@interface HDMyStoreTimeConfigModel : NSObject

@property (nonatomic,copy) NSString *endTime;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *storeId;
@property (nonatomic,copy) NSString *storeTimeId;
@property (nonatomic,copy) NSString *totalNum;

@property (nonatomic,copy) NSString *showTimes;

@end

NS_ASSUME_NONNULL_END
