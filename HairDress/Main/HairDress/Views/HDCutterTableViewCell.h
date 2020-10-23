//
//  HDCutterTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/22.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  发型师cell

#import <UIKit/UIKit.h>

#import "HDShopCutterListModel.h"

@protocol HDCutterTableViewCellDelegate <NSObject>

-(void)clickGenumAction:(HDShopCutterListModel *_Nullable)model;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDCutterTableViewCell : UITableViewCell

@property (nonatomic,strong) HDShopCutterListModel *model;

@property (nonatomic,assign) id<HDCutterTableViewCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
