//
//  HDQRScanViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/4.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  扫一扫

#import <UIKit/UIKit.h>
#import "SWQRCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDQRScanViewController : HDBaseViewController

@property (nonatomic, strong) SWQRCodeConfig *codeConfig;

@end

NS_ASSUME_NONNULL_END
