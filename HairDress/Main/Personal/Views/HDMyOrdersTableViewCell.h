//
//  HDMyOrdersTableViewCell.h
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  我的预约cell

#import <UIKit/UIKit.h>
#import "HDTonyOrderListModel.h"

typedef enum : NSUInteger {
    MyOrdersButtonTypeBegain,
    MyOrdersButtonTypeDone,
} MyOrdersButtonType;

NS_ASSUME_NONNULL_BEGIN

@protocol MyOrdersCellDelegate <NSObject>

-(void)clickOrderButtonType:(MyOrdersButtonType)btnType model:(HDTonyOrderListModel *)model;

@end

@interface HDMyOrdersTableViewCell : UITableViewCell


@property (nonatomic,assign)id<MyOrdersCellDelegate>delegate;

@property (nonatomic,strong) HDTonyOrderListModel *model;

@end

NS_ASSUME_NONNULL_END
