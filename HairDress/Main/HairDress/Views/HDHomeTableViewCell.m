//
//  HDHomeTableViewCell.m
//  HairDress
//
//  Created by Apple on 2019/12/20.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDHomeTableViewCell.h"


@interface HDHomeTableViewCell()

@property (nonatomic,strong) UIImageView * imageShop;  // 店图
@property (nonatomic,strong) UIImageView * imageAdd;  // 地址图标
@property (nonatomic,strong) UILabel * lblShopName;  // 店名
@property (nonatomic,strong) UILabel * lblPrice;  // 店名
@property (nonatomic,strong) UILabel * lblDistance;  // 距离
@property (nonatomic,strong) UILabel * lblAddress;  // 地址
@property (nonatomic,strong) UILabel * lblPai;  // 排队标识
@property (nonatomic,strong) UILabel * lblPaiNum;  // 排队人数
@property (nonatomic,strong) UILabel * lblNeariest;  // 距离最近标识

@property (nonatomic,strong) UIButton * btnGoCut;  // 去剪发按钮

@property (nonatomic,strong) UIView *line;

@property (nonatomic,strong) UIView *viewTags;//标签


@end

@implementation HDHomeTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        [self addSubview:self.imageShop];
        [self addSubview:self.lblShopName];
        [self addSubview:self.lblPrice];
        [self addSubview:self.lblPai];
        [self addSubview:self.lblPaiNum];
        
        [self addSubview:self.btnGoCut];
        [self addSubview:self.lblDistance];
        [self addSubview:self.lblNeariest];
        
        [self addSubview:self.viewTags];
        [self addSubview:self.imageAdd];
        [self addSubview:self.lblAddress];
        [self addSubview:self.line];
    }
    
    return self;
}

-(void)setShopModel:(HDHomeShopListModel *)shopModel{
    _shopModel = shopModel;
    
    NSArray *arrColors = @[@{@"titleColor":RGBCOLOR(2, 165, 164),@"bgColor":RGBAlpha(2, 165, 164, 0.08)},
    @{@"titleColor":RGBCOLOR(254, 117, 7),@"bgColor":RGBAlpha(254, 117, 7, 0.08)},
  @{@"titleColor":RGBCOLOR(255, 74, 74),@"bgColor":RGBAlpha(255, 74, 74, 0.08)}];
    
    [_imageShop sd_setImageWithURL:[NSURL URLWithString:_shopModel.logoImg]];
    _lblShopName.text = _shopModel.storeName;
    
    if ([HDToolHelper StringIsNullOrEmpty:_shopModel.serverAmount] && [HDToolHelper StringIsNullOrEmpty:_shopModel.serverName]) {
        _lblPrice.text = @"";
    }else{
        _lblPrice.text = [NSString stringWithFormat:@"%@ ¥%.2f",_shopModel.serverName,[_shopModel.serverAmount floatValue]];
    }
    _lblPaiNum.text = [NSString stringWithFormat:@"%@人正在排队",_shopModel.queueNumber];
    
    _lblDistance.text = _shopModel.distanceDesc;
    [_lblDistance sizeToFit];
    
    _lblAddress.text = _shopModel.storeAddress;
    _lblAddress.numberOfLines = 0;
    [_lblAddress sizeToFit];
    
    for (int i=0; i<30; i++) {
        UILabel *lbl = (UILabel *)[_viewTags viewWithTag:100+i];
        lbl.hidden = YES;
    }
    if (_shopModel.serviceList.count == 0) {
        self.line.hidden = YES;
    }else{
        for (int i=0; i<_shopModel.serviceList.count; i++) {
            if (i<30) {
                UILabel *lblFeture = (UILabel *)[_viewTags viewWithTag:100+i];
                lblFeture.text = _shopModel.serviceList[i];
                lblFeture.hidden = NO;
                lblFeture.width = _viewTags.width;
                
                NSDictionary *dicColor = arrColors[i%3];
                lblFeture.backgroundColor = dicColor[@"bgColor"];
                lblFeture.textColor = dicColor[@"titleColor"];
                
                lblFeture.numberOfLines = 0;
                [lblFeture sizeToFit];
                lblFeture.width = lblFeture.width + 5*SCALE;
                if (lblFeture.height <= 16*SCALE) {
                    lblFeture.height = 16*SCALE;
                }
                else{
                    lblFeture.height = lblFeture.height +5*SCALE;
                }
                
                UILabel *lblLast = (UILabel *)[_viewTags viewWithTag:100+i-1];
                if (i==0) {
                    lblFeture.y = 0;
                    lblFeture.x = 0;
                }else{
                    
                    lblFeture.x = CGRectGetMaxX(lblLast.frame)+6*SCALE;
                    if (CGRectGetMaxX(lblFeture.frame) > _viewTags.width) {
                        lblFeture.x = 0;
                        lblFeture.y = CGRectGetMaxY(lblLast.frame)+6*SCALE;
                    }else{
                        lblFeture.y = lblLast.y;
                    }
                }
            }
        }
    }
}

