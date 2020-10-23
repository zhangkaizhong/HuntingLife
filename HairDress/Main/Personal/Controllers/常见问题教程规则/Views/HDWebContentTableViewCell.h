//
//  HDWebContentTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2020/6/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  html内容cell

#import <UIKit/UIKit.h>

#import "HDWebContentModel.h"

@protocol HDWebContentTableViewCellDelegate <NSObject>

-(void)reloadHeight:(CGFloat)cellHeight model:(HDWebContentModel *)model;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDWebContentTableViewCell : UITableViewCell

@property (nonatomic,strong)HDWebContentModel *model;
@property (nonatomic,assign)id<HDWebContentTableViewCellDelegate>delegate;

@property (nonatomic,copy) void(^cellHeighBlcok)(CGFloat cellHeight,HDWebContentModel *model);

@end

NS_ASSUME_NONNULL_END
