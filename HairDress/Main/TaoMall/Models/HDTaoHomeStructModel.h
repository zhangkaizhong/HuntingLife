//
//  HDTaoHomeStructModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  首页bar数据模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoHomeStructModel : NSObject

@property (nonatomic,strong) NSArray *bannerVoList;//banner列表
@property (nonatomic,strong) NSArray *floorVoList;
@property (nonatomic,strong) NSArray *formatDemoVoList;//精选活动（板式）
@property (nonatomic,strong) NSArray *iconVoList;//菜单列表

@property (nonatomic,strong) NSArray *otherBarSortVoList;
@property (nonatomic,strong) NSArray *specialVoList;

@end

NS_ASSUME_NONNULL_END
