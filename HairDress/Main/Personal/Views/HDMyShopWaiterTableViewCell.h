//
//  HDMyShopWaiterTableViewCell.h
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//。我的店员cell

#import <UIKit/UIKit.h>

#import "HDStoreWaiterListModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MyShopWaiterDelegate <NSObject>

-(void)clickChangeShopWaiterType:(NSString *)btnTitle withModel:(HDStoreWaiterListModel *)model;

@end

@interface HDMyShopWaiterTableViewCell : UITableViewCell

@property (nonatomic,assign)id<MyShopWaiterDelegate>delegate;

@property (nonatomic,strong) HDStoreWaiterListModel *model;

@end

NS_ASSUME_NONNULL_END
