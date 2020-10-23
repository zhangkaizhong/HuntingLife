//
//  HDTaoIconCollectionCell.m
//  HairDress
//
//  Created by Apple on 2020/1/17.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoIconCollectionCell.h"

@interface HDTaoIconCollectionCell ()

@property (nonatomic,weak) UIImageView *imageV;
@property (nonatomic,weak) UILabel *lblTitle;

@end

@implementation HDTaoIconCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12*SCALE, 40*SCALE, 40*SCALE)];
        imageV.centerX = self.contentView.width/2;
        [self.contentView addSubview:imageV];
        self.imageV = imageV;
        
        UILabel *lblIcon = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageV.bottom+10*SCALE, self.contentView.width, 12*SCALE) title:@"" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        [self.contentView addSubview:lblIcon];
        self.lblTitle = lblIcon;
    }
    return self;
}


-(void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:_dic[@"barSortLogo"]]];
    self.lblTitle.text = _dic[@"title"];
}

@end
