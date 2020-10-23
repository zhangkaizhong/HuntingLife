//
//  HDTaoMallFloorDetailTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoMallFloorDetailTableViewCell.h"

@interface HDTaoMallFloorDetailTableViewCell ()

@property (nonatomic,weak) UIImageView *imageGood;
@property (nonatomic,weak) UIImageView *imageShopItem;
@property (nonatomic,weak) UIImageView *imageCouponView;
@property (nonatomic,weak) UILabel *lblTitle;
@property (nonatomic,weak) UILabel *lblShopName;
@property (nonatomic,weak) UILabel *lblCurrentPrice;
@property (nonatomic,weak) UILabel *lblOldPrice;
@property (nonatomic,weak) UILabel *lblVolume;
@property (nonatomic,weak) UILabel *lblQuan;
@property (nonatomic,weak) UILabel *lblCouponPrice;

@property (nonatomic,weak) UIView *linePrice;

@end

@implementation HDTaoMallFloorDetailTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //商品图
        UIImageView *imageGood = [[UIImageView alloc] initWithFrame:CGRectMake(16, 24, 96, 96)];
        [self.contentView addSubview:imageGood];
        self.imageGood = imageGood;
        
        //商品标题
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+12, imageGood.y, kSCREEN_WIDTH-CGRectGetMaxX(imageGood.frame)-24, 20)];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"雅诗兰黛小棕瓶抗蓝光精华露补水…" attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: RGBTEXT}];
        lblTitle.attributedText = string;
        self.lblTitle = lblTitle;
        [self.contentView addSubview:lblTitle];
        
        //店铺图标
        UIImageView *imageShopItem = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+12, lblTitle.bottom+4, 12, 12)];
        self.imageShopItem = imageShopItem;
        [self.contentView addSubview:imageShopItem];
        
        //店铺名称
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageShopItem.frame)+4, 0, kSCREEN_WIDTH-CGRectGetMaxX(imageShopItem.frame)-4-12, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblShopName.centerY = imageShopItem.centerY;
        self.lblShopName = lblShopName;
        [self.contentView addSubview:lblShopName];
        
        //现价
        UILabel *lblCurrentPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+9, imageShopItem.bottom+20, 100, 18)];
        lblCurrentPrice.attributedText = [[NSString alloc] setAttrText:@"¥89.09"  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
        [lblCurrentPrice sizeToFit];
        self.lblCurrentPrice = lblCurrentPrice;
        [self.contentView addSubview:lblCurrentPrice];
        
        //原价
        UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblCurrentPrice.frame)+8, 0, 100, 10) title:@"99.99" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblOldPrice sizeToFit];
        lblOldPrice.bottom = lblCurrentPrice.bottom-3;
        self.lblOldPrice = lblOldPrice;
        [self.contentView addSubview:lblOldPrice];
        
        UIView *linePrice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 0.5)];
        linePrice.centerY = lblOldPrice.height/2;
        linePrice.backgroundColor = RGBTEXTINFO;
        self.linePrice = linePrice;
        [lblOldPrice addSubview:linePrice];
        
        //销量
        UILabel *lblVolume = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+10, lblCurrentPrice.bottom+1, 100, 12) title:[NSString stringWithFormat:@"%@人付款",@"3878"] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblVolume sizeToFit];
        lblVolume.bottom = imageGood.bottom;
        self.lblVolume = lblVolume;
        [self.contentView addSubview:lblVolume];
        
        //优惠券
        UIImageView *imageCouponView = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-20-32, 134-26-14, 32, 14)];
        self.imageCouponView = imageCouponView;
        [self.contentView addSubview:imageCouponView];
        
        UILabel *lblQuan = [[UILabel alloc] initCommonWithFrame:CGRectMake(imageCouponView.width-18, 0, 16, 14) title:@"券" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        self.lblQuan = lblQuan;
        [imageCouponView addSubview:lblQuan];
        
        UILabel *lblCouponPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(7, 0, 80, 14) title:@"¥7" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        self.lblCouponPrice = lblCouponPrice;
        [lblCouponPrice sizeToFit];
        lblCouponPrice.height = 14;
        [imageCouponView addSubview:lblCouponPrice];
        imageCouponView.width = 5+lblCouponPrice.width+5+20;
        imageCouponView.x = kSCREEN_WIDTH-20-imageCouponView.width;
        lblQuan.x = imageCouponView.width-16;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 133, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBCOLOR(245, 245, 245);
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setModel:(HDTaoGoodsModel *)model{
    _model = model;
    
    [self.imageGood sd_setImageWithURL:[NSURL URLWithString:_model.pictUrl]];
    self.lblTitle.text = _model.title;
    [self.imageShopItem sd_setImageWithURL:[NSURL URLWithString:_model.itemUrl] placeholderImage:[UIImage imageNamed:@"mall_ic_tmall"]];
    self.lblShopName.text = _model.shopTitle;
    //现价
    self.lblCurrentPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥ %.2f",[_model.quanhoujiage floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
    [self.lblCurrentPrice sizeToFit];
    //原价
    self.lblOldPrice.text = model.size;
    [self.lblOldPrice sizeToFit];
    self.lblOldPrice.bottom = self.lblCurrentPrice.bottom-3;
    self.linePrice.width = self.lblOldPrice.width;
    self.linePrice.centerY = self.lblOldPrice.height/2;
    //销量
    self.lblVolume.text = [NSString stringWithFormat:@"%@人付款",_model.volume];
    [self.lblVolume sizeToFit];
    self.lblVolume.bottom = self.imageGood.bottom;
    //优惠券
    self.lblCouponPrice.text = [NSString stringWithFormat:@"¥%@",_model.couponInfoMoney];
    [self.lblCouponPrice sizeToFit];
    self.lblCouponPrice.height = 14;
    self.imageCouponView.width = 7+self.lblCouponPrice.width+16;
    self.imageCouponView.x = kSCREEN_WIDTH-20-self.imageCouponView.width;
    self.lblQuan.x = self.imageCouponView.width-16;

    //调整优惠券图片的大小
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
