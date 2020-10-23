//
//  HDSearchShopsViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  搜索门店

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSearchShopsViewController : HDBaseViewController

@property (nonatomic,copy) void(^clickSearchShopResult)(NSInteger shopCount);
@property (nonatomic,copy) NSString *tradeStr;
@property (nonatomic,copy) NSString *serviceStr;
@property (nonatomic,copy) NSString *sortStr;
@property (nonatomic,copy) NSString *searchName;

@property (nonatomic,copy) NSString *longitude;
@property (nonatomic,copy) NSString *latitude;

//下拉刷新数据
-(void)setupRefresh;

@end

NS_ASSUME_NONNULL_END
