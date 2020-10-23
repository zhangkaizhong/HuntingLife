//
//  HDCutterExperienceTableViewCell.m
//  HairDress
//
//  Created by Apple on 2019/12/24.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCutterExperienceTableViewCell.h"

@interface HDCutterExperienceTableViewCell ()

@property (nonatomic,strong) UIView * viewLineUp;  // 上半部分线
@property (nonatomic,strong) UIView * viewLineDown;  // 下半部分线
@property (nonatomic,strong) UIView * viewBlock;  // 中间分割点
@property (nonatomic,strong) UILabel * lblShopName;  // 店名
@property (nonatomic,strong) UILabel * lblTiem;  // 时间

@end

@implementation HDCutterExperienceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupUI];
    }
    return self;
}

-(void)setModel:(HDCutterResumeExpModel *)model{
    _model = model;
    
    self.lblShopName.text = _model.storeName;
    self.lblTiem.text = [NSString stringWithFormat:@"在职时间:%@-%@",_model.startTime,_model.endTime];
}

-(void)setupUI{
    
    self.viewLineUp = [[UIView alloc] initWithFrame:CGRectMake(19, 0, 1, 32)];
    self.viewLineUp.backgroundColor = RGBAlpha(216, 216, 216, 1);
    [self.contentView addSubview:self.viewLineUp];
    
    self.viewBlock = [[UIView alloc] initWithFrame:CGRectMake(0, self.viewLineUp.bottom+2, 6, 6)];
    self.viewBlock.backgroundColor = RGBAlpha(216, 216, 216, 1);
    self.viewBlock.centerX = self.viewLineUp.centerX;
    [self.contentView addSubview:self.viewBlock];
    
    self.viewLineDown = [[UIView alloc] initWithFrame:CGRectMake(19, self.viewBlock.bottom+2, 1, 38)];
    self.viewLineDown.backgroundColor = RGBAlpha(216, 216, 216, 1);
    [self.contentView addSubview:self.viewLineDown];
    
    self.lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(self.viewBlock.frame)+8, 0, kSCREEN_WIDTH-CGRectGetMaxX(self.viewBlock.frame)-8-16, 14) title:@"泊泽漫时光" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    self.lblShopName.centerY = self.viewBlock.centerY;
    [self.contentView addSubview:self.lblShopName];
    
    self.lblTiem = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(self.viewBlock.frame)+8, CGRectGetMaxY(self.lblShopName.frame)+12, kSCREEN_WIDTH-CGRectGetMaxX(self.viewBlock.frame)-8-16, 14) title:@"在职时间：2015.03-2018.03" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [self.contentView addSubview:self.lblTiem];
    
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
