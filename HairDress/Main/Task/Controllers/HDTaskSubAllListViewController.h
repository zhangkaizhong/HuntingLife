//
//  HDTaskSubAllListViewController.h
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTaskSubAllListViewController : SegmentViewController

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,copy) NSString *taskType;

//下拉刷新数据
-(void)loadNewData;

@end

NS_ASSUME_NONNULL_END
