//
//  PersonInfoModel.m
//  HairDress
//
//  Created by 张凯中 on 2020/5/27.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "NewPersonInfoModel.h"

@implementation NewPersonInfoModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
        @"userCancelNum":@"cancelNum",
        @"userFinishNum":@"finishNum",
        @"userPayNum":@"payNum",
        @"userServiceNum":@"serviceNum",
        @"userWaitOrQueueNum":@"waitOrQueueNum"
    };
}

@end
