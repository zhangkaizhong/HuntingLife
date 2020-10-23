//
//  HDRegisterTextFeild.h
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    BTN_VERCODE     = 0, // 发送验证码
    BTN_PWDHIDE    = 1, // 隐藏密码
    BTN_PWDVISIBLE  = 2, // 密码可见
}TextButtonType;

@protocol TextButtonClickDelete <NSObject>

-(void)clickBtnType:(UIButton *)sender btnType:(TextButtonType)type;

@end

@interface HDRegisterTextFeild : UIView

-(instancetype)initWithFrame:(CGRect)frame
placeHolder:(NSString *)holderStr
 titleImage:(NSString *)imageStr
                          btnImage:(NSString *)btnImageStr;

@property (nonatomic,assign) id<TextButtonClickDelete> delegate;

@property (nonatomic,assign) TextButtonType btnType;

@property (nonatomic,strong) UIButton * btn;  // 尾部按钮
@property (nonatomic,strong) HDTextFeild * txtFeild;  // 输入框

@end

NS_ASSUME_NONNULL_END
