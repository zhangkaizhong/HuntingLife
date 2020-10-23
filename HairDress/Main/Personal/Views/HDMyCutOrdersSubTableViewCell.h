//
//  HDMyCutOrdersTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  个人中心我的订单理发订单已完成已取消过号cell

#import <UIKit/UIKit.h>
#import "HDUserOrderListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MyCutOrdersSubButtonTypeEva,//评价
    MyCutOrdersSubButtonTypeRegetNo,//重新取号
} MyCutOrdersSubButtonType;

@protocol HDMyCutOrdersSubDelegate <NSObject>

-(void)clickMyCutOrdersSubBtnType:(MyCutOrdersSubButtonType)type model:(HDUserOrderListModel *)model;

@end

@interface HDMyCutOrdersSubTableViewCell : UITableViewCell


@property (nonatomic,strong) HDUserOrderListModel *model;

@property (nonatomic,assign)id<HDMyCutOrdersSubDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
