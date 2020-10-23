//
//  HDSearchCutterViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  搜索发型师

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSearchCutterViewController : HDBaseViewController

@property (nonatomic,copy) void(^clickSearchCutterResult)(NSInteger cutterCount);
@property (nonatomic,copy) NSString *tradeStr;
@property (nonatomic,copy) NSString *serviceStr;
@property (nonatomic,copy) NSString *sortStr;
@property (nonatomic,copy) NSString *searchName;

//下拉刷新数据
-(void)setupRefresh;

@end

NS_ASSUME_NONNULL_END
