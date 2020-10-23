//
//  HDChooseServicesViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  选择服务标准

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDChooseServicesConfigDelegate <NSObject>

-(void)chooseConfigList:(NSString *)type configs:(NSArray *)arrConfigs;

@end

@interface HDChooseServicesViewController : HDBaseViewController

@property (nonatomic,copy)NSString *chooseType;
@property (nonatomic,assign)BOOL singleChoose;
@property (nonatomic,strong) NSArray *arrSelects;
@property (nonatomic,assign) id<HDChooseServicesConfigDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
