//
//  HDMyShopWaiterTableViewCell.m
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyShopWaiterTableViewCell.h"

@interface HDMyShopWaiterTableViewCell ()

@property (nonatomic,strong) UIImageView * imageHeader;  // 头像
@property (nonatomic,weak) UIImageView * imagePhone;  //
@property (nonatomic,strong) UILabel * lblName;  // 名字
@property (nonatomic,strong) UILabel * lblSex;  // 性别
@property (nonatomic,strong) UILabel * lblNo;  // 工号
@property (nonatomic,strong) UILabel * lblWaiterType;  // 店员类型
@property (nonatomic,strong) UILabel * lblPhone;  // 电话
@property (nonatomic,strong) UILabel * lblAddTime;  // 加入时间

@property (nonatomic,strong) UIButton * buttonChange;  // 变更岗位
@property (nonatomic,strong) UIButton * buttonDelete;  // 删除店员
@property (nonatomic,strong) UIView * line;  //
@property (nonatomic,weak) UIView * line2;  // 变更岗位

@end

@implementation HDMyShopWaiterTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8)];
        line1.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line1];
        
        [self.contentView addSubview:self.imageHeader];
        [self.contentView addSubview:self.lblName];
        [self.contentView addSubview:self.lblSex];
        [self.contentView addSubview:self.line];
        [self.contentView addSubview:self.lblNo];
        [self.contentView addSubview:self.lblWaiterType];
        
        [self.contentView addSubview:self.buttonDelete];
        [self.contentView addSubview:self.buttonChange];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(16, _imageHeader.bottom+16, kSCREEN_WIDTH-32, 1)];
        line2.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line2];
        self.line2 = line2;
        
        UIImageView *imagePhone = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.line2.bottom+10, 16, 16)];
        imagePhone.image = [UIImage imageNamed:@"login_error_ic_phone"];
        self.imagePhone = imagePhone;
        [self.contentView addSubview:self.imagePhone];
        [self.contentView addSubview:self.lblPhone];
        [self.contentView addSubview:self.lblAddTime];
    }
    return self;
}

-(void)setModel:(HDStoreWaiterListModel *)model{
    _model = model;
    
    [self.imageHeader sd_setImageWithURL:[NSURL URLWithString:_model.headImg]];
    self.lblName.text = _model.userName;
    self.lblSex.text = _model.gender;
    self.lblPhone.text = _model.phone;
    self.lblNo.text = _model.tonyId;
    [self.lblNo sizeToFit];
    _lblNo.centerY = _lblSex.centerY;
    
    self.lblAddTime.text = [NSString stringWithFormat:@"%@加入",_model.storeStartTime];
    if ([_model.storePost isEqualToString:@"T"]) {
        self.lblWaiterType.text = @"发型师";
    }else{
        self.lblWaiterType.text = @"普通店员";
    }
}

// 变更岗位
-(void)changeTypeAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickChangeShopWaiterType:withModel:)]) {
        [self.delegate clickChangeShopWaiterType:sender.titleLabel.text withModel:_model];
    }
}

// 删除店员
-(void)deleteWaiterAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickChangeShopWaiterType:withModel:)]) {
        [self.delegate clickChangeShopWaiterType:sender.titleLabel.text withModel:_model];
    }
}

#pragma mark ================== 加载控件 =====================

-(UIImageView *)imageHeader{
    if (!_imageHeader) {
        _imageHeader = [[UIImageView alloc] initWithFrame:CGRectMake(16, 28, 72, 72)];
        _imageHeader.image = [UIImage imageNamed:@"4.jpg"];
        _imageHeader.layer.cornerRadius = 4;
        _imageHeader.layer.masksToBounds = YES;
    }
    return _imageHeader;
}

-(UILabel *)lblName{
    if (!_lblName) {
        _lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageHeader.frame)+12, _imageHeader.y+4, 200, 16) title:@"又见tony老师" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblName;
}

- (UILabel *)lblSex{
    if (!_lblSex) {
        _lblSex = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageHeader.frame)+12, _lblName.bottom+10, 50, 12) title:@"男" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:YES];
    }
    return _lblSex;
}

- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lblSex.frame)+4, 0, 1, 12)];
        _line.backgroundColor = RGBLIGHT_TEXTINFO;
        _line.centerY = _lblSex.centerY;
    }
    return _line;
}

-(UILabel *)lblNo{
    if (!_lblNo) {
        _lblNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_line.frame)+4, 0, 150, 12) title:@"001" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:YES];
        _lblNo.centerY = _lblSex.centerY;
    }
    return _lblNo;
}

-(UILabel *)lblWaiterType{
    if (!_lblWaiterType) {
        _lblWaiterType = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageHeader.frame)+12, _lblSex.bottom+10, 150, 12) title:@"发型师" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblWaiterType;
}

-(UIButton *)buttonChange{
    if (!_buttonChange) {
        _buttonChange = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16-76, _lblName.bottom+8, 76, 36) btnTitle:@"变更岗位" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _buttonChange.layer.cornerRadius = 2;
        _buttonChange.backgroundColor = RGBMAIN;
        
        [_buttonChange addTarget:self action:@selector(changeTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonChange;
}

-(UIButton *)buttonDelete{
    if (!_buttonDelete) {
        _buttonDelete = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16-76-10-76, _lblName.bottom+8, 76, 36) btnTitle:@"删除店员" btnImage:@"" titleColor:RGBMAIN titleFont:14];
        _buttonDelete.layer.cornerRadius = 2;
        _buttonDelete.layer.borderColor = RGBMAIN.CGColor;
        _buttonDelete.layer.borderWidth = 1;
        
        [_buttonDelete addTarget:self action:@selector(deleteWaiterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonDelete;
}

-(UILabel *)lblPhone{
    if (!_lblPhone) {
        _lblPhone = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imagePhone.frame)+9, 0, 150, 12) title:@"13089898989" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:YES];
        _lblPhone.centerY = _imagePhone.centerY;
    }
    return _lblPhone;
}

-(UILabel *)lblAddTime{
    if (!_lblAddTime) {
        _lblAddTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2-16, 12) title:@"2019-12-20加入" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        _lblAddTime.centerY = _imagePhone.centerY;
    }
    return _lblAddTime;
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
