//
//  HDMyWithdrawRecordsTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyWithdrawRecordsTableViewCell.h"

@interface HDMyWithdrawRecordsTableViewCell ()

@property (nonatomic,weak) UILabel *lblWithStatus;//提现状态
@property (nonatomic,weak) UILabel *lblBalance;//余额
@property (nonatomic,weak) UILabel *lblTime;
@property (nonatomic,weak) UILabel *lblWithMoney;//提现金额
@property (nonatomic,weak) UILabel *lblMinMoney;//手续费
@property (nonatomic,weak) UILabel *lblOrderId;//提现单号

@end

@implementation HDMyWithdrawRecordsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblWithStatus = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 17, kSCREEN_WIDTH/2, 14) title:@"提现-申请中" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblWithStatus = lblWithStatus;
        [self.contentView addSubview:self.lblWithStatus];
        
        UILabel *lblOrderIdText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblWithStatus.bottom+12, kSCREEN_WIDTH/2, 12) title:@"提现单号:" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:YES];
        [self.contentView addSubview:lblOrderIdText];
        
        UILabel *lblOrderId = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblOrderIdText.frame)+5, lblOrderIdText.y, kSCREEN_WIDTH-CGRectGetMaxX(lblOrderIdText.frame)-5-16, 12) title:@"9088988989786756554" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [self.contentView addSubview:lblOrderId];
        self.lblOrderId = lblOrderId;
        
        UILabel *lblMinMoneyText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblOrderIdText.bottom+8, lblOrderIdText.width, 12) title:@"手续费:" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblMinMoneyText textAlignmentLeftAndRightWith:lblOrderIdText.width];
        [self.contentView addSubview:lblMinMoneyText];
        
        UILabel *lblMinMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblMinMoneyText.frame)+5, lblMinMoneyText.y, kSCREEN_WIDTH/2, 12) title:@"10.00" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblMinMoney = lblMinMoney;
        [self.contentView addSubview:lblMinMoney];
        
        UILabel *lblBalanceText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblMinMoneyText.bottom+8, lblOrderIdText.width, 12) title:@"余额:" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblBalanceText textAlignmentLeftAndRightWith:lblOrderIdText.width];
        [self.contentView addSubview:lblBalanceText];
        
        UILabel *lblBalance = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblBalanceText.frame)+5, lblBalanceText.y, kSCREEN_WIDTH/2, 12) title:@"100.98" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblBalance = lblBalance;
        [self.contentView addSubview:lblBalance];
        
        UILabel *lblTimeText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblBalanceText.bottom+8, lblOrderIdText.width, 12) title:@"创建时间:" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblTimeText textAlignmentLeftAndRightWith:lblOrderIdText.width];
        [self.contentView addSubview:lblTimeText];
        
        UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblTimeText.frame)+5, lblBalanceText.bottom+8, kSCREEN_WIDTH-CGRectGetMaxX(lblTimeText.frame)-5-16, 12) title:@"2019-09-09 08:09:09" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblTime.height = 12;
        self.lblTime = lblTime;
        [self.contentView addSubview:lblTime];
        
        UILabel *lblWithMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH/2, 16) title:@"98.00" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:16 textAlignment:NSTextAlignmentRight isFit:YES];
        lblWithMoney.x = kSCREEN_WIDTH - lblWithMoney.width-16;
        lblWithMoney.centerY = 132/2;
        self.lblWithMoney = lblWithMoney;
        [self.contentView addSubview:lblWithMoney];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 131, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setModel:(HDWithdrewRecordModel *)model{
    _model = model;
    
    self.lblWithStatus.text = [NSString stringWithFormat:@"提现-%@",_model.typeName];
    self.lblOrderId.text = _model.record_id;
    self.lblWithMoney.text = [NSString stringWithFormat:@"%.2f",[_model.applyBalance floatValue]];
    self.lblTime.text = _model.createTime;
    self.lblBalance.text = [NSString stringWithFormat:@"%.2f",[_model.balance floatValue]-[_model.applyBalance floatValue]-[_model.serviceBalance floatValue]];
    self.lblMinMoney.text = [NSString stringWithFormat:@"%.2f",[_model.serviceBalance floatValue]];
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
