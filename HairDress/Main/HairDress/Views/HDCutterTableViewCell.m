//
//  HDCutterTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/22.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCutterTableViewCell.h"

@interface HDCutterTableViewCell ()

@property (nonatomic,strong) UILabel *lblCutterName; // 发型师昵称
@property (nonatomic,strong) UILabel *lblPrice; // 价格
@property (nonatomic,strong) UILabel *lblExperience; // 工作经验
@property (nonatomic,strong) UILabel *lblServiceAim; // 服务宗旨

@property (nonatomic,strong) UIView *shopNameView;// 门店名称视图
@property (nonatomic,strong) UILabel *lblShopName; // 门店名称
@property (nonatomic,strong) UILabel *lblDistance; // 距离
@property (nonatomic,strong) UIImageView *imgGo;
@property (nonatomic,strong) UIImageView *imgDistance;

@property (nonatomic,strong) UIImageView * imgCutter; // 发型师图片

@property (nonatomic,strong) UIView *fetureView; // 技术特点view
@property (nonatomic,strong) UIImageView *imgFeture; // 技术特点图标

@property (nonatomic,strong) UIButton *btnGetNum; // 取号按钮

@property (nonatomic,strong) UILabel * lblPai;  // 排队标识
@property (nonatomic,strong) UILabel * lblQueueNumber;  // 排队人数
@property (nonatomic,strong) UIView * paiView; // 排队人数view

//@property (nonatomic,strong) UIView *viewBlock;

@end

@implementation HDCutterTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
            
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.layer.cornerRadius = 6;
        self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.16].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,1);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 4;
        
        [self.contentView addSubview:self.imgCutter];
        
        [self.contentView addSubview:self.lblCutterName];
        [self.contentView addSubview:self.lblExperience];
        [self.contentView addSubview:self.btnGetNum];
        
//        [self.contentView addSubview:self.paiView];
        [self.contentView addSubview:self.lblQueueNumber];
        
        [self.contentView addSubview:self.lblPrice];
        
        [self.contentView addSubview:self.fetureView];
        
        [self.contentView addSubview:self.lblServiceAim];

        [self.contentView addSubview:self.shopNameView];
//        [self.contentView addSubview:self.viewBlock];
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame{
    
    frame.origin.x += 16;
    frame.origin.y += 8;
    frame.size.height -= 8;
    frame.size.width -= 32;
    [super setFrame:frame];
}

-(void)setModel:(HDShopCutterListModel *)model{
    _model = model;
    
    [_imgCutter sd_setImageWithURL:[NSURL URLWithString:_model.headImg] placeholderImage:[UIImage imageNamed:@"barber_avatar"]];
    _lblCutterName.text = _model.userName;
    [_lblCutterName sizeToFit];

    _lblExperience.text = [NSString stringWithFormat:@"%@年工作经验",_model.workingLife];
    [_lblExperience sizeToFit];
    _lblExperience.height = 16;
    _lblExperience.width = _lblExperience.width+8;
    _lblExperience.x = CGRectGetMaxX(_lblCutterName.frame)+8;
    
    //UI重新布局
    if (CGRectGetMaxX(_lblExperience.frame)+10 > _btnGetNum.x) {
        _lblExperience.x = _btnGetNum.x -_lblExperience.width-10;
        _lblCutterName.width = _lblExperience.x - 8 - 12 -CGRectGetMaxX(_imgCutter.frame);
    }
    
    _lblPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[_model.serverAmount floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
    [_lblPrice sizeToFit];
    
    _lblQueueNumber.text = [NSString stringWithFormat:@"%@人正在排队",_model.queueNumber];
    [_lblQueueNumber sizeToFit];
    _lblQueueNumber.height = 12;

    
    for (int i=0; i<30; i++) {
        UILabel *lblFeture = (UILabel *)[_fetureView viewWithTag:100+i];
        lblFeture.hidden = YES;
    }
//    NSArray *arr = _model.labels;
//    if (arr.count == 0) {
        self.imgFeture.hidden = YES;
//    }else{
//        self.imgFeture.hidden = NO;
//        for (int i=0; i<arr.count; i++) {
//            if (i<30) {
//                UILabel *lblFeture = (UILabel *)[_fetureView viewWithTag:100+i];
//                lblFeture.text = arr[i];
//                lblFeture.hidden = NO;
//                lblFeture.width = kSCREEN_WIDTH - 36-26;
//
//                lblFeture.numberOfLines = 0;
//                [lblFeture sizeToFit];
//                lblFeture.width = lblFeture.width + 5;
//                if (lblFeture.height < 16) {
//                    lblFeture.height = 16;
//                }
//                else{
//                    lblFeture.height = lblFeture.height +5;
//                }
//
//                UILabel *lblLast = (UILabel *)[_fetureView viewWithTag:100+i-1];
//                if (i==0) {
//                    lblFeture.y = 0;
//                    lblFeture.x = 36;
//                }else{
//
//                    lblFeture.x = CGRectGetMaxX(lblLast.frame)+8;
//                    if (CGRectGetMaxX(lblFeture.frame)+16 > (kSCREEN_WIDTH-36)) {
//                        lblFeture.x = 36;
//                        lblFeture.y = CGRectGetMaxY(lblLast.frame)+8;
//                    }else{
//                        lblFeture.y = lblLast.y;
//                    }
//                }
//
//                _fetureView.height = lblFeture.bottom;
//            }
//        }
//    }
    
    //服务宗旨
    self.lblServiceAim.width = kSCREEN_WIDTH-32;
    self.lblServiceAim.text = [NSString stringWithFormat:@"服务宗旨：%@",_model.serviceTenet];
    self.lblServiceAim.numberOfLines = 0;
    [self.lblServiceAim sizeToFit];
    
    if ([_model.isDetail isEqualToString:@"1"]) {
        self.shopNameView.hidden = YES;
    }
    else{
        _lblShopName.width = kSCREEN_WIDTH-32;
        _lblShopName.text = _model.storeAddress;
        _lblShopName.numberOfLines = 0;
        [_lblShopName sizeToFit];
        self.shopNameView.hidden = NO;
    }
}

//重新布局UI
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.imgCutter.frame = self.model.cutterImgFrame;
    self.fetureView.frame = self.model.viewTagsFrame;
    self.lblServiceAim.frame = self.model.tenetFrame;
    self.shopNameView.frame = self.model.viewAddressFrame;
//    self.viewBlock.frame = self.model.viewBlockFrame;
}

