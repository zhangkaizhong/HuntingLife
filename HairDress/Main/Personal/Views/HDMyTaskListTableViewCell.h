//
//  HDMyTaskListTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/5.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDMyTaskListModel.h"

#define TimeCellNotification  @"NotificationTimeCell"

NS_ASSUME_NONNULL_BEGIN

@interface HDMyTaskListTableViewCell : UITableViewCell

//刷新显示在屏幕上的时间
@property(nonatomic,assign)BOOL isDisplay;

-(void)setSecond:(HDMyTaskListModel *)model row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
