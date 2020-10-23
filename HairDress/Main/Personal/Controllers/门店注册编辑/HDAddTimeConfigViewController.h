//
//  HDAddTimeConfigViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/31.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDMyStoreConfigModel.h"

@protocol HDAddTimeConfigDelegate <NSObject>

-(void)refreshTimeConfigList;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDAddTimeConfigViewController : HDBaseViewController

@property (nonatomic,strong) HDMyStoreTimeConfigModel *timeModel;
@property (nonatomic,assign) id<HDAddTimeConfigDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
