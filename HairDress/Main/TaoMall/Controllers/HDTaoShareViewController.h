//
//  HDTaoShareViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/22.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  分享页面

#import <UIKit/UIKit.h>
#import "HDTaoDetailInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoShareViewController : HDBaseViewController

@property (nonatomic,strong) HDTaoDetailInfoModel *detailModel;
@property (nonatomic,copy) NSString *clickUrl;

@end

NS_ASSUME_NONNULL_END
