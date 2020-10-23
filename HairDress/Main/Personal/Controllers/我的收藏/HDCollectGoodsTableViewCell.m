//
//  HDCollectGoodsTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/1.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDCollectGoodsTableViewCell.h"

@interface HDCollectGoodsTableViewCell ()

@property (nonatomic,weak) UIImageView *imageGoods;
@property (nonatomic,weak) UILabel *lblGoodsName;
@property (nonatomic,weak) UILabel *lblShopName;
@property (nonatomic,weak) UILabel *lblPrice;
@property (nonatomic,weak) UILabel *lblOldPrice;
@property (nonatomic,weak) UILabel *lblBuyNum;
@property (nonatomic,weak) UILabel *lblAccountMoney;
@property (nonatomic,weak) UILabel *lblQuan;

@property (nonatomic,weak) UILabel *lblCouponPrice;
@property (nonatomic,weak) UIImageView *imageCouponView;
@property (nonatomic,weak) UIView *lineMoney;

@end

@implementation HDCollectGoodsTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageGoods = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 96, 96)];
        imageGoods.backgroundColor = RGBBG;
        [self.contentView addSubview:imageGoods];
        self.imageGoods = imageGoods;
        
        UILabel *lblGoodsName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageGoods.frame)+12, 12, kSCREEN_WIDTH-CGRectGetMaxX(imageGoods.frame)-12-16, 20) title:@"雅诗兰黛小棕瓶抗雅诗兰黛小棕瓶抗蓝…" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblGoodsName];
        self.lblGoodsName = lblGoodsName;
        
        UIImageView *imageTag = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageGoods.frame)+12, lblGoodsName.bottom+4, 12, 12)];
        imageTag.image = [UIImage imageNamed:@"mall_ic_tmall"];
        [self.contentView addSubview:imageTag];
        
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageTag.frame)+4, lblGoodsName.bottom+4, kSCREEN_WIDTH-CGRectGetMaxX(imageTag.frame)-4-16, 12) title:@"雅诗兰黛旗舰店" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblShopName];
        self.lblShopName = lblShopName;
        
        UILabel *lblPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageGoods.frame)+9, imageTag.bottom+20, 60, 18) title:@"60" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblPrice];
        self.lblPrice = lblPrice;
        
        UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblPrice.frame)+8, imageTag.bottom+25, 14, 10) title:@"¥510" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblOldPrice];
        self.lblOldPrice = lblOldPrice;
        
        UIView *lineMoney = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 1)];
        lineMoney.backgroundColor = RGBTEXTINFO;
        lineMoney.centerY = lblOldPrice.height/2;
        [lblOldPrice addSubview:lineMoney];
        self.lineMoney = lineMoney;
        
        UILabel *lblBuyNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageGoods.frame)+12, lblPrice.bottom+11, kSCREEN_WIDTH-CGRectGetMaxX(imageGoods.frame)-12-16, 12) title:@"1138人付款" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblBuyNum];
        self.lblBuyNum = lblBuyNum;
        
        //优惠券
        UIImageView *imageCouponView = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-32, 81, 32, 14)];
        [self.contentView addSubview:imageCouponView];
        self.imageCouponView = imageCouponView;
        
        UILabel *lblQuan = [[UILabel alloc] initCommonWithFrame:CGRectMake(imageCouponView.width-18, 0, 16, 14) title:@"券" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        [imageCouponView addSubview:lblQuan];
        self.lblQuan = lblQuan;
        
        UILabel *lblCouponPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(7, 0, 80, 14) title:@"" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        [lblCouponPrice sizeToFit];
        lblCouponPrice.height = 14;
        self.lblCouponPrice = lblCouponPrice;
        [imageCouponView addSubview:lblCouponPrice];
        
        imageCouponView.width = 5+lblCouponPrice.width+20;
        imageCouponView.x = kSCREEN_WIDTH-16-imageCouponView.width;
        lblQuan.x = imageCouponView.width-16;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 120, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setModel:(HDTaoUserGoodsModel *)model{
    _model = model;
    
    [self.imageGoods sd_setImageWithURL:[NSURL URLWithString:_model.pictUrl]];
    self.lblGoodsName.text = _model.title;
    self.lblShopName.text = _model.shopTitle;
    
    self.lblPrice.text = [NSString stringWithFormat:@"¥ %.2f",[_model.quanhoujiage floatValue]];
    [self.lblPrice sizeToFit];
    self.lblPrice.height = 18;
    
    self.lblOldPrice.text = [NSString stringWithFormat:@"¥%.2f",[_model.size floatValue]];
    self.lblOldPrice.x = CGRectGetMaxX(self.lblPrice.frame)+8;
    [self.lblOldPrice sizeToFit];
    self.lblOldPrice.height = 10;
    self.lblOldPrice.centerY = self.lblPrice.centerY;
    self.lineMoney.width = self.lblOldPrice.width;
    self.lineMoney.centerY = self.lblOldPrice.height/2;
    
    self.lblBuyNum.text = [NSString stringWithFormat:@"%@人付款",_model.volume];
    
    self.lblCouponPrice.text = [NSString stringWithFormat:@"¥%.2f",[_model.couponInfoMoney floatValue]];
    [self.lblCouponPrice sizeToFit];
    self.lblCouponPrice.height = 14;
    
    self.imageCouponView.width = 7+self.lblCouponPrice.width+16;
    self.imageCouponView.x = kSCREEN_WIDTH-16-self.imageCouponView.width;
    self.lblQuan.x = self.imageCouponView.width-16;
    
    UIImage *imgCoupon = [UIImage imageNamed:@"coupon_bg"];
    CGFloat imageWidth = imgCoupon.size.width;
    CGFloat imageHeight = imgCoupon.size.height;
    CGPoint centerPoint = CGPointMake(imageWidth*0.5, imageHeight*0.5);
    UIEdgeInsets insets = UIEdgeInsetsMake(centerPoint.y, centerPoint.x, imageHeight - centerPoint.y - 1, imageWidth - centerPoint.y - 1);
    imgCoupon = [imgCoupon resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    self.imageCouponView.image = imgCoupon;
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
