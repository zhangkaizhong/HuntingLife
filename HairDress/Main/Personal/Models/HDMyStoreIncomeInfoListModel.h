//
//  HDMyStoreIncomeInfoListModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  门店收益列表model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMyStoreIncomeInfoListModel : NSObject

@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *storeId;
@property (nonatomic,copy) NSString *settleTime;
@property (nonatomic,copy) NSString *tonyId;
@property (nonatomic,copy) NSString *tonyName;

@end

NS_ASSUME_NONNULL_END
