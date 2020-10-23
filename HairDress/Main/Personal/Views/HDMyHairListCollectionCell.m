//
//  HDMyHairListCollectionCell.m
//  HairDress
//
//  Created by Apple on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyHairListCollectionCell.h"

@interface HDMyHairListCollectionCell ()

@property (nonatomic,strong) UIImageView *imageCover;// 封面
@property (nonatomic,strong) UILabel * lblShopName;  // 门店名称
@property (nonatomic,strong) UILabel * lblCutterName;  // 发型师名称
@property (nonatomic,strong) UILabel * lblCreateTime;  // 创建时间

@end

@implementation HDMyHairListCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        
        self.contentView.layer.cornerRadius = 8;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        self.contentView.layer.shadowOffset = CGSizeMake(0,1);
        self.contentView.layer.shadowOpacity = 1;
        self.contentView.layer.shadowRadius = 1.5;
        
        
        [self.contentView addSubview:self.imageCover];
        [self.contentView addSubview:self.lblShopName];
        [self.contentView addSubview:self.lblCutterName];
        [self.contentView addSubview:self.lblCreateTime];
    }
    return self;
}

#pragma mark ================== 加载控件 =====================

-(UIImageView *)imageCover{
    if (!_imageCover) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (kSCREEN_WIDTH-32-15)/2, 158)];
        
        CGFloat corner = 8;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:image.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(corner, corner)].CGPath;
        image.layer.mask = shapeLayer;
        
        _imageCover = image;
    }
    return _imageCover;
}

-(UILabel *)lblShopName{
    if (!_lblShopName) {
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(8, CGRectGetMaxY(_imageCover.frame)+11, (kSCREEN_WIDTH-32-15)/2-8-8, 12) title:@"大东城发型工作室" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblShopName = lblText;
    }
    return _lblShopName;
}

-(UILabel *)lblCutterName{
    if (!_lblCutterName) {
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(8, CGRectGetMaxY(_lblShopName.frame)+11, (kSCREEN_WIDTH-32-15)/2-8-8, 12) title:@"发型师：Tony" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblCutterName = lblText;
    }
    return _lblCutterName;
}

-(UILabel *)lblCreateTime{
    if (!_lblCreateTime) {
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(8, CGRectGetMaxY(_lblCutterName.frame)+11, (kSCREEN_WIDTH-32-15)/2-8-8, 12) title:@"发型师：Tony" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblCreateTime = lblText;
    }
    return _lblCreateTime;
}

@end
