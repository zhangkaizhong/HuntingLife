//
//  HDSettingTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/1.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDSettingTableViewCell.h"

@interface HDSettingTableViewCell ()

@property (nonatomic,strong) UILabel *lblTitle;

@property (nonatomic,weak) UILabel *lblCache;

@end

@implementation HDSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.lblTitle];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.centerY = 55/2;
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [self.contentView addSubview:imageGo];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
        
        UILabel *lblCache = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 100, 16) title:@"" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:YES];
        self.lblCache = lblCache;
        [self.contentView addSubview:lblCache];
    }
    return self;
}

-(UILabel *)lblTitle{
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32-24, 14) title:@"账号与安全" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblTitle;
}

// 赋值
-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    
    _lblTitle.text = cellTitle;
}

-(void)setCacheSize:(NSString *)cacheSize{
    _cacheSize = cacheSize;
    
    self.lblCache.text = cacheSize;
    [self.lblCache sizeToFit];
    self.lblCache.x = kSCREEN_WIDTH-24-16-self.lblCache.width;
    self.lblCache.centerY = 55/2;
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
