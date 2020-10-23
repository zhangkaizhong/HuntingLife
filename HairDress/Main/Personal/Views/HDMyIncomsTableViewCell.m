//
//  HDMyIncomsTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyIncomsTableViewCell.h"

@interface HDMyIncomsTableViewCell ()

@property (nonatomic,weak) UILabel *lblIncomType;//普通佣金
@property (nonatomic,weak) UILabel *lblName;//交易人
@property (nonatomic,weak) UILabel *lblJiaoyiTime;//交易时间
@property (nonatomic,weak) UILabel *lblJiesuanTime;//结算时间
@property (nonatomic,weak) UILabel *lblMoney;//金额

@end

@implementation HDMyIncomsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblIncomType = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"普通佣金" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblIncomType];
        self.lblIncomType = lblIncomType;
        
        UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblIncomType.bottom+12, kSCREEN_WIDTH-32, 12) title:@"交易人：李初九" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblName];
        self.lblName = lblName;
        
        UILabel *lblJiaoyiTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblName.bottom+8, kSCREEN_WIDTH-32-30, 12) title:@"交易时间：2019-12-15 14:26:55" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblJiaoyiTime];
        self.lblJiaoyiTime = lblJiaoyiTime;
        
        UILabel *lblJiesuanTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblJiaoyiTime.bottom+8, kSCREEN_WIDTH-32-30, 12) title:@"结算时间：2019-12-25" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblJiesuanTime];
        self.lblJiesuanTime = lblJiesuanTime;
        
        UILabel *lblMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(kSCREEN_WIDTH-32-30, 0, 46, 12) title:@"23.98" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:16 textAlignment:NSTextAlignmentRight isFit:YES];
        [self.contentView addSubview:lblMoney];
        lblMoney.centerY = 119/2;
        self.lblMoney = lblMoney;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 118, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setModel:(HDMyIncomProfitsModel *)model{
    _model = model;
    
    self.lblIncomType.text = _model.changeType;
    self.lblName.text = [NSString stringWithFormat:@"交易人：%@",_model.childNickName];
    self.lblJiaoyiTime.text = _model.showOrderTime;
    self.lblJiesuanTime.text = _model.showSettleTime;
    self.lblMoney.text = _model.changeAmount;
    [self.lblMoney sizeToFit];
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
