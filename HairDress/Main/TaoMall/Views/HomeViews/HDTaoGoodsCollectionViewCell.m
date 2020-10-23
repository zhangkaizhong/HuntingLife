//
//  HDTaoGoodsCollectionViewCell.m
//  HairDress
//
//  Created by Apple on 2020/1/13.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoGoodsCollectionViewCell.h"

@interface HDTaoGoodsCollectionViewCell ()

@property (nonatomic,weak) UILabel *lblGoodsName;
@property (nonatomic,weak) UILabel *lblShopName;
@property (nonatomic,weak) UILabel *lblCurrentPrice;
@property (nonatomic,weak) UILabel *lblOldPrice;
@property (nonatomic,weak) UIView *linePrice;
@property (nonatomic,weak) UILabel *lblVolume;
@property (nonatomic,weak) UILabel *lblQuan;
@property (nonatomic,weak) UILabel *lblCouponPrice;

@property (nonatomic,weak) UIImageView *imageV;
@property (nonatomic,weak) UIImage *imageCoupon;
@property (nonatomic,weak) UIImageView *imageShopItem;
@property (nonatomic,weak) UIImageView *imageCouponView;

@end

@implementation HDTaoGoodsCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = RGBCOLOR(245, 245, 245).CGColor;
        self.contentView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.cornerRadius = 4;
        self.contentView.layer.shadowColor = RGBAlpha(0, 0, 0, 0.06).CGColor;
        self.contentView.layer.shadowOffset = CGSizeMake(0,3);
        self.contentView.layer.shadowOpacity = 1;
        self.contentView.layer.shadowRadius = 3;
        
        CGFloat view_width = (kSCREEN_WIDTH-32)/2;
        
        // 商品图片
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,view_width, view_width)];
        [self.contentView addSubview:imageV];
        self.imageV = imageV;
        
        //商品名称
        UILabel *lblGoodsName = [[UILabel alloc] initCommonWithFrame:CGRectMake(7, imageV.bottom+8, imageV.width-17, 20) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblGoodsName];
        self.lblGoodsName = lblGoodsName;
        
        //店铺图标
        UIImageView *imageShopItem = [[UIImageView alloc] initWithFrame:CGRectMake(lblGoodsName.x, lblGoodsName.bottom+4, 12, 12)];
        [imageShopItem sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"mall_ic_tmall"]];
        [self.contentView addSubview:imageShopItem];
        self.imageShopItem = imageShopItem;
        
        //店铺名称
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageShopItem.frame)+4, 0, view_width-CGRectGetMaxX(imageShopItem.frame)-4-12, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblShopName.centerY = imageShopItem.centerY;
        [self.contentView addSubview:lblShopName];
        self.lblShopName = lblShopName;
        
        //现价
        UILabel *lblCurrentPrice = [[UILabel alloc] initWithFrame:CGRectMake(lblGoodsName.x, lblShopName.bottom+12, 100, 18)];
//        lblCurrentPrice.numberOfLines = 0;
        [self.contentView addSubview:lblCurrentPrice];
        self.lblCurrentPrice = lblCurrentPrice;
        
        //原价
        UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblCurrentPrice.frame)+8, 0, 100, 10) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblOldPrice sizeToFit];
        lblOldPrice.bottom = lblCurrentPrice.bottom-3;
        [self.contentView addSubview:lblOldPrice];
        self.lblOldPrice = lblOldPrice;
        
        UIView *linePrice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 0.5)];
        linePrice.centerY = lblOldPrice.height/2;
        linePrice.backgroundColor = RGBTEXTINFO;
        [lblOldPrice addSubview:linePrice];
        self.linePrice = linePrice;
        
        //销量
        UILabel *lblVolume = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblGoodsName.x, lblCurrentPrice.bottom+10, 100, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblVolume sizeToFit];
        [self.contentView addSubview:lblVolume];
        self.lblVolume = lblVolume;
        
        //优惠券
        UIImageView *imageCouponView = [[UIImageView alloc] initWithFrame:CGRectMake(view_width-8-32, lblShopName.bottom+14, 32, 14)];
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
        imageCouponView.x = view_width-8-imageCouponView.width;
        lblQuan.x = imageCouponView.width-16;
    }
    return self;
}

-(void)setModel:(HDTaoGoodsModel *)model{
    _model = model;
    
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:_model.pictUrl]];
    self.lblGoodsName.text = _model.title;
    [self.imageShopItem sd_setImageWithURL:[NSURL URLWithString:_model.itemUrl] placeholderImage:[UIImage imageNamed:@"mall_ic_tmall"]];
    self.lblShopName.text = _model.nick;
    
    self.lblCurrentPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[_model.quanhoujiage floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
    [self.lblCurrentPrice sizeToFit];
    
    self.lblOldPrice.x = CGRectGetMaxX(self.lblCurrentPrice.frame)+8;
    
    self.lblOldPrice.text = _model.size;
    [self.lblOldPrice sizeToFit];
    self.lblOldPrice.bottom = self.lblCurrentPrice.bottom-3;
    
    self.linePrice.width = self.lblOldPrice.width;
    self.linePrice.centerY = self.lblOldPrice.height/2;
    
    self.lblVolume.text = [NSString stringWithFormat:@"%@人付款",_model.volume];
    [self.lblVolume sizeToFit];
    
    self.lblCouponPrice.text = [NSString stringWithFormat:@"¥%@",_model.couponInfoMoney];
    [self.lblCouponPrice sizeToFit];
    self.lblCouponPrice.height = 14;
    
    self.imageCouponView.width = 7+self.lblCouponPrice.width+16;
    self.imageCouponView.x = (kSCREEN_WIDTH-32)/2-8-self.imageCouponView.width;
    self.lblQuan.x = self.imageCouponView.width-16;
    
    UIImage *imgCoupon = [UIImage imageNamed:@"coupon_bg"];
    CGFloat imageWidth = imgCoupon.size.width;
    CGFloat imageHeight = imgCoupon.size.height;
    CGPoint centerPoint = CGPointMake(imageWidth*0.5, imageHeight*0.5);
    UIEdgeInsets insets = UIEdgeInsetsMake(centerPoint.y, centerPoint.x, imageHeight - centerPoint.y - 1, imageWidth - centerPoint.y - 1);
    imgCoupon = [imgCoupon resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    self.imageCouponView.image = imgCoupon;
    
    if ([_model.couponInfoMoney floatValue] == 0) {
        self.imageCouponView.hidden = YES;
    }
}

@end
