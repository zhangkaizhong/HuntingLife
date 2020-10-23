//
//  HDMyTinyShowsCollectionCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyTinyShowsCollectionCell.h"

@interface HDMyTinyShowsCollectionCell ()

@property (nonatomic,weak) UIImageView *imageCover;
@property (nonatomic,weak) UILabel *lblShows;
@property (nonatomic,weak) UIButton *btnDel;

@end

@implementation HDMyTinyShowsCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, (kSCREEN_WIDTH-32-15)/2, 204)];
        [self.contentView addSubview:backView];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (kSCREEN_WIDTH-32-15)/2, 164)];
        [backView addSubview:image];
        image.contentMode = 2;
        self.imageCover = image;
        
        CGFloat corner = 8;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:image.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(corner, corner)].CGPath;
        image.layer.mask = shapeLayer;
        
        backView.layer.cornerRadius = 8;
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        backView.layer.shadowOffset = CGSizeMake(0,1);
        backView.layer.shadowOpacity = 1;
        backView.layer.shadowRadius = 1.5;
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(8, CGRectGetMaxY(image.frame)+12, (kSCREEN_WIDTH-32-15)/2-8-8, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [backView addSubview:lblText];
        self.lblShows = lblText;
        
        UIButton *btnDel = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, 0, 16, 16) btnTitle:@"" btnImage:@"chahao" titleColor:[UIColor clearColor] titleFont:0];
        [btnDel addTarget:self action:@selector(deleteShowAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnDel];
    }
    return self;
}

-(void)setModel:(HDCutterWorkShowsModel *)model{
    _model = model;
    
    [self.imageCover sd_setImageWithURL:[NSURL URLWithString:_model.imgUrl]];
    self.lblShows.text = _model.worksName;
}

-(void)deleteShowAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickDeleteShows:)]) {
        [self.delegate clickDeleteShows:_model];
    }
}

@end
