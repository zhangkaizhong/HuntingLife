//
//  NavView.m
//  XgShop
//
//  Created by XIAO on 2018/8/20.
//  Copyright © 2018年 Cocav. All rights reserved.
//

#import "HDBaseNavView.h"

@interface HDBaseNavView()<UITextFieldDelegate>

/** 搜索框视图 */
@property (nonatomic,strong)UIButton *cityButton;
@property (nonatomic,strong)UIButton *rightButton;
@property (nonatomic,strong)UIImageView *searchImage;
@property (nonatomic,strong)UILabel *lblSearchView;

// 返回按钮
@property (nonatomic,weak) UIButton *backBtn;
@property (nonatomic,weak)UILabel *lblTitle;

@end
@implementation HDBaseNavView

// 创建带搜索框的导航栏
-(id)initSearchBarViewWithFrame:(CGRect)frame
                        bgColor:(UIColor *)backColor
                      textColor:(UIColor *)textColor
                searchViewColor:(UIColor *)searchViewColor
                        isWhite:(NSString *)isWhite
                    theDelegate:(id<navViewDelegate>)delegate{
    if (self = [super init]) {
        
        self.delegate = delegate;
        self.frame = frame;
        
        self.backgroundColor = backColor;
        
        self.searchView = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, NAVHIGHT-32*SCALE, kSCREEN_WIDTH-32*SCALE, 32*SCALE)];
        self.searchView.backgroundColor = [searchViewColor colorWithAlphaComponent:0.32];
        
        if ([isWhite isEqualToString:@"1"]) {
            self.searchView.y = NAVHIGHT-32*SCALE-7*SCALE;
            self.searchView.backgroundColor = searchViewColor;
        }
        [self addSubview:self.searchView];
        
        self.searchView.layer.cornerRadius = self.searchView.height/2;
        
        
        self.cityButton = [[UIButton alloc] initCustomWithFrame:CGRectMake(0, 0, 65*SCALE, self.searchView.height) btnTitle:@"厦门" btnImage:@"" btnType:RIGHT bgColor:[UIColor clearColor] titleColor:textColor titleFont:12*SCALE];
        [self.cityButton addTarget:self action:@selector(btnSelectCityAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.searchView addSubview:self.cityButton];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.cityButton.frame), 0, 0.5, 18*SCALE)];
        line.backgroundColor = textColor;
        if ([textColor isEqual:RGBTEXT]) {
            line.backgroundColor = RGBCOLOR(229, 229, 229);
            line.width = 1;
        }
        line.centerY = self.searchView.height/2;
        [self.searchView addSubview:line];
        
        self.searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_search_w"]];
        self.searchImage.centerY = self.searchView.height/2;
        self.searchImage.x = CGRectGetMaxX(line.frame)+5*SCALE;
        [self.searchView addSubview:self.searchImage];
        if ([backColor isEqual:[UIColor whiteColor]]) {
            self.searchImage.image = [UIImage imageNamed:@"common_ic_search_g"];
        }
        
        self.lblSearchView = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchImage.frame)+5*SCALE, 0, self.searchView.width-CGRectGetMaxX(self.searchImage.frame)-5*SCALE, 32*SCALE)];
        self.lblSearchView.textColor = textColor;
        self.lblSearchView.backgroundColor = [UIColor clearColor];
        self.lblSearchView.font = [UIFont systemFontOfSize:12*SCALE];
        self.lblSearchView.text = @"请输入发型师或门店名称";
        self.lblSearchView.alpha = 0.64;
        [self.searchView addSubview:self.lblSearchView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearchClick:)];
        self.lblSearchView.userInteractionEnabled = YES;
        [self.lblSearchView addGestureRecognizer:tap];
    }
    
    return self;
}

