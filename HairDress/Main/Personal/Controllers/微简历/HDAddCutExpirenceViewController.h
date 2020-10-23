//
//  HDAddCutExpirenceViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  添加剪发经验

#import <UIKit/UIKit.h>
#import "HDCutterResumeExpModel.h"

@protocol HDAddCutExpirenceDelegate <NSObject>

-(void)addCutExpActionDelegate;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDAddCutExpirenceViewController : HDBaseViewController

@property (nonatomic,strong) NSString *expId;

@property (nonatomic,assign) id<HDAddCutExpirenceDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
