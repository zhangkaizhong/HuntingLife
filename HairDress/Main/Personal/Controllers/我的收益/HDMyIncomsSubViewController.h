//
//  HDMyIncomsSubViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMyIncomsSubViewController : HDBaseViewController

@property (nonatomic,copy) NSString *orderSource;//收益来源：cpsOrder（订单）task（任务）
@property (nonatomic,copy) NSString *profitSource;//收益类型 all/team/person
@property (nonatomic,copy) NSString *settleStatus;//结算状态 SettlementStatusEnum： no_handle/finish/cancel

@end

NS_ASSUME_NONNULL_END
