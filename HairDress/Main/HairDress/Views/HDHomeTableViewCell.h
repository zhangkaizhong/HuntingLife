//
//  HDHomeTableViewCell.h
//  HairDress
//
//  Created by Apple on 2019/12/20.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  门店cell

#import <UIKit/UIKit.h>

#import "HDHomeShopListModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HomeTableViewCellDelegate <NSObject>

-(void)clickHomeCellWithModel:(HDHomeShopListModel *)model;

@end

@interface HDHomeTableViewCell : UITableViewCell

@property (nonatomic,assign)id<HomeTableViewCellDelegate>delegate;

@property (nonatomic,strong)HDHomeShopListModel *shopModel;

@property (nonatomic,copy) NSString *nearestDis;

@end

NS_ASSUME_NONNULL_END
