//
//  HDOrderManageTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDOrderManageTableViewCell.h"

@interface HDOrderManageTableViewCell ()

@property (nonatomic,strong) UIView *viewPaiNum; // 排队号码
@property (nonatomic,weak) UILabel *lblPaiNum;

@property (nonatomic,strong) UIView *viewCutter; // 发型师
@property (nonatomic,weak) UILabel *lblCutterName;

@property (nonatomic,strong) UIView *viewService; // 服务项目
@property (nonatomic,weak) UILabel *lblService;

@property (nonatomic,strong) UIView *viewPrice; // 合计价格
@property (nonatomic,weak) UILabel *lblPrice;

@property (nonatomic,strong) UIView *viewGetNoTime; // 取号时间
@property (nonatomic,weak) UILabel *lblGetNoTime;

@property (nonatomic,strong) UIView *viewSignTime; // 到店时间
@property (nonatomic,weak) UILabel *lblSignTime;

@property (nonatomic,strong) UIView *viewDoneTime; // 完成时间
@property (nonatomic,weak) UILabel *lblDoneTime;

@property (nonatomic,strong) UIView *viewBtns;
@property (nonatomic,strong) UIButton *buttonService; //完成服务/开始服务
@property (nonatomic,strong) UIButton *buttonCancel;// 取消

@end

@implementation HDOrderManageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8)];
        line1.backgroundColor = RGBBG;
        [self.contentView addSubview:line1];
        
        [self.contentView addSubview:self.viewPaiNum];
        [self.contentView addSubview:self.viewCutter];
        [self.contentView addSubview:self.viewService];
        [self.contentView addSubview:self.viewPrice];
        [self.contentView addSubview:self.viewGetNoTime];
        
        [self.contentView addSubview:self.viewSignTime];
        
        [self.contentView addSubview:self.viewDoneTime];
        
        [self.contentView addSubview:self.viewBtns];
    }
    return self;
}

-(void)setModel:(HDStoreOrderListModel *)model{
    _model = model;
    
    self.lblPaiNum.text = _model.queueNum;
    self.lblCutterName.text = _model.tonyName;
    self.lblService.text = _model.serviceName;
    self.lblGetNoTime.text = _model.createTime;
    self.lblSignTime.text = _model.signTime;
    self.lblPrice.text = [NSString stringWithFormat:@"¥%.2f",[_model.totalAmount floatValue]];
    
    if ([_model.orderStatus isEqualToString:@"queue"]) {
        //普通店员查看预约
        if ([[HDUserDefaultMethods getData:@"storePost"] isEqualToString:@"O"]) {
            self.viewDoneTime.hidden = YES;
            self.viewBtns.hidden = YES;
            self.buttonCancel.hidden = YES;
            self.buttonService.hidden = YES;
        }
        //店主查看预约
        else{
            self.viewDoneTime.hidden = YES;
            self.viewBtns.y = _viewSignTime.bottom+16;
            self.buttonCancel.hidden = NO;
            [self.buttonService setTitle:@"开始服务" forState:UIControlStateNormal];
        }
        
    }else if ([_model.orderStatus isEqualToString:@"service"]){
        //普通店员查看预约
        if ([[HDUserDefaultMethods getData:@"storePost"] isEqualToString:@"O"]) {
            self.viewDoneTime.hidden = YES;
            self.viewBtns.hidden = YES;
            self.buttonCancel.hidden = YES;
            self.buttonService.hidden = YES;
        }
        //店主查看预约
        else{
            self.viewDoneTime.hidden = YES;
            self.viewBtns.y = _viewSignTime.bottom+16;
            self.buttonCancel.hidden = YES;
            [self.buttonService setTitle:@"完成服务" forState:UIControlStateNormal];
        }
    }else if ([_model.orderStatus isEqualToString:@"cancel"]){
        self.viewDoneTime.hidden = YES;
        self.viewSignTime.hidden = YES;
        self.viewBtns.hidden = YES;
        self.buttonCancel.hidden = YES;
        self.buttonService.hidden = YES;
    }else{
        self.viewDoneTime.hidden = NO;
        self.viewBtns.hidden = YES;
        
        self.lblDoneTime.text = [HDToolHelper StringIsNullOrEmpty:_model.finishTime] ? @"用户还未评价" : _model.finishTime;
    }
}

// 按钮点击事件
-(void)buttonAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"取消预约"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickOrderButtonType:withModel:)]) {
            [self.delegate clickOrderButtonType:ButtonTypeCancel withModel:_model];
        }
    }
    if ([sender.titleLabel.text isEqualToString:@"开始服务"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickOrderButtonType:withModel:)]) {
            [self.delegate clickOrderButtonType:ButtonTypeBegain withModel:_model];
        }
    }
    if ([sender.titleLabel.text isEqualToString:@"完成服务"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickOrderButtonType:withModel:)]) {
            [self.delegate clickOrderButtonType:ButtonTypeDone withModel:_model];
        }
    }
}

