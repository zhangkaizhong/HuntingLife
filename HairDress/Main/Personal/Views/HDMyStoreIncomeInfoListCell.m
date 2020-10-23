//
//  HDMyStoreIncomeInfoListCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyStoreIncomeInfoListCell.h"

@interface HDMyStoreIncomeInfoListCell ()

@property (nonatomic,weak) UILabel *lblTitle;
@property (nonatomic,weak) UILabel *lblCutterText;
@property (nonatomic,weak) UILabel *lblCreateText;
@property (nonatomic,weak) UILabel *lblSettleText;
@property (nonatomic,weak) UILabel *lblWithMoney;

@end

@implementation HDMyStoreIncomeInfoListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"施华蔻精品烫染" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblTitle = lblTitle;
        [self.contentView addSubview:lblTitle];
        
        UILabel *lblCutterText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblTitle.bottom+12, 100, 12) title:@"发型师：Tony" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblCutterText = lblCutterText;
        [self.contentView addSubview:lblCutterText];
        
        UILabel *lblCreateText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblCutterText.bottom+8, 100, 12) title:@"创建时间：2020-03-10 15:55:26" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblCreateText = lblCreateText;
        [self.contentView addSubview:lblCreateText];
        
        UILabel *lblSettleText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblCreateText.bottom+8, 100, 12) title:@"结算时间：2020-03-10 15:55:26" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblSettleText = lblSettleText;
        [self.contentView addSubview:lblSettleText];
        
        UILabel *lblWithMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH/2, 16) title:@"98.00" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:16 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblWithMoney = lblWithMoney;
        [self.contentView addSubview:lblWithMoney];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 119, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setModel:(HDMyStoreIncomeInfoListModel *)model{
    _model = model;
    
    self.lblTitle.text = _model.serviceName;
    self.lblCutterText.text = [NSString stringWithFormat:@"发型师：%@",_model.tonyName];
    [self.lblCutterText sizeToFit];
    self.lblCutterText.height = 12;
    self.lblCreateText.text = [NSString stringWithFormat:@"创建时间：%@",_model.createTime];
    [self.lblCreateText sizeToFit];
    self.lblCreateText.height = 12;
    self.lblSettleText.text = [NSString stringWithFormat:@"结算时间：%@",_model.settleTime];
    [self.lblSettleText sizeToFit];
    self.lblSettleText.height = 12;
    
    self.lblWithMoney.text = [NSString stringWithFormat:@"%.2f",[_model.amount floatValue]];
    [self.lblWithMoney sizeToFit];
    self.lblWithMoney.x = kSCREEN_WIDTH - self.lblWithMoney.width-16;
    self.lblWithMoney.centerY = 120/2;
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
