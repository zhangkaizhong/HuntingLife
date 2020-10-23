//
//  HDTaskListTableViewCell.h
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDTaskListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDTaskListTableViewCell : UITableViewCell

@property (nonatomic,strong) HDTaskListModel *model;

@end

NS_ASSUME_NONNULL_END
