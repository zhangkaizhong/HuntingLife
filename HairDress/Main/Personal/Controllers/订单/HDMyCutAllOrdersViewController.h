//
//  HDMyCutAllOrdersViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/6/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  我的理发订单

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMyCutAllOrdersViewController : UIViewController

//选中代付款页面
-(void)selectIndexRefresh:(NSInteger)index isReoload:(BOOL)reload;

@property (nonatomic,assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