-(void)setNearestDis:(NSString *)nearestDis{
    _nearestDis = nearestDis;
    if ([_nearestDis isEqualToString:@"1"]) {
        self.lblNeariest.hidden = NO;
    }else{
        self.lblNeariest.hidden = YES;
    }
}

#pragma mark ================== 加载控件 =====================

-(UIImageView *)imageShop{
    if (!_imageShop) {
        _imageShop = [[UIImageView alloc] initWithFrame:CGRectMake(24*SCALE, 12*SCALE, 72*SCALE, 72*SCALE)];
        _imageShop.contentMode = UIViewContentModeScaleAspectFill;
        _imageShop.clipsToBounds = YES;
        _imageShop.layer.cornerRadius = 6;
    }
    return _imageShop;
}

-(UIImageView *)imageAdd{
    if (!_imageAdd) {
        _imageAdd = [[UIImageView alloc] initWithFrame:CGRectMake(24*SCALE, _viewTags.bottom+21*SCALE, 14*SCALE, 14*SCALE)];
        _imageAdd.image = [UIImage imageNamed:@"common_ic_location"];
    }
    return _imageAdd;
}

-(UILabel *)lblAddress{
    if (!_lblAddress) {
        _lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(44*SCALE, _viewTags.bottom+21*SCALE, kSCREEN_WIDTH-44*SCALE-90*SCALE-41*SCALE, 10*SCALE)];
        _lblAddress.textColor = RGBAlpha(118, 118, 118, 1);
        _lblAddress.font = TEXT_SC_TFONT(TEXT_SC_Regular, 10*SCALE);
    }
    return _lblAddress;
}

-(UILabel *)lblShopName{
    if (!_lblShopName) {
        _lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageShop.frame)+8*SCALE, 16*SCALE, kSCREEN_WIDTH-CGRectGetMaxX(_imageShop.frame)-8*SCALE-16*SCALE, 16*SCALE)
                                                      title:@""
                                                    bgColor:[UIColor clearColor]
                                                 titleColor:RGBAlpha(51, 51, 51, 1)
                                                  titleFont:16*SCALE
                                              textAlignment:NSTextAlignmentLeft
                                                      isFit:NO];
        _lblShopName.font = TEXT_SC_TFONT(TEXT_SC_Semibold, 16*SCALE);
    }
    return _lblShopName;
}

-(UILabel *)lblDistance{
    if (!_lblDistance) {
        _lblDistance = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageShop.frame)+8*SCALE, _btnGoCut.y-14*SCALE-14*SCALE, 100*SCALE, 14*SCALE)
                title:@""
              bgColor:[UIColor clearColor]
           titleColor:[UIColor blackColor]
            titleFont:14*SCALE
        textAlignment:NSTextAlignmentRight
                isFit:NO];
        _lblDistance.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
    }
    return _lblDistance;
}

-(UILabel *)lblNeariest{
    if (!_lblNeariest) {
        _lblNeariest = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH-100*SCALE-12*SCALE, _lblDistance.y-9*SCALE-8*SCALE, 100*SCALE, 8*SCALE)
                title:@"离你最近"
              bgColor:[UIColor clearColor]
           titleColor:RGBCOLOR(211,0, 9)
            titleFont:8*SCALE
        textAlignment:NSTextAlignmentRight
                isFit:NO];
        _lblNeariest.font = TEXT_SC_TFONT(TEXT_SC_Regular, 8*SCALE);
    }
    return _lblNeariest;
}

-(UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imageShop.frame)+8*SCALE, _lblAddress.bottom+8*SCALE, kSCREEN_WIDTH-CGRectGetMaxX(_imageShop.frame)+8*SCALE, 1)];
        _line.backgroundColor = RGBCOLOR(239, 239, 239);
    }
    return _line;
}

