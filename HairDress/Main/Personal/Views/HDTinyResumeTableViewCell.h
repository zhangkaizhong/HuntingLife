//
//  HDTinyResumeTableViewCell.h
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDCutterResumeExpModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDTinyResumeTableViewCell : UITableViewCell

@property (nonatomic,strong) HDCutterResumeExpModel *model;
@property (nonatomic,assign) NSInteger rowIndex;

@end

NS_ASSUME_NONNULL_END
