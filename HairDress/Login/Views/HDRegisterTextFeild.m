//
//  HDRegisterTextFeild.m
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDRegisterTextFeild.h"

@interface HDRegisterTextFeild()

@property (nonatomic,strong) UIImageView * titleImage;  // 图标

/** 按钮名 */
@property (nonatomic,copy) NSString *btnStr;

@end

@implementation HDRegisterTextFeild

-(instancetype)initWithFrame:(CGRect)frame
                     placeHolder:(NSString *)holderStr
                      titleImage:(NSString *)imageStr
                        btnImage:(NSString *)btnImageStr
{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = self.height/2;
        self.layer.borderWidth = 1;
        self.backgroundColor = RGBAlpha(250, 251, 250, 1);
        self.layer.borderColor = RGBAlpha(236, 236, 236, 1).CGColor;
        
        self.btnStr = btnImageStr;
        
        // 图标
        self.titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStr]];
        [self addSubview:self.titleImage];
        _titleImage.centerY = self.height/2;
        _titleImage.x = 15;
//        _titleImage.image = [UIImage imageNamed:imageStr];
        
        // 分割线
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleImage.frame)+8, 0, 1, 16)];
        line.backgroundColor = RGBAlpha(231, 231, 231, 1);
        line.centerY = self.height/2;
        [self addSubview:line];
        
        // 输入框
        [self addSubview:self.txtFeild];
        _txtFeild.placeholder = holderStr;
        
        if (![btnImageStr isEqualToString:@""]) {
            [self addSubview:self.btn];
        }else{
            self.txtFeild.width = self.width-CGRectGetMaxX(_titleImage.frame)-17;
            self.txtFeild.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
    }
    return self;
}

-(void)btnSeePwd:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if (sender.selected) { // 按下去了就是明文
        self.txtFeild.secureTextEntry = NO;
    } else { // 暗文
        self.txtFeild.secureTextEntry = YES;
    }
}

#pragma mark ================== 加载视图 =====================

//-(UIImageView *)titleImage{
//    if (!_titleImage) {
//        _titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 20*SCALE, 16*HEIGHT_SCALE)];
//        _titleImage.centerY = self.height/2;
//    }
//    return _titleImage;
//}

-(HDTextFeild *)txtFeild{
    if (!_txtFeild) {
        _txtFeild = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleImage.frame)+17, 0, self.width-CGRectGetMaxX(_titleImage.frame)-17-70, 20)];
        _txtFeild.centerY = self.height/2;
        _txtFeild.font = [UIFont systemFontOfSize:14.0f];
    }
    return _txtFeild;
}

-(UIButton *)btn{
    if (!_btn) {
        if ([self.btnStr isEqualToString:@"获取验证码"]) {
            _btn = [[UIButton alloc] initSystemWithFrame:CGRectMake(self.width-80, 0, 80, 20) btnTitle:self.btnStr btnImage:@"" titleColor:RGBAlpha(153, 153, 153, 1) titleFont:12];
            [_btn.titleLabel sizeToFit];
        }else{
            _btn = [[UIButton alloc] initSystemWithFrame:CGRectMake(self.width-50, 0, 50, self.height) btnTitle:@"" btnImage:@"login_input_ic_hidepassword" titleColor:[UIColor clearColor] titleFont:0];
            [_btn setImage:[UIImage imageNamed:@"login_input_ic_displaypassword"] forState:UIControlStateSelected];
            [_btn addTarget:self action:@selector(btnSeePwd:) forControlEvents:UIControlEventTouchUpInside];
        }
        _btn.centerY = self.height/2;
    }
    return _btn;
}

@end