// 创建带按钮的搜索框
-(id)initSearchBarWithButtonsFrame:(CGRect)frame bgColor:(UIColor *)backColor textColor:(UIColor *)textColor searchViewColor:(UIColor *)searchViewColor btnTitle:(NSString *)btnTitle placeHolder:(NSString *)place theDelegate:(id<navViewDelegate>)delegate{
    
    if (self = [super init]) {
        
        self.delegate = delegate;
        self.frame = frame;
        
        self.backgroundColor = backColor;
        
        // 搜索框
        UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(40*SCALE, NAVHIGHT-8*SCALE-28*SCALE, kSCREEN_WIDTH-(8+40+34+16)*SCALE, 28*SCALE)];
        searchView.tag = 10000;
        searchView.backgroundColor = searchViewColor;
        searchView.layer.cornerRadius = 14*SCALE;
        [self addSubview:searchView];
        
        // 返回按钮
        UIButton *btnBack = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, 0, 40*SCALE, 19*SCALE) btnTitle:btnTitle btnImage:@"login_ic_back" titleColor:[UIColor clearColor] titleFont:0];
        btnBack.centerY = searchView.centerY;
        btnBack.tag = 20000;
        [self addSubview:btnBack];
        [btnBack addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        if ([backColor isEqual:RGBMAIN]) {
            [btnBack setImage:[UIImage imageNamed:@"common_ic_arrow_back_w"] forState:UIControlStateNormal];
        }
        // 搜索图标
        self.searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_search_w"]];
        self.searchImage.centerY = searchView.height/2;
        self.searchImage.x = 10*SCALE;
        self.searchImage.tag = 100;
        if ([backColor isEqual:[UIColor whiteColor]]) {
            self.searchImage.image = [UIImage imageNamed:@"common_ic_search_g"];
        }
        [searchView addSubview:self.searchImage];
        
        // 输入框
        HDTextFeild *txtSearch = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchImage.frame)+8*SCALE, 0, searchView.width-CGRectGetMaxX(self.searchImage.frame)-8*SCALE-5*SCALE, searchView.height)];
        txtSearch.placeholder = place;
        txtSearch.tintColor = RGBMAIN;
        txtSearch.tag = 200;
        txtSearch.textColor = RGBAlpha(51, 51, 51, 1);
        txtSearch.font = [UIFont systemFontOfSize:12*SCALE];
        txtSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
        [searchView addSubview:txtSearch];
        self.txtSearch = txtSearch;
        self.txtSearch.delegate = self;
        
        // 右边按钮
        if(![btnTitle isEqualToString:@""]){
            UIButton *rightBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(searchView.frame)+8, 0, 34, 28) btnTitle:btnTitle btnImage:@"" titleColor:RGBAlpha(51, 51, 51, 1) titleFont:14*SCALE];
            rightBtn.centerY = searchView.centerY;
            rightBtn.tag = 30000;
            if ([btnTitle isEqualToString:@"取消"]) {
                btnBack.hidden = YES;
                searchView.x = 12*SCALE;
                searchView.width = kSCREEN_WIDTH-(8+12+34+12)*SCALE;
            }
            if ([btnTitle isEqualToString:@"客服"]) {
                searchView.x = 24*SCALE;
                searchView.width = kSCREEN_WIDTH-24*SCALE-40*SCALE;
                
                rightBtn = [[UIButton alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(searchView.frame)+4*SCALE, searchView.y, 34*SCALE, 28*SCALE) btnTitle:btnTitle btnImage:@"featured_ic_service" btnType:Top_Msg bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:9*SCALE];
                btnBack.hidden = YES;
                self.searchImage.image = [UIImage imageNamed:@"common_ic_search_g"];
                self.txtSearch.width = searchView.width-CGRectGetMaxX(self.searchImage.frame)-8*SCALE-5*SCALE;
            }
            [self addSubview:rightBtn];
            [rightBtn addTarget:self action:@selector(btnRightClick) forControlEvents:UIControlEventTouchUpInside];
        }else{
            
            searchView.width = kSCREEN_WIDTH-8*SCALE-40*SCALE-16*SCALE;
            self.txtSearch.width = searchView.width-CGRectGetMaxX(self.searchImage.frame)-8*SCALE-5*SCALE;
            
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:place attributes:
            @{NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.5],NSFontAttributeName:txtSearch.font}];
            txtSearch.attributedPlaceholder = attrString;
        }
    }
    
    return self;
}

