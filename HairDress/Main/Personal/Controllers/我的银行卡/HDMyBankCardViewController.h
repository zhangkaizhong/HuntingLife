//
//  HDMyBankCardViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/13.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  单张银行卡

#import <UIKit/UIKit.h>

@protocol HDMyBankCardDelegate <NSObject>

-(void)changeMyBankMsg:(NSDictionary *)dicBank;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDMyBankCardViewController : HDBaseViewController

@property (nonatomic,assign)id<HDMyBankCardDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
