//
//  HDShopDetailViewController.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  门店详情

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDShopDetailViewDelegate <NSObject>

-(void)clickCollectActionRefreshList;

@end

@interface HDShopDetailViewController : HDBaseViewController

@property (nonatomic,copy)NSString *shop_id;

@property (nonatomic,assign) id<HDShopDetailViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
