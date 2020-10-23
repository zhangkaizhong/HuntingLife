//
//  HDTaoMallSubCommonViewController.h
//  HairDress
//
//  Created by Apple on 2020/1/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  icon菜单点击进入的页面

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoMallSubCommonViewController : HDBaseViewController

@property (nonatomic,copy) NSString *cid;
@property (nonatomic,copy) NSString *subTitle;

@property (nonatomic,copy) NSString *keyWords;
@property (nonatomic,copy) NSString *searchType;

@end

NS_ASSUME_NONNULL_END
