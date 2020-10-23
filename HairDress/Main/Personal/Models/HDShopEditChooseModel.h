//
//  HDShopEditChooseModel.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  配置项模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDShopEditChooseModel : NSObject

@property (nonatomic,copy) NSString *configName;
@property (nonatomic,copy) NSString *configType;
@property (nonatomic,copy) NSString *configValue;
@property (nonatomic,copy) NSString *config_id;
@property (nonatomic,copy) NSString *select;

@end

NS_ASSUME_NONNULL_END