// 创建普通导航栏
-(id)initWithFrame:(CGRect)frame title:(NSString *)title bgColor:(UIColor *)backColor backBtn:(BOOL)isBackBtn rightBtn:(NSString *)rightTitle rightBtnImage:(NSString *)rightImage theDelegate:(id<navViewDelegate>)delegate{
    
    if (self = [super init]) {
        self.delegate = delegate;
        self.frame = frame;
        self.backgroundColor = backColor;
        
        UIButton *backBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(10*SCALE, NAVHIGHT-10*SCALE-28*SCALE, 32*SCALE, 32*SCALE) btnTitle:@"" btnImage:@"common_ic_arrow_back" titleColor:[UIColor clearColor] titleFont:0];
        backBtn.tag = 5000;
        if (isBackBtn) {
            self.backBtn = backBtn;
            [_backBtn addTarget:self action:@selector(backTapClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:backBtn];
        }
        
        UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, NAVHIGHT-14*SCALE-16*SCALE, 200*SCALE, 16*SCALE) title:title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:18 textAlignment:NSTextAlignmentCenter isFit:NO];
        lblTitle.tag = 6000;
        lblTitle.centerX = kSCREEN_WIDTH/2;
        lblTitle.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 18);
        if ([backColor isEqual: RGBMAIN]) {
            [backBtn setImage:[UIImage imageNamed:@"common_ic_arrow_back_w"] forState:UIControlStateNormal];
            lblTitle.textColor = [UIColor whiteColor];
        }
        [self addSubview:lblTitle];
        self.lblTitle = lblTitle;
        
        
        // 带图片按钮
        if (![rightImage isEqualToString:@""] && ![rightTitle isEqualToString:@""]) {
            UIButton *btnRight = [[UIButton alloc] initCustomWithFrame:CGRectMake(kSCREEN_WIDTH-70*SCALE-16*SCALE, 0, 70*SCALE, 24*SCALE) btnTitle:rightTitle btnImage:rightImage btnType:RIGHT bgColor:[UIColor whiteColor] titleColor:RGBTEXT titleFont:16*SCALE];
            [self addSubview:btnRight];
            btnRight.tag = 10000;
        }
        
        // 纯图片按钮
        if (![rightImage isEqualToString:@""] && [rightTitle isEqualToString:@""]) {
            UIButton *rightBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-19*SCALE-17*SCALE, NAVHIGHT-5*SCALE-16*SCALE, 27*SCALE, 27*SCALE) btnTitle:@"" btnImage:rightImage titleColor:[UIColor whiteColor] titleFont:0];
            [self addSubview:rightBtn];
            rightBtn.tag = 10000;
            self.rightButton = rightBtn;
            [self.rightButton addTarget:self action:@selector(btnRightClick) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.backBtn) {
                rightBtn.centerY = self.backBtn.centerY;
                
                if ([rightImage isEqualToString:@"shuaxin_black"]) {
                    UIButton *closeBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(self.backBtn.frame)+8*SCALE, 0, 30*SCALE, 30*SCALE) btnTitle:@"" btnImage:@"icon_close" titleColor:[UIColor whiteColor] titleFont:0];
                    closeBtn.centerY = rightBtn.centerY;
                    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:closeBtn];
                }
            }
        }
        // 纯文字按钮
        if ([rightImage isEqualToString:@""] && ![rightTitle isEqualToString:@""]) {
            UIButton *rightBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-35*SCALE-16*SCALE, NAVHIGHT-5*SCALE-16*SCALE, 35*SCALE, 27*SCALE) btnTitle:rightTitle btnImage:rightImage titleColor:[UIColor whiteColor] titleFont:14*SCALE];
            [self addSubview:rightBtn];
            rightBtn.tag = 10000;
            [rightBtn addTarget:self action:@selector(btnRightClick) forControlEvents:UIControlEventTouchUpInside];
            if ([backColor isEqual: RGBMAIN]) {
                rightBtn.titleLabel.textColor = [UIColor whiteColor];
            }
            if (rightTitle.length > 2) {
                if ([backColor isEqual:RGBMAIN]) {
                    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else{
                    [rightBtn setTitleColor:RGBMAIN forState:UIControlStateNormal];
                }
                rightBtn.x = kSCREEN_WIDTH-70*SCALE-16*SCALE;
                rightBtn.width = 70*SCALE;
            }
            if (self.backBtn) {
                rightBtn.centerY = self.backBtn.centerY;
            }
        }
    }
    
    
    return self;
}

// 设置title颜色
-(void)setTitleColor:(UIColor *)titleColor{
    self.lblTitle.textColor = titleColor;
}

//设置导航栏城市名称
-(void)setCityName:(NSString *)cityName{
    _cityName = cityName;
    [self.cityButton setTitle:cityName forState:UIControlStateNormal];
}

//设置右边按钮图片
-(void)setRightImage:(NSString *)rightImage{
    if ([rightImage isEqualToString:@""]) {
        rightImage = @"xxxxx";
    }
    [self.rightButton setImage:[UIImage imageNamed:rightImage] forState:UIControlStateNormal];
}

#pragma mark -- 输入框代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navTxtEndEditing:)]) {
        [self.delegate navTxtEndEditing:self.txtSearch.text];
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navTxtEndEditing:)]) {
        [self.delegate navTxtEndEditing:self.txtSearch.text];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navTxtEndEditing:)]) {
        [self.delegate navTxtEndEditing:self.txtSearch.text];
    }
}

#pragma mark -- 创建搜索框视图

#pragma mark -- 搜索 delegate
-(void)tapSearchClick:(UITapGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navClickSearchView)]) {
        [self.delegate navClickSearchView];
    }
}

// 返回按钮响应事件
-(void)backBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navBackClicked)]) {
        [self.delegate navBackClicked];
    }
}

//关闭按钮
-(void)closeBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navCloseClicked)]) {
        [self.delegate navCloseClicked];
    }
}

-(void)backTapClick:(UIGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navBackClicked)]) {
        [self.delegate navBackClicked];
    }
}

// 城市选择
-(void)btnSelectCityAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navClickCitySearch)]) {
        [self.delegate navClickCitySearch];
    }
}

// 右边按钮响应事件
-(void)btnRightClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navRightClicked)]) {
        [self.delegate navRightClicked];
    }
}


@end
