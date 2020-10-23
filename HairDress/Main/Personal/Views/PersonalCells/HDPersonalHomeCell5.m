//
//  HDPersonalHomeCell5.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalHomeCell5.h"

@interface HDPersonalHomeCell5 ()

@property (nonatomic,strong) UIImageView *imageMenu;
@property (nonatomic,strong) UILabel * lblTitle;  // 菜单名

@end

@implementation HDPersonalHomeCell5

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-24-16, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        imageGo.centerY = 24;
        [self.contentView addSubview:imageGo];
        
        [self.contentView addSubview:self.imageMenu];
        [self.contentView addSubview:self.lblTitle];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 47, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBCOLOR(245, 245, 245);
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    _lblTitle.text = dic[@"title"];
    _imageMenu.image = [UIImage imageNamed:dic[@"image"]];
}

#pragma mark ================== 加载控件 =====================

-(UIImageView *)imageMenu{
    if (!_imageMenu) {
        _imageMenu = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 24, 24)];
        _imageMenu.centerY = 24;
    }
    return _imageMenu;
}

-(UILabel *)lblTitle{
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imageMenu.frame)+8, 0, 150, 14) title:@"我的任务" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblTitle.centerY = 24;
    }
    return _lblTitle;
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
