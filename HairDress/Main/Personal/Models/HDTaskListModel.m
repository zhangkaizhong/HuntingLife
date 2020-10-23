//
//  HDTaskListModel.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/5.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaskListModel.h"

@implementation HDTaskListModel

-(CGFloat)cellHeight{
    self.taskImgFrame = CGRectMake(23*SCALE, 21*SCALE, 55*SCALE, 55*SCALE);
    self.taskTypeFrame = CGRectMake(CGRectGetMaxX(self.taskImgFrame)+15*SCALE, 20*SCALE, 28*SCALE, 14*SCALE);
    
    self.taskDescFrame = CGRectMake(CGRectGetMaxX(self.taskImgFrame)+15*SCALE, CGRectGetMaxY(self.taskTypeFrame)+7*SCALE, kSCREEN_WIDTH-CGRectGetMaxX(self.taskImgFrame)-15*SCALE-16*SCALE-46*SCALE-15*SCALE, 18);
    CGRect taskDesFrame = [self.taskDesc boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-CGRectGetMaxX(self.taskImgFrame)-15*SCALE-16*SCALE-46*SCALE-15*SCALE, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TEXT_SC_TFONT(TEXT_SC_Regular, 10*SCALE)} context:nil];
    if (taskDesFrame.size.height <= 10*SCALE) {
        taskDesFrame.size.height = 10*SCALE;
    }
    taskDesFrame.size.height = 10*SCALE;
    self.taskDescFrame = CGRectMake(CGRectGetMaxX(self.taskImgFrame)+15*SCALE, CGRectGetMaxY(self.taskTypeFrame)+7*SCALE, kSCREEN_WIDTH-CGRectGetMaxX(self.taskImgFrame)-15*SCALE-16*SCALE-46*SCALE-15*SCALE, taskDesFrame.size.height);
    
    self.taskMoneyImgFrame = CGRectMake(CGRectGetMaxX(self.taskImgFrame)+15*SCALE, CGRectGetMaxY(self.taskDescFrame)+7*SCALE, 18*SCALE, 16*SCALE);
    self.lineFrame = CGRectMake(8*SCALE, CGRectGetMaxY(self.taskMoneyImgFrame)+26*SCALE, kSCREEN_WIDTH-16*SCALE, 1);
    _cellHeight = CGRectGetMaxY(self.lineFrame);
    return _cellHeight;
}

-(NSString *)taskType{
    _taskType = [_taskType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _taskType = [_taskType stringByReplacingOccurrencesOfString:@" " withString:@""];
    return _taskType;
}

@end
