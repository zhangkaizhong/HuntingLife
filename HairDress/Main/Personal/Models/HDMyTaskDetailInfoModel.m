//
//  HDMyTaskDetailInfoModel.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyTaskDetailInfoModel.h"

@implementation HDMyTaskDetailInfoModel

-(HDTaskDetailInfoModel *)taskInfoModel{
    _taskInfoModel = [HDTaskDetailInfoModel mj_objectWithKeyValues:[HDToolHelper nullDicToDic:self.taskInfo]];
    return _taskInfoModel;
}

@end
