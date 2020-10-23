//
//  HDMyTeamsTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyTeamsTableViewCell.h"

@interface HDMyTeamsTableViewCell ()

@property (nonatomic,weak) UIImageView *imageHeader;
@property (nonatomic,weak) UILabel *lblName;
@property (nonatomic,weak) UILabel *lblInvCount;

@end

@implementation HDMyTeamsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageHeader = [[UIImageView alloc] initWithFrame:CGRectMake(16, 8, 36, 36)];
        imageHeader.layer.cornerRadius = 18;
        imageHeader.layer.masksToBounds = YES;
        [self.contentView addSubview: imageHeader];
        self.imageHeader = imageHeader;
        
        UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageHeader.frame)+8, 0, 180, 14) title:@"歌神张学友" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblName];
        lblName.centerY = imageHeader.centerY;
        self.lblName = lblName;
        
        UILabel *lblInvCount = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH-16-150, 0, 150, 12) title:@"邀请1230人" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        lblInvCount.centerY = lblName.centerY;
        self.lblInvCount = lblInvCount;
        [self.contentView addSubview:lblInvCount];
        
//        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
//        imageGo.centerY = lblName.centerY;
//        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
//        [self.contentView addSubview:imageGo];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 52, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
    }
    
    return self;
}

-(void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    dic = [HDToolHelper nullDicToDic:dic];
    [self.imageHeader sd_setImageWithURL:[NSURL URLWithString:dic[@"headImg"]]];
    self.lblName.text = dic[@"userName"];
    self.lblInvCount.text = [NSString stringWithFormat:@"邀请%ld人",(long)[dic[@"teamNum"] integerValue]];
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