-(UIView *)viewTags{
    if (!_viewTags) {
        _viewTags = [[UIView alloc] initWithFrame:CGRectMake(24*SCALE, CGRectGetMaxY(self.imageShop.frame)+8*SCALE, kSCREEN_WIDTH-24*SCALE-16*SCALE-90*SCALE, 16*SCALE)];
        
        for (int i = 0; i<30; i++) {
            UILabel *lblFeture = [[UILabel alloc] initCommonWithFrame:CGRectMake(i*56, 0, _viewTags.width, 16*SCALE) title:@"" bgColor:RGBAlpha(245, 34, 45, 0.08) titleColor:RGBMAIN titleFont:10*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];

            lblFeture.font = TEXT_SC_TFONT(TEXT_SC_Regular, 10*SCALE);
            lblFeture.tag = 100+i;
            lblFeture.hidden = YES;
            
            UILabel *lblLast = (UILabel *)[_viewTags viewWithTag:100+i-1];
            
            if (i==0) {
                lblFeture.y = 0;
                lblFeture.x = 0;
            }else{
                
                lblFeture.x = CGRectGetMaxX(lblLast.frame)+6*SCALE;
                if (CGRectGetMaxX(lblFeture.frame) > _viewTags.width) {
                    lblFeture.x = 0;
                    lblFeture.y = CGRectGetMaxY(lblLast.frame)+6*SCALE;
                }else{
                    lblFeture.y = lblLast.y;
                }
            }
            
            lblFeture.layer.cornerRadius = 2;
            
            [_viewTags addSubview:lblFeture];
        }
    }
    return _viewTags;
}

-(UILabel *)lblPrice{
    if (!_lblPrice) {
        _lblPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageShop.frame)+8*SCALE, CGRectGetMaxY(_lblShopName.frame)+10*SCALE, kSCREEN_WIDTH-CGRectGetMaxX(_imageShop.frame)-8*SCALE-100*SCALE-16*SCALE-10*SCALE,14*SCALE)
                title:@"洗剪吹 ¥38"
              bgColor:[UIColor clearColor]
           titleColor:RGBTEXT
            titleFont:14*SCALE
        textAlignment:NSTextAlignmentLeft
                isFit:NO];

        _lblPrice.font = TEXT_SC_TFONT(TEXT_SC_Regular, 14*SCALE);
    }
    return _lblPrice;
}

-(UILabel *)lblPai{
    if (!_lblPai) {
        _lblPai = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageShop.frame)+8*SCALE, CGRectGetMaxY(_lblPrice.frame)+10*SCALE, 10*SCALE,10*SCALE)
                title:@"排"
              bgColor:RGBMAIN
           titleColor:[UIColor whiteColor]
            titleFont:6*SCALE
        textAlignment:NSTextAlignmentCenter
                isFit:NO];

        _lblPai.layer.cornerRadius = 1.7;
        _lblPai.bottom = _imageShop.bottom-2;
        _lblPai.font = TEXT_SC_TFONT(TEXT_SC_Regular, 6*SCALE);
    }
    return _lblPai;
}

-(UILabel *)lblPaiNum{
    if (!_lblPaiNum) {
        _lblPaiNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_lblPai.frame)+4*SCALE, CGRectGetMaxY(_lblPrice.frame)+10*SCALE, kSCREEN_WIDTH-CGRectGetMaxX(_lblPai.frame)-4*SCALE-24*SCALE,10*SCALE)
                title:@"0人正在排队"
              bgColor:[UIColor clearColor]
           titleColor:RGBCOLOR(70, 70, 70)
            titleFont:10*SCALE
        textAlignment:NSTextAlignmentLeft
                isFit:NO];

        _lblPaiNum.centerY = _lblPai.centerY;
        _lblPaiNum.font = TEXT_SC_TFONT(TEXT_SC_Regular, 10*SCALE);
    }
    return _lblPaiNum;
}

-(UIButton *)btnGoCut{
    if (!_btnGoCut) {
        _btnGoCut = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-78*SCALE-12*SCALE, 38*SCALE, 78*SCALE, 28*SCALE) btnTitle:@"剪发预约" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14*SCALE];
        _btnGoCut.backgroundColor = RGBMAIN;
        _btnGoCut.layer.cornerRadius = 4;
        _btnGoCut.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Regular, 14*SCALE);
        
        _btnGoCut.userInteractionEnabled = NO;
    }
    return _btnGoCut;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageShop.frame = self.shopModel.logoImgFrame;
    self.viewTags.frame = self.shopModel.serviceListFrame;
    self.lblAddress.frame = self.shopModel.storeAddressFrame;
    self.btnGoCut.frame = self.shopModel.openFrame;
    self.lblDistance.frame = self.shopModel.distanceFrame;
    
    self.lblNeariest.y = self.lblDistance.y-9*SCALE-8*SCALE;
    self.imageAdd.y = _viewTags.bottom+21*SCALE;
    self.line.frame = self.shopModel.lineFrame;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
