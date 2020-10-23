//
//  HDResetPasswordsViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  修改密码（账号密码、支付密码）

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDResetPasswordsViewController : HDBaseViewController

@property (nonatomic,copy) NSString *pwdType;//1账号密码，2支付密码

@end

NS_ASSUME_NONNULL_END
