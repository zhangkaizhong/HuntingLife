//
//  HDMyIncomInfoModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMyIncomInfoModel : NSObject

@property (nonatomic,copy) NSString *dayAmount;
@property (nonatomic,copy) NSString *dayOrderNum;
@property (nonatomic,copy) NSString *daySettleNum;
@property (nonatomic,copy) NSString *today;
@property (nonatomic,copy) NSString *totalAmount;
@property (nonatomic,copy) NSString *totalOrderNum;
@property (nonatomic,copy) NSString *totalSettleNum;

@end

NS_ASSUME_NONNULL_END
