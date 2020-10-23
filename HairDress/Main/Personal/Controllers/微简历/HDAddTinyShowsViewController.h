//
//  HDAddTinyShowsViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  添加微简历作品集

#import <UIKit/UIKit.h>

@protocol HDAddTinyShowsDelegate <NSObject>

-(void)refreshNewShowsList;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDAddTinyShowsViewController : HDBaseViewController

@property (nonatomic,assign)id<HDAddTinyShowsDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
