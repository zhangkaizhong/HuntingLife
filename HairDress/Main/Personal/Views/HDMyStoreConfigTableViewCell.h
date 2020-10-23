//
//  HDMyStoreConfigTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  门店配置cell

#import <UIKit/UIKit.h>

#import "HDMyStoreConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDMyStoreConfigTableViewCell : UITableViewCell

@property (nonatomic,strong) HDMyStoreConfigModel *model;
@property (nonatomic,strong) HDMyStoreTimeConfigModel *timeModel;

@end

NS_ASSUME_NONNULL_END