-(void)btnGetNumAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickGenumAction:)]) {
        [self.delegate clickGenumAction:_model];
    }
}

#pragma mark -- 加载控件

-(UIImageView *)imgCutter{
    if (!_imgCutter) {
        _imgCutter = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 72, 72)];
        _imgCutter.contentMode = UIViewContentModeScaleAspectFill;
        _imgCutter.clipsToBounds = YES;
        _imgCutter.layer.cornerRadius = 4;
    }
    
    return _imgCutter;
}

-(UIButton *)btnGetNum{
    if (!_btnGetNum) {
        _btnGetNum = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-20-26-58, 0, 58, 24) btnTitle:@"取号" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:16];
        _btnGetNum.centerY = _imgCutter.centerY;
        _btnGetNum.backgroundColor = RGBMAIN;
        _btnGetNum.layer.cornerRadius = 2;
        
        [_btnGetNum addTarget:self action:@selector(btnGetNumAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnGetNum;
}

//发型师名称
-(UILabel *)lblCutterName{
    if (!_lblCutterName) {
        _lblCutterName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgCutter.frame)+12, 24, 100, 16)];
        _lblCutterName.font = TEXT_SC_TFONT(TEXT_SC_Regular, 16*SCALE);
        _lblCutterName.textColor = RGBCOLOR(26, 25, 32);
    }
    
    return _lblCutterName;
}

//工作经验
-(UILabel *)lblExperience{
    if (!_lblExperience) {
        _lblExperience = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lblCutterName.frame)+8, 0, 70, 16)];
        _lblExperience.centerY = _lblCutterName.centerY;
        _lblExperience.font = [UIFont systemFontOfSize:10];
        _lblExperience.backgroundColor = RGBCOLOR(241, 135, 112);
        _lblExperience.textColor = [UIColor whiteColor];
        _lblExperience.textAlignment = NSTextAlignmentCenter;
        
        _lblExperience.layer.cornerRadius = 2;
//        _lblExperience.layer.borderWidth = 1;
//        _lblExperience.layer.borderColor = RGBMAIN.CGColor;
    }
    
    return _lblExperience;
}

-(UIView *)paiView{
    if (!_paiView) {
        _paiView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgCutter.frame)+12, _lblCutterName.bottom+8, 150, 12)];
//        [_paiView addSubview:self.lblPai];
        [_paiView addSubview:self.lblQueueNumber];
    }
    return _paiView;
}

-(UILabel *)lblPai{
    if (!_lblPai) {
        _lblPai = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _lblPai.text = @"排";
        _lblPai.font = [UIFont systemFontOfSize:10];
        _lblPai.textColor = [UIColor whiteColor];
        _lblPai.textAlignment = NSTextAlignmentCenter;
        _lblPai.backgroundColor = RGBAlpha(255, 56, 56, 1);
        _lblPai.layer.cornerRadius = 2;
        _lblPai.clipsToBounds = YES;
    }
    return _lblPai;
}

