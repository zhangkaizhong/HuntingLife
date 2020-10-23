//
//  HDPersonalHomeHeaderView.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalHomeHeaderView.h"

@interface HDPersonalHomeHeaderView ()

@property (nonatomic,strong) UIView *redBackView;
@property (nonatomic,strong) UIView *whiteBackView;

@property (nonatomic,strong) UIImageView *headerImageView;
@property (nonatomic,strong) UILabel *lblName;

@property (nonatomic,strong) UILabel *lblMoney;

@end

@implementation HDPersonalHomeHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.redBackView];
        [self addSubview:self.whiteBackView];
        
        [self addSubview:self.headerImageView];
        [self addSubview:self.lblName];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_w"]];
        imageGo.x = kSCREEN_WIDTH-48;
        imageGo.centerY = _headerImageView.centerY;
        [self addSubview:imageGo];
        
        // 添加点击动作
        UIView *viewTap = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerImageView.y, kSCREEN_WIDTH, self.headerImageView.height)];
        [self addSubview:viewTap];
        viewTap.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPersonInfoAction:)];
        viewTap.userInteractionEnabled = YES;
        [viewTap addGestureRecognizer:tap];
        
    }
    return self;
}

-(void)setUserDic:(NSDictionary *)userDic{
    _userDic = userDic;

    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_userDic[@"headImg"]] placeholderImage:[UIImage imageNamed:@"personal_default"]];
    _lblName.text = _userDic[@"nickName"];
}

-(void)setProfitDic:(NSDictionary *)profitDic{
    _profitDic = profitDic;
    
    UILabel *lbl1 = (UILabel *)[_whiteBackView viewWithTag:10000];//今日预估收益
    UILabel *lbl2 = (UILabel *)[_whiteBackView viewWithTag:10001];//本月预估收益
    UILabel *lbl3 = (UILabel *)[_whiteBackView viewWithTag:10002];//上月结算
    UILabel *lbl4 = (UILabel *)[_whiteBackView viewWithTag:10003];//可提现余额
    
    lbl1.text = [NSString stringWithFormat:@"%.2f",[_profitDic[@"todayPredictFee"] floatValue]];
    lbl2.text = [NSString stringWithFormat:@"%.2f",[_profitDic[@"monthPredictFee"] floatValue]];
    lbl3.text = [NSString stringWithFormat:@"%.2f",[_profitDic[@"lastMonthSettledFee"] floatValue]];
    lbl4.text = [NSString stringWithFormat:@"%.2f",[_profitDic[@"canGetFee"] floatValue]];
    self.lblMoney.text = [NSString stringWithFormat:@"%.2f",[_profitDic[@"totalPredictFee"] floatValue]];
}

#pragma mark -- action

-(void)tapPersonInfoAction:(UIGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonalHeaderView:)]) {
        // 个人资料
        [self.delegate clickPersonalHeaderView:PersonalHeaderClickTypePersonInfo];
    }
}

// 说明
-(void)btnIntroAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPersonalHeaderView:)]) {
        [self.delegate clickPersonalHeaderView:PersonalHeaderClickTypeIntr];
    }
}

-(UIImageView *)headerImageView{
    if (!_headerImageView) {
        UIImageView *viewImageHeader = [[UIImageView alloc] init];
        viewImageHeader.frame = CGRectMake(24,72,54,54);
        viewImageHeader.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        viewImageHeader.layer.shadowOffset = CGSizeMake(0,1);
        viewImageHeader.layer.shadowOpacity = 1;
        viewImageHeader.layer.shadowRadius = 2;
        viewImageHeader.layer.masksToBounds = YES;
        viewImageHeader.layer.cornerRadius = 54/2;
        
        _headerImageView = viewImageHeader;
        
    }
    
    return _headerImageView;
}

-(UILabel *)lblName{
    if (!_lblName) {
        _lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame)+10, 0, 165, 20) title:@"" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:20 textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblName.centerY = _headerImageView.centerY;
    }
    return _lblName;
}

-(UIView *)redBackView{
    if (!_redBackView) {
        _redBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 198)];
        _redBackView.backgroundColor = RGBMAIN;
        _redBackView.tag = 10000;
        
    }
    return _redBackView;
}

-(UIView *)whiteBackView{
    if (!_whiteBackView) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(16,150,kSCREEN_WIDTH-32,154);

        view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        view.layer.cornerRadius = 8;
        view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.06].CGColor;
        view.layer.shadowOffset = CGSizeMake(0,6);
        view.layer.shadowOpacity = 1;
        view.layer.shadowRadius = 6;
        
        _whiteBackView = view;
        
        // 预估收益
        UILabel *lblYugu = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 24, _whiteBackView.width, 12) title:@"累计预估收益(元)" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        lblYugu.centerX = _whiteBackView.width/2;
        [_whiteBackView addSubview:lblYugu];
        
        self.lblMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblYugu.bottom+12, _whiteBackView.width, 28) title:@"0.00" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:28 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_whiteBackView addSubview:self.lblMoney];
        
        // line
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, _lblMoney.bottom+23, _whiteBackView.width-24, 1)];
        line.backgroundColor = RGBCOLOR(245, 245, 245);
        [_whiteBackView addSubview:line];
        
        NSArray *arr = @[@{@"title":@"今日预估",@"money":@"0.00"},@{@"title":@"本月预估",@"money":@"0.00"},@{@"title":@"上月结算",@"money":@"0.00"},@{@"title":@"当前余额",@"money":@"0.00"}];
        
        for (int i= 0; i<arr.count; i++) {
            
            UIView *subViewBack = [[UIView alloc] initWithFrame:CGRectMake(i*_whiteBackView.width/arr.count, line.bottom, _whiteBackView.width/arr.count, 58)];
            subViewBack.backgroundColor = [UIColor clearColor];
            if (i != 0) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 17, 1, 24)];
                line.backgroundColor = RGBCOLOR(245, 245, 245);
                [subViewBack addSubview:line];
            }
            
            UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 12, subViewBack.width, 12) title:arr[i][@"title"] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
            [subViewBack addSubview:lblTitle];
            
            UILabel *lblMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTitle.bottom+6, subViewBack.width, 16) title:arr[i][@"money"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentCenter isFit:NO];
            lblMoney.tag = 10000+i;
            [subViewBack addSubview:lblMoney];
            
            [_whiteBackView addSubview:subViewBack];
        }
        
        UIButton *btnDes = [[UIButton alloc] initCustomWithFrame:CGRectMake(_whiteBackView.width-55, 12, 38, 11) btnTitle:@"说明" btnImage:@"personal_ic_info" btnType:LeftCostom bgColor:[UIColor clearColor] titleColor:RGBCOLOR(202, 63, 50) titleFont:11];
//        [_whiteBackView addSubview:btnDes];
        [btnDes addTarget:self action:@selector(btnIntroAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _whiteBackView;
}


@end
