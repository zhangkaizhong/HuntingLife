//
//  NSString+Common.m
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "NSString+Common.h"


@implementation NSString (Common)

//判断是否为整形
- (BOOL)isNumber{
    if (self == nil || [self length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *filtered = [[self componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![self isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}

//判断是否是手机号码
- (BOOL)isPhoneNo{
    NSString *phoneRegex = @"1[2|3|4|5|6|7|8|9|][0-9]{9}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

//判断是否是座机
-(BOOL)isTelPhone{
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    return [phoneTest evaluateWithObject:self];
}

//富文本字符串
-(NSAttributedString *)setAttrText:(NSString *)targetString textColor:(UIColor *)txtColor setRange:(NSRange)range setColor:(UIColor *)color{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:targetString attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:14],NSForegroundColorAttributeName: txtColor}];
    // 字符串长度
    NSInteger length = [targetString length];
    [string addAttributes:@{NSForegroundColorAttributeName:color} range:NSMakeRange(0, 1)];
    [string addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: color} range:NSMakeRange(1, length-1)];
    [string addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: color} range:NSMakeRange(length-2, 2)];
    return string;
}

-(NSAttributedString *)setCustomAttrText:(NSString *)targetString textColor:(UIColor *)txtColor setBeginIndex:(NSInteger)begainIndex setLongth:(NSInteger)longth setColor:(UIColor *)color textFont:(NSInteger)intFont{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:targetString attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:intFont],NSForegroundColorAttributeName: txtColor}];
    // 字符串长度
//    NSInteger length = [targetString length];
    [string addAttributes:@{NSForegroundColorAttributeName:color} range:NSMakeRange(0, 1)];
    [string addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:intFont], NSForegroundColorAttributeName: color} range:NSMakeRange(begainIndex, longth)];
//    [string addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:intFont], NSForegroundColorAttributeName: color} range:NSMakeRange(length-2, 2)];
    return string;
}

@end