-(UILabel *)lblQueueNumber{
    if (!_lblQueueNumber) {
        _lblQueueNumber = [[UILabel alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(_imgCutter.frame)+12, 0, 100, 12) title:@"0人正在排队" bgColor:[UIColor clearColor] titleColor:RGBAlpha(102, 102, 102, 1) titleFont:10];
        _lblQueueNumber.bottom = _imgCutter.bottom-2;
    }
    return _lblQueueNumber;
}

-(UILabel *)lblPrice{
    if (!_lblPrice) {
        _lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgCutter.frame)+12, _lblCutterName.bottom+10, 150, 20)];
    }
    
    return _lblPrice;
}

-(UIView *)fetureView{
    if (!_fetureView) {
        _fetureView = [[UIView alloc] initWithFrame:CGRectMake(0, _imgCutter.bottom+12, kSCREEN_WIDTH, 16)];
        
        [_fetureView addSubview:self.imgFeture];
        
        for (int i = 0; i<30; i++) {
            UILabel *lblFeture = [[UILabel alloc] initCommonWithFrame:CGRectMake(36 + i*56, 0, 48, 16) title:@"" bgColor:RGBAlpha(245, 34, 45, 0.08) titleColor:RGBMAIN titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
            
            lblFeture.tag = 100+i;
            lblFeture.hidden = YES;
            
            UILabel *lblLast = (UILabel *)[_fetureView viewWithTag:100+i-1];
            
            if (i==0) {
                lblFeture.y = 0;
                lblFeture.x = 36;
            }else{
                
                lblFeture.x = CGRectGetMaxX(lblLast.frame)+8;
                if (CGRectGetMaxX(lblFeture.frame)+16 > (kSCREEN_WIDTH-36)) {
                    lblFeture.x = 36;
                    lblFeture.y = CGRectGetMaxY(lblLast.frame)+8;
                }else{
                    lblFeture.y = lblLast.y;
                }
            }
            
            lblFeture.layer.cornerRadius = 2;
            
            [_fetureView addSubview:lblFeture];
        }
    }
    
    return _fetureView;
}

-(UIImageView *)imgFeture{
    if (!_imgFeture) {
        _imgFeture = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barber_ic_label"]];
        _imgFeture.x = 16;
        _imgFeture.y = 3;
    }
    return _imgFeture;
}

-(UILabel *)lblServiceAim{
    if (!_lblServiceAim) {
        _lblServiceAim = [[UILabel alloc] initWithFrame:CGRectMake(16, _fetureView.bottom+12, kSCREEN_WIDTH-32, 16)];
        _lblServiceAim.textColor = RGBAlpha(102, 102, 102, 1);
        _lblServiceAim.font = [UIFont systemFontOfSize:12];
    }
    return _lblServiceAim;
}

-(UIView *)shopNameView{
    if (!_shopNameView) {
        _shopNameView = [[UIView alloc] init];
        _shopNameView.width = kSCREEN_WIDTH;
        _shopNameView.height = 37;
        self.shopNameView.hidden = YES;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBAlpha(239, 239, 239, 1);
        [_shopNameView addSubview:line];
        
        [_shopNameView addSubview:self.lblShopName];
//        [_shopNameView addSubview:self.imgGo];
//        [_shopNameView addSubview:self.lblDistance];
//        [_shopNameView addSubview:self.imgDistance];
    }
    
    return _shopNameView;
}

// 分割线
//-(UIView *)viewBlock{
//    if (!_viewBlock) {
//        _viewBlock = [[UIView alloc] init];
//        _viewBlock.backgroundColor = RGBAlpha(249, 249, 249, 1);
//    }
//    return _viewBlock;
//}

-(UILabel *)lblShopName{
    if (!_lblShopName) {
        _lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 11, _shopNameView.width-32, 16) title:@"大董村工作室" bgColor:[UIColor whiteColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    
    return _lblShopName;
}

-(UIImageView *)imgGo{
    if (!_imgGo) {
        _imgGo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lblShopName.frame), 0, 16, 16)];
        _imgGo.image = [UIImage imageNamed:@"login_error_ic_phone"];
        _imgGo.centerY = _lblShopName.centerY;
    }
    
    return _imgGo;
}

-(UILabel *)lblDistance{
    if (!_lblDistance) {
        _lblDistance = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH-16-70, 0, 70, 16) title:@"13.8km" bgColor:[UIColor whiteColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:YES];
        _lblDistance.centerY = _lblShopName.centerY;
        _lblDistance.x = kSCREEN_WIDTH-16-_lblDistance.width;
    }
    
    return _lblDistance;
}

-(UIImageView *)imgDistance{
    if (!_imgDistance) {
        _imgDistance = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-_lblDistance.width-4-16, 0, 16, 16)];
        _imgDistance.image =[UIImage imageNamed:@"login_error_ic_phone"];
        _imgDistance.centerY = _lblShopName.centerY;
    }
    
    return _imgDistance;
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
