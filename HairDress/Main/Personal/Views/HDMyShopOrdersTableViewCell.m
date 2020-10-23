//
//  HDMyShopOrdersTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyShopOrdersTableViewCell.h"

@interface HDMyShopOrdersTableViewCell ()

@property (nonatomic,strong) UILabel *lblOrderNo;//订单号
@property (nonatomic,strong) UIImageView *imageGoods;//商品图片
@property (nonatomic,strong) UIImageView *imageTag;//商品图片
@property (nonatomic,strong) UILabel *lblBuyTime;//下单时间
@property (nonatomic,strong) UILabel *lblPricePay;//付款价格
@property (nonatomic,strong) UILabel *lblPayBackMoney;//返还价格
@property (nonatomic,strong) UILabel *lblAccountTime;//到账时间

@end

@implementation HDMyShopOrdersTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8)];
        line1.backgroundColor = RGBBG;
        [self.contentView addSubview:line1];
        
        [self.contentView addSubview:self.lblOrderNo];
        
        // 订单图标
        UIImageView *imageTag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mall_ic_tmall"]];
        imageTag.x = kSCREEN_WIDTH-imageTag.width-16;
        imageTag.centerY = self.lblOrderNo.centerY;
        self.imageTag = imageTag;
        [self.contentView addSubview:imageTag];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(16,self.lblOrderNo.bottom+16, kSCREEN_WIDTH-32, 1)];
        line2.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line2];
        
        [self.contentView addSubview:self.imageGoods];
        [self.contentView addSubview:self.lblBuyTime];
        [self.contentView addSubview:self.lblPricePay];
        [self.contentView addSubview:self.lblPayBackMoney];
        [self.contentView addSubview:self.lblAccountTime];
        
    }
    return self;
}

//赋值
-(void)setModel:(HDUserGoodsOrderListModel *)model{
    _model = model;
    _lblOrderNo.text = [NSString stringWithFormat:@"订单号：%@",_model.tradeId];
    _lblBuyTime.text = _model.showPayTime;
    _lblPricePay.text = [NSString stringWithFormat:@"付款%.2f元",[_model.alipayTotalPrice floatValue]];
    if ([_model.orderType isEqualToString:@"天猫"]) {
        self.imageTag.image = [UIImage imageNamed:@"tmall_small_icon"];
    }else{
        self.imageTag.image = [UIImage imageNamed:@"logo_taobao"];
    }
    [_imageGoods sd_setImageWithURL:[NSURL URLWithString:_model.itemImg]];
    _lblAccountTime.text = _model.showSettlementStatus;
    _lblPayBackMoney.text = [NSString stringWithFormat:@"返还%.2f元",[_model.pubSharePreFee floatValue]];
    [_lblPayBackMoney sizeToFit];
    [_lblAccountTime sizeToFit];
    _lblAccountTime.x = CGRectGetMaxX(_lblPayBackMoney.frame)+10;
    _lblAccountTime.width = kSCREEN_WIDTH-CGRectGetMaxX(_lblPayBackMoney.frame)-10-16;
}

#pragma mark -- 加载控件

-(UILabel *)lblOrderNo{
    if (!_lblOrderNo) {
        _lblOrderNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 24, kSCREEN_WIDTH-32-10, 12) title:@"订单号：123456789098765432" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblOrderNo;
}

-(UIImageView *)imageGoods{
    if (!_imageGoods) {
        _imageGoods = [[UIImageView alloc] initWithFrame:CGRectMake(16, _lblOrderNo.bottom+33, 72, 72)];
        _imageGoods.backgroundColor = RGBBG;
    }
    return _imageGoods;
}

-(UILabel *)lblBuyTime{
    if (!_lblBuyTime) {
        _lblBuyTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageGoods.frame)+8, _lblOrderNo.bottom+33, kSCREEN_WIDTH-CGRectGetMaxX(_imageGoods.frame)-8-16, 12) title:@"下单时间：2019-12-15 16:42:23" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblBuyTime;
}

-(UILabel *)lblPricePay{
    if (!_lblPricePay) {
        _lblPricePay = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageGoods.frame)+8, _lblBuyTime.bottom+14, kSCREEN_WIDTH-CGRectGetMaxX(_imageGoods.frame)-8-16, 12) title:@"付款108元" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblPricePay;
}

-(UILabel *)lblPayBackMoney{
    if (!_lblPayBackMoney) {
        _lblPayBackMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageGoods.frame)+8, _lblPricePay.bottom+20, 150, 14) title:@"返还1.64元" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    }
    return _lblPayBackMoney;
}

-(UILabel *)lblAccountTime{
    if (!_lblAccountTime) {
        _lblAccountTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, _lblPayBackMoney.y+2, 100, 12) title:@"2019-12-25到账" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
    }
    return _lblAccountTime;
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
