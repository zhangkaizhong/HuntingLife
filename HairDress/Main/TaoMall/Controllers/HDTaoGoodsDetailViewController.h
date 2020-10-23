//
//  HDTaoGoodsDetailViewController.h
//  HairDress
//
//  Created by Apple on 2020/1/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  商品详情

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDTaoGoodsDetailViewDelegate <NSObject>

-(void)clickCollectGoodsActionRefreshList;

@end

@interface HDTaoGoodsDetailViewController : HDBaseViewController

@property (nonatomic,copy) NSString *taoId;
@property (nonatomic,assign) NSInteger indexTab;

@property (nonatomic,assign)id<HDTaoGoodsDetailViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
