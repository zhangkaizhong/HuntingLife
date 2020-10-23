//
//  HDCutterWorkShowsModel.m
//  HairDress
//
//  Created by Apple on 2020/1/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDCutterWorkShowsModel.h"

@implementation HDCutterWorkShowsModel
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"work_show_id":@"id"};
}

-(CGFloat)cellHegiht{
    self.imageFrame = CGRectMake(0, 0, (kSCREEN_WIDTH-32-15)/2, 164);
    //门店地址frame
//    CGRect addressNewFrame = [self.worksName boundingRectWithSize:CGSizeMake((kSCREEN_WIDTH-32-15)/2-8-8, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
//    if (addressNewFrame.size.height <= 12) {
//        addressNewFrame.size.height = 12;
//    }
    self.labelFrame = CGRectMake(8, CGRectGetMaxY(self.imageFrame)+12, (kSCREEN_WIDTH-32-15)/2-8-8, 12);
    _cellHegiht = CGRectGetMaxY(self.labelFrame)+16;
    
    return _cellHegiht;
}

@end
