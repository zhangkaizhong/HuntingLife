//
//  HDMyBankCardsTableViewCell.m
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyBankCardsTableViewCell.h"

@interface HDMyBankCardsTableViewCell ()

@property (nonatomic,weak) UIImageView *imageBank;
@property (nonatomic,weak) UILabel *lblBankName;
@property (nonatomic,weak) UILabel *lblCardType;
@property (nonatomic,weak) UILabel *lblCardNo;

@end

@implementation HDMyBankCardsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8)];
        line1.backgroundColor = RGBBG;
        [self.contentView addSubview:line1];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, 100)];
        viewBack.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:viewBack];
        
        UIImageView *imageBank = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 56, 56)];
        imageBank.image = [UIImage imageNamed:@"bank_logo_boc"];
        [viewBack addSubview:imageBank];
        self.imageBank = imageBank;
        
        UILabel *lblBankName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageBank.frame)+8, 10, kSCREEN_WIDTH-CGRectGetMaxX(imageBank.frame)-8-16, 14) title:@"中国银行" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblBankName = lblBankName;
        [viewBack addSubview:self.lblBankName];
        
        UILabel *lblCardType = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageBank.frame)+8, lblBankName.bottom+8, kSCREEN_WIDTH-CGRectGetMaxX(imageBank.frame)-8-16, 14) title:@"储蓄卡" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblCardType = lblCardType;
        [viewBack addSubview:self.lblCardType];
        
        UILabel *lblCardNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageBank.frame)+8, lblCardType.bottom+12, kSCREEN_WIDTH-CGRectGetMaxX(imageBank.frame)-8-16, 26) title:@"**** **** **** 1234" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:26 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblCardNo = lblCardNo;
        [viewBack addSubview:self.lblCardNo];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 100, kSCREEN_WIDTH, 16)];
        line2.backgroundColor = RGBBG;
        [self.contentView addSubview:line2];
    }
    return self;
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
