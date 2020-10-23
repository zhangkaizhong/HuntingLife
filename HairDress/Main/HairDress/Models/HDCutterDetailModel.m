//
//  YHWorkGroup.m
//  github:  https://github.com/samuelandkevin
//  CSDN:  http://blog.csdn.net/samuelandkevin
//  Created by samuelandkevin on 16/5/5.
//  Copyright © 2016年 HKP. All rights reserved.
//

#import "HDCutterDetailModel.h"
#import <UIKit/UIKit.h>


@implementation HDCutterDetailModel

- (NSString *)workingLifeText{
    NSString *str = self.workingLife;
    str = [NSString stringWithFormat:@"%@年工作经验",str];
    _workingLifeText = str;
    return _workingLifeText;
}

@end
