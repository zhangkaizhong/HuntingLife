//
//  HDSettingViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/1.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDSettingDelegate<NSObject>

-(void)logoutAction;

@end
NS_ASSUME_NONNULL_BEGIN

@interface HDSettingViewController : HDBaseViewController

@property (nonatomic,assign) id<HDSettingDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
