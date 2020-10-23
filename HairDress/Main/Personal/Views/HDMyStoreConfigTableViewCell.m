//
//  HDMyStoreConfigTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyStoreConfigTableViewCell.h"

@interface HDMyStoreConfigTableViewCell ()

@property (nonatomic,strong) UILabel *lblName;
@property (nonatomic,strong) UILabel *lblAmount;

@end

@implementation HDMyStoreConfigTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.lblName];
        [self.contentView addSubview:self.lblAmount];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 56, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
        
    }
    return self;
}

//设置配置项数据
-(void)setModel:(HDMyStoreConfigModel *)model{
    _model = model;
    
    self.lblName.text = _model.linkName;
    [self.lblName sizeToFit];
    self.lblName.height = 14;
    
    self.lblAmount.text = [NSString stringWithFormat:@"%.2f元",[_model.amount floatValue]];
}

//设置时间段数据
-(void)setTimeModel:(HDMyStoreTimeConfigModel *)timeModel{
    _timeModel = timeModel;
    self.lblName.text = _timeModel.showTimes;
    [self.lblName sizeToFit];
    self.lblName.height = 14;
    
    self.lblAmount.text = [NSString stringWithFormat:@"%@人",_timeModel.totalNum];
}

-(UILabel *)lblName{
    if (!_lblName) {
        _lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 14) title:@"洗剪吹" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblName.centerY = 57/2;
    }
    return _lblName;
}

-(UILabel *)lblAmount{
    if (!_lblAmount) {
        UIImageView *imgGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
        imgGo.x = kSCREEN_WIDTH-imgGo.width-16;
        imgGo.centerY = _lblName.centerY;
        [self.contentView addSubview:imgGo];
        
        _lblAmount = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH/2, 14) title:@"38元" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        _lblAmount.centerY = _lblName.centerY;
        _lblAmount.x = imgGo.x - _lblAmount.width;
    }
    return _lblAmount;
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
