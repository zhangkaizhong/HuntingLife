//
//  UIButton+Custom.h
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Custom)

/**
 带图标的按钮
 */
-(UIButton *)initCustomWithFrame:(CGRect)frame
                  btnTitle:(NSString *)title
                  btnImage:(NSString *)imageStr
                   btnType:(BtnType)type
                   bgColor:(UIColor *)bgColor
                titleColor:(UIColor *)titleColor
                 titleFont:(CGFloat)fontsize;

/*
 不带图标
 */
-(UIButton *)initCommonWithFrame:(CGRect)frame
                  btnTitle:(NSString *)title
                   bgColor:(UIColor *)bgColor
                titleColor:(UIColor *)titleColor
                 titleFont:(CGFloat)fontsize;


/*
 系统
 */
-(UIButton *)initSystemWithFrame:(CGRect)frame
                  btnTitle:(NSString *)title
                  btnImage:(NSString *)imageStr
                titleColor:(UIColor *)titleColor
                 titleFont:(CGFloat)fontsize;

@end

NS_ASSUME_NONNULL_END
