//
//  HDChooseTimeViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/31.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  选择理发预约时段

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDChooseCutTimeViewController : HDBaseViewController

@property (nonatomic,copy) NSString *storeID;
@property (nonatomic,copy) NSString *cutterID;
@property (nonatomic,strong) NSDictionary *dicSelectService;

@end

NS_ASSUME_NONNULL_END
