//
//  SVProgressHUD.h
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVHUDHelper : NSObject

+(void)showInfoWithTimestamp:(NSInteger)timestamp msg:(NSString *)msg;
+(void)showWorningMsg:(NSString *)msg timeInt:(NSInteger)timestamp;
+(void)showLoadingHUD;
+(void)showDarkWarningMsg:(NSString *)msg;
+(void)showSuccessDoneMsg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
