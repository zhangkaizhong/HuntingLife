//
//  UILabel+Custom.h
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Custom)

-(UILabel *)initCustomWithFrame:(CGRect)frame
                          title:(NSString *)title
                        bgColor:(UIColor *)bgColor
                     titleColor:(UIColor *)titleColor
                      titleFont:(CGFloat)fontsize;


-(UILabel *)initCommonWithFrame:(CGRect)frame
                          title:(NSString *)title
                        bgColor:(UIColor *)bgColor
                     titleColor:(UIColor *)titleColor
                      titleFont:(CGFloat)fontsize
                  textAlignment:(NSTextAlignment)textAlignment
                          isFit:(BOOL)isFit;

//两端对齐
- (void)textAlignmentLeftAndRight;
//指定Label以最后的冒号对齐的width两端对齐
- (void)textAlignmentLeftAndRightWith:(CGFloat)labelWidth;


@end

NS_ASSUME_NONNULL_END
