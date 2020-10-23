//
//  HDShopMsgInfoViewController.h
//  HairDress
//
//  Created by Apple on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  门店信息

#import <UIKit/UIKit.h>
#import "HDShopDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDShopMsgInfoViewController : SegmentViewController

@property (nonatomic,assign) CGFloat tableHeight;

@property (nonatomic,strong) HDShopDetailModel *shopDetailModel;

@end

NS_ASSUME_NONNULL_END
