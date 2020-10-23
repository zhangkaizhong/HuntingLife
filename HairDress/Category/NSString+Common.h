//
//  NSString+Common.h
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Common)

//判断字符串是否为整型
- (BOOL)isNumber;
//判断是否是手机号码
- (BOOL)isPhoneNo;
//判断是否是座机号码
-(BOOL)isTelPhone;

// 富文本字符串
-(NSAttributedString *)setAttrText:(NSString *)targetString
                         textColor:(UIColor *)txtColor  
                setRange:(NSRange)range
                setColor:(UIColor *)color;

-(NSAttributedString *)setCustomAttrText:(NSString *)targetString textColor:(UIColor *)txtColor setBeginIndex:(NSInteger)begainIndex setLongth:(NSInteger)longth setColor:(UIColor *)color textFont:(NSInteger)intFont;

@end

NS_ASSUME_NONNULL_END
