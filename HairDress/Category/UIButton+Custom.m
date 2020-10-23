//
//  UIButton+Custom.m
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "UIButton+Custom.h"


@implementation UIButton (Custom)

/*
 带图标按钮
 */
-(UIButton *)initCustomWithFrame:(CGRect)frame
                    btnTitle:(NSString *)title
                    btnImage:(NSString *)imageStr
                     btnType:(BtnType)type
                     bgColor:(UIColor *)bgColor
                  titleColor:(UIColor *)titleColor
                   titleFont:(CGFloat)fontsize
{
    HDButton *btn = [HDButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.btnType = type;
    btn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundColor:bgColor];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    return btn;
}

/*
 不带图标按钮
 */
-(UIButton *)initCommonWithFrame:(CGRect)frame
                  btnTitle:(NSString *)title
                   bgColor:(UIColor *)bgColor
                titleColor:(UIColor *)titleColor
                titleFont:(CGFloat)fontsize
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundColor:bgColor];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    return btn;
}


/*
 系统按钮
 */
 -(UIButton *)initSystemWithFrame:(CGRect)frame
                   btnTitle:(NSString *)title
                   btnImage:(NSString *)imageStr
                 titleColor:(UIColor *)titleColor
                  titleFont:(CGFloat)fontsize
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    if (![title isEqualToString:@""]) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (![imageStr isEqualToString:@""]) {
        [btn setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    }
    
    return btn;
}

@end
