//
//  HDOrderManageViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  预约处理

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDOrderManageViewController : HDBaseViewController

//选中页面
-(void)selectIndexRefresh:(NSInteger)index;

@property (nonatomic,copy) NSString *suTitle;

@property (nonatomic,assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
