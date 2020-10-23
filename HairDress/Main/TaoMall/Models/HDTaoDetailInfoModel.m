//
//  HDTaoDetailInfoModel.m
//  HairDress
//
//  Created by Apple on 2020/1/16.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoDetailInfoModel.h"

@implementation HDTaoDetailInfoModel

-(NSArray *)contentImages{
    if ([self.pcDescContent isEqualToString:@""]) {
        return @[];
    }
    NSArray *array = [self.pcDescContent componentsSeparatedByString:@"|"];
    
    NSMutableArray *arr = [NSMutableArray new];
    for (NSString *str in array) {
        [arr addObject:[NSString stringWithFormat:@"https:%@",str]];
    }
    _contentImages = arr;
    
    return _contentImages;
}

-(NSArray *)smallImagesArr{
    NSMutableArray *arr = [NSMutableArray new];
    
    NSArray *sArr = [self.smallImages componentsSeparatedByString:@"|"];
    [arr addObject:self.pictUrl];
    [arr addObjectsFromArray:sArr];
    
    return arr;
}

@end
