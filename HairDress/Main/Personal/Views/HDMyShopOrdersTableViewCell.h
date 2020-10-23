//
//  HDMyShopOrdersTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  个人中心我的订单商品订单cell

#import <UIKit/UIKit.h>

#import "HDUserGoodsOrderListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDMyShopOrdersTableViewCell : UITableViewCell

@property (nonatomic,strong) HDUserGoodsOrderListModel *model;

@end

NS_ASSUME_NONNULL_END
