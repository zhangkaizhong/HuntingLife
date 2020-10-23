//
//  HDPersonalHomeCell1.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PersonCellOneMenuTypeIncome = 0,//我的收益
    PersonCellOneMenuTypeMyOrder,//我的订单
    PersonCellOneMenuTypeWithdraw, //余额提现
    PersonCellOneMenuTypeMyTeam,//我的团队
} PersonCellOneMenuType;

@protocol PersonCellOneMenuDelegate <NSObject>

-(void)clickCellOneMenuType:(PersonCellOneMenuType)type;

@end

@interface HDPersonalHomeCell1 : UITableViewCell

@property (nonatomic,assign)id<PersonCellOneMenuDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
