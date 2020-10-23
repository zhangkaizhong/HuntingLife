//
//  HDMyStoreConfigModel.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyStoreConfigModel.h"

@implementation HDMyStoreConfigModel

@end

@implementation HDMyStoreTimeConfigModel

-(NSString *)showTimes{
    _showTimes = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%@:00",_startTime],[NSString stringWithFormat:@"%@:00",_endTime]];
    return _showTimes;
}

@end
