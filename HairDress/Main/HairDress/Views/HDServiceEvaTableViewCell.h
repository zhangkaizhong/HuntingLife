//
//  CellForQAList.h
//  github:  https://github.com/samuelandkevin
//
//  Created by samuelandkevin on 16/8/29.
//  Copyright © 2016年 HKP. All rights reserved.
//  原创视图

#import <UIKit/UIKit.h>
#import "HDEvaluateModel.h"

@class HDServiceEvaTableViewCell;
@protocol CellForServiceEvaDelegate <NSObject>

- (void)onAvatarInCell:(HDServiceEvaTableViewCell *)cell;

@end

@interface HDServiceEvaTableViewCell : UITableViewCell

@property (nonatomic,strong) HDEvaluateModel *model;
@property (nonatomic, weak) id<CellForServiceEvaDelegate> delegate;
@property (nonatomic,strong)UIView  *viewBottom;
@end
