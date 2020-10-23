//
//  HDEditNickNameViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  修改昵称

#import <UIKit/UIKit.h>

@protocol HDEditNickNameDelegate <NSObject>

-(void)editNickNameAction:(NSString *_Nullable)nickName;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDEditNickNameViewController : HDBaseViewController

@property (nonatomic,assign)id<HDEditNickNameDelegate>delegate;

@property (nonatomic,copy) NSString *nickName;

@end

NS_ASSUME_NONNULL_END
