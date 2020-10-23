//
//  HDSearchViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  搜索页面

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSearchViewController : HDBaseViewController

@property (nonatomic,copy) NSString *cityName;

@property (nonatomic,copy) NSString *longitude;
@property (nonatomic,copy) NSString *latitude;

@end

NS_ASSUME_NONNULL_END
