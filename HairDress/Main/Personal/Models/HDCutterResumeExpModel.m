//
//  HDCutterResumeExpModel.m
//  HairDress
//
//  Created by Apple on 2020/1/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDCutterResumeExpModel.h"

@implementation HDCutterResumeExpModel

-(CGFloat)cellHeight{
    
    CGRect rect = [_storeName boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
    CGSize size = rect.size;
    CGFloat h = size.height;
    
    if (h<14) {
        h = 14;
    }
    _cellHeight = 81-14+h;
    
    return _cellHeight;
}

@end
