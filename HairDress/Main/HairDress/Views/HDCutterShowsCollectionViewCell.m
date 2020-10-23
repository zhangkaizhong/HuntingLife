//
//  HDCutterShowsCollectionViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/13.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDCutterShowsCollectionViewCell.h"

@interface HDCutterShowsCollectionViewCell ()

@property (nonatomic,weak) UILabel *lblText;

@end

@implementation HDCutterShowsCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (kSCREEN_WIDTH-32-15)/2, 164)];
        [self.contentView addSubview:image];
        image.contentMode = 2;
        self.imageShow = image;
        CGFloat corner = 8;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:image.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(corner, corner)].CGPath;
        image.layer.mask = shapeLayer;
        
        self.contentView.layer.cornerRadius = 8;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        self.contentView.layer.shadowOffset = CGSizeMake(0,1);
        self.contentView.layer.shadowOpacity = 1;
        self.contentView.layer.shadowRadius = 1.5;
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(8, CGRectGetMaxY(image.frame)+12, (kSCREEN_WIDTH-32-15)/2-8-8, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblText];
        self.lblText = lblText;
    }
    return self;
}

-(void)setModel:(HDCutterWorkShowsModel *)model{
    _model = model;
    
    [_imageShow sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
//    _lblText.width = (kSCREEN_WIDTH-32-15)/2-8-8;
    _lblText.text = model.worksName;
//    _lblText.numberOfLines = 0;
//    [_lblText sizeToFit];
}

-(void)layoutSubviews{
    [super layoutSubviews];

    self.imageShow.frame = self.model.imageFrame;
    self.lblText.frame = self.model.labelFrame;
}

@end
