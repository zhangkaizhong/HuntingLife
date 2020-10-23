//
//  HDAddShopConfigViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  新增门店配置

#import <UIKit/UIKit.h>
#import "HDMyStoreConfigModel.h"

@protocol HDAddShopConfigDelegate <NSObject>

-(void)refreshShopConfigList;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDAddShopConfigViewController : HDBaseViewController

@property (nonatomic,strong) HDMyStoreConfigModel *storeConfigModel;
@property (nonatomic,assign) id<HDAddShopConfigDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
