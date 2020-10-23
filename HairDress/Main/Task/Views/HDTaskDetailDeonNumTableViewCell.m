//
//  HDTaskDetailDeonNumTableViewCell.m
//  HairDress
//
//  Created by Apple on 2020/2/10.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaskDetailDeonNumTableViewCell.h"

@interface HDTaskDetailDeonNumTableViewCell ()

@property (nonatomic,weak) UIImageView *headImage;
@property (nonatomic,weak) UILabel *lblName;
@property (nonatomic,weak) UILabel *lblMoney;
@property (nonatomic,weak) UILabel *lblDate;

@end

@implementation HDTaskDetailDeonNumTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageHead = [[UIImageView alloc] initWithFrame:CGRectMake(12, 6, 40, 40)];
        [self.contentView addSubview:imageHead];
        imageHead.layer.masksToBounds = YES;
        imageHead.contentMode = 2;
        imageHead.layer.cornerRadius = 20;
        self.headImage = imageHead;
        
        UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageHead.frame)+12, 0, 100, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblName.centerY = 26;
        self.lblName = lblName;
        [self.contentView addSubview:lblName];
        
        UILabel *lblMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblName.frame)+24, 0, 100, 14) title:@"获得 1 元" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
        lblMoney.centerY = lblName.centerY;
        self.lblMoney = lblMoney;
        [self.contentView addSubview:lblMoney];
        
        UILabel *lblDate = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblMoney.frame)+5, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblMoney.frame)-5-12, 14) title:@"12月10日" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:YES];
        lblDate.centerY = lblName.centerY;
        lblDate.x = kSCREEN_WIDTH - lblDate.width-12;
        self.lblDate = lblDate;
        [self.contentView addSubview:lblDate];
    }
    return self;
}

-(void)setDic:(NSDictionary *)dic{
    _dic = [HDToolHelper nullDicToDic:dic];
    
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:dic[@"headImg"]]];
    NSString *userNameStr = dic[@"userName"];
    
    NSInteger index = 1;
    if (![HDToolHelper StringIsNullOrEmpty:userNameStr]) {
        if ([userNameStr length] > 2) {
            index = 2;
        }
        NSString *userName = [userNameStr stringByReplacingCharactersInRange:NSMakeRange(1, [userNameStr length]-index) withString:@"**"];
        self.lblName.text = userName;
    }
    [self.lblName sizeToFit];
    self.lblName.height = 14;
    self.lblMoney.text = [NSString stringWithFormat:@"获得%.2f元",[dic[@"taskMoney"] floatValue]];
    self.lblMoney.x = CGRectGetMaxX(_lblName.frame)+40;
    [self.lblMoney sizeToFit];
    self.lblMoney.centerY = self.lblName.centerY;
    
    self.lblDate.text = dic[@"finishDate"];
    [self.lblDate sizeToFit];
    self.lblDate.x = kSCREEN_WIDTH - self.lblDate.width-16;
    self.lblDate.centerY = self.lblName.centerY;
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
