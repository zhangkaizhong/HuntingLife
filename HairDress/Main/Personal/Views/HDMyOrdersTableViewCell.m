//
//  HDMyOrdersTableViewCell.m
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyOrdersTableViewCell.h"

@interface HDMyOrdersTableViewCell ()

@property (nonatomic,strong) UIView *viewPaiNum; // 排队号码
@property (nonatomic,weak) UILabel *lblPaiNum;

@property (nonatomic,strong) UIView *viewService; // 服务项目
@property (nonatomic,weak) UILabel *lblService;

@property (nonatomic,strong) UIView *viewGetNoTime; // 取号时间
@property (nonatomic,weak) UILabel *lblGetNoTime;

@property (nonatomic,strong) UIView *viewDoneTime; // 完成时间
@property (nonatomic,weak) UILabel *lblDoneTime;

@property (nonatomic,strong) UIButton *buttonService; //完成服务/开始服务

@end

@implementation HDMyOrdersTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8)];
        line1.backgroundColor = RGBBG;
        [self.contentView addSubview:line1];
        
        [self.contentView addSubview:self.viewPaiNum];
        [self.contentView addSubview:self.viewService];
        [self.contentView addSubview:self.viewGetNoTime];
        
        [self.contentView addSubview:self.viewDoneTime];
        
        [self.contentView addSubview:self.buttonService];
    }
    return self;
}

-(void)setModel:(HDTonyOrderListModel *)model{
    _model = model;
    
    if ([_model.orderStatus isEqualToString:@"wait"] || [_model.orderStatus isEqualToString:@"queue"]) {
        self.viewDoneTime.hidden = YES;
        self.buttonService.hidden = NO;
        [self.buttonService setTitle:@"开始服务" forState:UIControlStateNormal];
    }else if ([_model.orderStatus isEqualToString:@"service"]){
        self.viewDoneTime.hidden = YES;
        self.buttonService.hidden = NO;
        [self.buttonService setTitle:@"完成服务" forState:UIControlStateNormal];
    }else{
        self.viewDoneTime.hidden = NO;
        _lblDoneTime.text = [HDToolHelper StringIsNullOrEmpty:_model.finishTime] ? @"用户还未评价" : _model.finishTime;
        self.buttonService.hidden = YES;
    }
    
    _lblGetNoTime.text = _model.createTime;
    _lblPaiNum.text = _model.queueNum;
    _lblService.text = _model.serviceName;
}

#pragma mark ================== action =====================
// 按钮点击事件
-(void)buttonAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"开始服务"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickOrderButtonType:model:)]) {
            [self.delegate clickOrderButtonType:MyOrdersButtonTypeBegain model:_model];
        }
    }
    if ([sender.titleLabel.text isEqualToString:@"完成服务"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickOrderButtonType:model:)]) {
            [self.delegate clickOrderButtonType:MyOrdersButtonTypeDone model:_model];
        }
    }
}

#pragma mark ================== 加载控件 =====================

-(UIView *)viewPaiNum{
    if (!_viewPaiNum) {
        _viewPaiNum = [[UIView alloc] initWithFrame:CGRectMake(0, 28, kSCREEN_WIDTH, 24)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"排队号码：" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewPaiNum addSubview:lbltext];
        lbltext.centerY = 24/2;
        
        UILabel *lblPaiNum= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewPaiNum.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"D009" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblPaiNum.centerY = lbltext.centerY;
        self.lblPaiNum = lblPaiNum;
        [_viewPaiNum addSubview:self.lblPaiNum];
    }
    return _viewPaiNum;
}

-(UIView *)viewService{
    if (!_viewService) {
        _viewService = [[UIView alloc] initWithFrame:CGRectMake(0, _viewPaiNum.bottom, kSCREEN_WIDTH, 24)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"服务项目：" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewService addSubview:lbltext];
        lbltext.centerY = 24/2;
        
        UILabel *lblService= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewService.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"洗剪吹" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblService.centerY = lbltext.centerY;
        self.lblService = lblService;
        [_viewService addSubview:self.lblService];
    }
    return _viewService;
}

-(UIView *)viewGetNoTime{
    if (!_viewGetNoTime) {
        _viewGetNoTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewService.bottom, kSCREEN_WIDTH, 24)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"取号时间：" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewGetNoTime addSubview:lbltext];
        lbltext.centerY = 24/2;
        
        UILabel *lblGetNoTime= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewGetNoTime.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"2019-09-09 08:28:19" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblGetNoTime.centerY = lbltext.centerY;
        self.lblGetNoTime = lblGetNoTime;
        [_viewGetNoTime addSubview:self.lblGetNoTime];
    }
    return _viewGetNoTime;
}

-(UIView *)viewDoneTime{
    if (!_viewDoneTime) {
        _viewDoneTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewGetNoTime.bottom, kSCREEN_WIDTH, 24)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"完成时间：" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        [_viewDoneTime addSubview:lbltext];
        lbltext.centerY = 24/2;
        
        UILabel *lblDoneTime= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewDoneTime.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"2019-09-09 08:28:19" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblDoneTime.centerY = lbltext.centerY;
        self.lblDoneTime = lblDoneTime;
        [_viewDoneTime addSubview:self.lblDoneTime];
    }
    return _viewDoneTime;
}

-(UIButton *)buttonService{
    if (!_buttonService) {
        _buttonService = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-88-16, 38, 88, 36) btnTitle:@"开始服务" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _buttonService.layer.cornerRadius = 2;
        _buttonService.backgroundColor = RGBMAIN;
        [_buttonService addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonService;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
