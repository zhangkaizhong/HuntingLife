//
//  HDOrderManageTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//。预约处理cell

#import <UIKit/UIKit.h>
#import "HDStoreOrderListModel.h"

typedef enum : NSUInteger {
    ButtonTypeCancel,
    ButtonTypeDone,
    ButtonTypeBegain,
} ServiceButtonType;

NS_ASSUME_NONNULL_BEGIN

@protocol OrderManageCellDelegate <NSObject>

-(void)clickOrderButtonType:(ServiceButtonType)btnType withModel:(HDStoreOrderListModel *)model;

@end

@interface HDOrderManageTableViewCell : UITableViewCell

@property (nonatomic,assign)id<OrderManageCellDelegate>delegate;
@property (nonatomic,strong) HDStoreOrderListModel *model;

@end

NS_ASSUME_NONNULL_END