-(UIView *)viewPaiNum{
    if (!_viewPaiNum) {
        _viewPaiNum = [[UIView alloc] initWithFrame:CGRectMake(0, 16, kSCREEN_WIDTH, 28)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"排队号码" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewPaiNum addSubview:lbltext];
        lbltext.centerY = 28/2;
        
        UILabel *lblPaiNum= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewPaiNum.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblPaiNum.centerY = lbltext.centerY;
        self.lblPaiNum = lblPaiNum;
        [_viewPaiNum addSubview:self.lblPaiNum];
    }
    return _viewPaiNum;
}

-(UIView *)viewCutter{
    if (!_viewCutter) {
        _viewCutter = [[UIView alloc] initWithFrame:CGRectMake(0, _viewPaiNum.bottom, kSCREEN_WIDTH, 28)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"发型师" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewCutter addSubview:lbltext];
        lbltext.centerY = 28/2;
        
        UILabel *lblCutter= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewCutter.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblCutter.centerY = lbltext.centerY;
        self.lblCutterName = lblCutter;
        [_viewCutter addSubview:self.lblCutterName];
    }
    return _viewCutter;
}

-(UIView *)viewService{
    if (!_viewService) {
        _viewService = [[UIView alloc] initWithFrame:CGRectMake(0, _viewCutter.bottom, kSCREEN_WIDTH, 28)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"服务项目" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewService addSubview:lbltext];
        lbltext.centerY = 28/2;
        
        UILabel *lblService= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewService.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblService.centerY = lbltext.centerY;
        self.lblService = lblService;
        [_viewService addSubview:self.lblService];
    }
    return _viewService;
}

-(UIView *)viewPrice{
    if (!_viewPrice) {
        _viewPrice = [[UIView alloc] initWithFrame:CGRectMake(0, _viewService.bottom, kSCREEN_WIDTH, 28)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"合计" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewPrice addSubview:lbltext];
        lbltext.centerY = 28/2;
        
        UILabel *lblPrice= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewPrice.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblPrice.centerY = lbltext.centerY;
        self.lblPrice = lblPrice;
        [_viewPrice addSubview:self.lblPrice];
    }
    return _viewPrice;
}

-(UIView *)viewGetNoTime{
    if (!_viewGetNoTime) {
        _viewGetNoTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewPrice.bottom, kSCREEN_WIDTH, 28)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"取号时间" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewGetNoTime addSubview:lbltext];
        lbltext.centerY = 28/2;
        
        UILabel *lblgetTime= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewGetNoTime.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblgetTime.centerY = lbltext.centerY;
        self.lblGetNoTime = lblgetTime;
        [_viewGetNoTime addSubview:self.lblGetNoTime];
    }
    return _viewGetNoTime;
}

-(UIView *)viewSignTime{
    if (!_viewSignTime) {
        _viewSignTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewGetNoTime.bottom, kSCREEN_WIDTH, 28)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"到店时间" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewSignTime addSubview:lbltext];
        lbltext.centerY = 28/2;
        
        UILabel *lblSignTime= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewSignTime.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblSignTime.centerY = lbltext.centerY;
        self.lblSignTime = lblSignTime;
        [_viewSignTime addSubview:self.lblSignTime];
    }
    return _viewSignTime;
}

-(UIView *)viewDoneTime{
    if (!_viewDoneTime) {
        _viewDoneTime = [[UIView alloc] initWithFrame:CGRectMake(0, _viewSignTime.bottom, kSCREEN_WIDTH, 28)];
        
        UILabel *lbltext = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, 100, 14) title:@"完成时间" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewDoneTime addSubview:lbltext];
        lbltext.centerY = 28/2;
        
        UILabel *lblDoneTime= [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbltext.frame)+10, 0, _viewDoneTime.width-CGRectGetMaxX(lbltext.frame)-26, 14) title:@"2019-09-08 21:09:08" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblDoneTime.centerY = lbltext.centerY;
        self.lblDoneTime = lblDoneTime;
        [_viewDoneTime addSubview:self.lblDoneTime];
    }
    return _viewDoneTime;
}

// 按钮视图
-(UIView *)viewBtns{
    if (!_viewBtns) {
        _viewBtns = [[UIView alloc] initWithFrame:CGRectMake(0, _viewSignTime.bottom+16, kSCREEN_WIDTH, 48+37)];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 0, _viewBtns.width-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewBtns addSubview:line];
        
        [_viewBtns addSubview:self.buttonCancel];
        [_viewBtns addSubview:self.buttonService];
    }
    return _viewBtns;
}

-(UIButton *)buttonCancel{
    if (!_buttonCancel) {
        _buttonCancel = [[UIButton alloc] initSystemWithFrame:CGRectMake(32, 24, (kSCREEN_WIDTH-96)/2, 36) btnTitle:@"取消预约" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        _buttonCancel.layer.cornerRadius = 2;
        _buttonCancel.layer.borderWidth = 1;
        _buttonCancel.layer.borderColor = RGBMAIN.CGColor;
        
        [_buttonCancel addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCancel;
}

-(UIButton *)buttonService{
    if (!_buttonService) {
        _buttonService = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH/2+16, 24, (kSCREEN_WIDTH-96)/2, 36) btnTitle:@"开始服务" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
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

    // Configure the view for the selected state
}

@end
