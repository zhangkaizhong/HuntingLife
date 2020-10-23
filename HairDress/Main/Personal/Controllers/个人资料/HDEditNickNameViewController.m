//
//  HDEditNickNameViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDEditNickNameViewController.h"

@interface HDEditNickNameViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,weak) HDTextFeild *textNickName;
@property (nonatomic,strong) UIButton * btnComfirn;  // 确定

@end

@implementation HDEditNickNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    [self createUI];
    [self.view addSubview:self.btnComfirn];
}

#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//输入监听
-(void)textfieldChangedAction:(UITextField *)sender{
    if (self.textNickName.text.length > 15) {
        self.textNickName.text = [self.textNickName.text substringToIndex:15];
    }
}

// 确认
-(void)comfirnAction{
    if ([self.textNickName.text isEqualToString:@""]) {
        [SVHUDHelper showWorningMsg:@"请输入昵称" timeInt:1];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(editNickNameAction:)]) {
        [self.delegate editNickNameAction:self.textNickName.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// UI
-(void)createUI{
    UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(0, NAVHIGHT+12, kSCREEN_WIDTH, 89)];
    viewBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewBack];
    
    UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"昵称" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewBack addSubview:lblText];
    
    HDTextFeild *textName = [[HDTextFeild alloc] initWithFrame:CGRectMake(16, lblText.bottom+12, kSCREEN_WIDTH-32, 22)];
    textName.font = [UIFont systemFontOfSize:14];
    textName.placeholder = @"请输入昵称";
    [textName addTarget:self action:@selector(textfieldChangedAction:) forControlEvents:UIControlEventEditingChanged];
    
    if (self.nickName) {
        textName.text = self.nickName;
    }
    self.textNickName = textName;
    [viewBack addSubview:self.textNickName];
}

// 导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"设置昵称" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

// 确定
-(UIButton *)btnComfirn{
    if (!_btnComfirn) {
        _btnComfirn = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnComfirn.layer.cornerRadius = 24;
        _btnComfirn.backgroundColor = RGBMAIN;
        
        [_btnComfirn addTarget:self action:@selector(comfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnComfirn;
}


@end
