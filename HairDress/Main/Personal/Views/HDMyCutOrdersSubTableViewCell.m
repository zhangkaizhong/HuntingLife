//
//  HDMyCutOrdersTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCutOrdersSubTableViewCell.h"

@interface HDMyCutOrdersSubTableViewCell ()

@property (nonatomic,weak) UIView *viewBack;
@property (nonatomic,weak)UILabel *lblShopName;//门店名称
@property (nonatomic,weak)UILabel *lblDistance;//距离
@property (nonatomic,weak)UILabel *lblServiceDes;//服务项目详情

@property (nonatomic,weak) UIButton *button;

@end

@implementation HDMyCutOrdersSubTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16, 8, kSCREEN_WIDTH-32, 316)];
        [self.contentView addSubview:viewBack];
        viewBack.layer.cornerRadius = 4;
        viewBack.backgroundColor = [UIColor whiteColor];
        self.viewBack = viewBack;
        
        // 门店名称/地址
        UIView *viewAddress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewBack.width, 50)];
        [self.viewBack addSubview:viewAddress];
    
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(24, 49, viewAddress.width-48, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewAddress addSubview:line];
        
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, viewAddress.width-48, 16) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblShopName.centerY = viewAddress.height/2;
        self.lblShopName = lblShopName;
        [viewAddress addSubview:lblShopName];
        
//        UILabel *lblDistance = [[UILabel alloc] initCommonWithFrame:CGRectMake(viewAddress.width-16-80, 0, 80, 16) title:@"13.5km" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:YES];
//        lblDistance.centerY = viewAddress.height/2;
//        self.lblDistance = lblDistance;
//        self.lblDistance.x = viewAddress.width-lblDistance.width-24;
//        [viewAddress addSubview:lblDistance];
//
//        UIImageView *imageDis = [[UIImageView alloc] initWithFrame:CGRectMake(viewAddress.width-24-lblDistance.width-20, 0, 16, 16)];
//        imageDis.image = [UIImage imageNamed:@"common_ic_location"];
//        imageDis.centerY = lblDistance.centerY;
//        [viewAddress addSubview:imageDis];
        
        // 项目详情
        NSString *strDes = @"排队号码\n\n发型师\n\n服务项目\n\n合计\n\n取号时间";
        UILabel *lblDesText = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, viewAddress.bottom+16, self.viewBack.width/2, 100) title:strDes bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblDesText.numberOfLines = 0;
        [lblDesText sizeToFit];
        [self.viewBack addSubview:lblDesText];
        
        UILabel *lblDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(80, lblDesText.y, self.viewBack.width-80, 100) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblServiceDes = lblDes;
        [self.viewBack addSubview:lblDes];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(24, lblDesText.bottom+16, self.viewBack.width-48, 1)];
        line1.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.viewBack addSubview:line1];
        
        UIButton *btn = [[UIButton alloc] initSystemWithFrame:CGRectMake(_viewBack.width-24-140, line1.bottom+24, 140, 36) btnTitle:@"评价" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        btn.layer.cornerRadius = 2;
        btn.backgroundColor = RGBMAIN;
        [self.viewBack addSubview:btn];
        self.button = btn;
        [btn addTarget:self action:@selector(btnTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)setModel:(HDUserOrderListModel *)model{
    _model = model;
    
    _lblShopName.text = _model.storeName;
    
    _lblServiceDes.text = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n¥%.2f\n\n%@",_model.queueNum,_model.tonyName,_model.serviceName,[_model.payAmount floatValue],_model.createTime];
    _lblServiceDes.numberOfLines = 0;
    [_lblServiceDes sizeToFit];
    _lblServiceDes.width = self.viewBack.width - 80;
    _lblServiceDes.x = self.viewBack.width - _lblServiceDes.width-24;
    
    if ([_model.orderStatus isEqualToString:@"evaluate"]) {//待评价
        [self.button setTitle:@"评价" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.backgroundColor = RGBMAIN;
        self.button.userInteractionEnabled = YES;
    }else if ([_model.orderStatus isEqualToString:@"finish"]){
        [self.button setTitle:@"已评价" forState:UIControlStateNormal];
        [self.button setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
        self.button.backgroundColor = RGBLINE;
        self.button.userInteractionEnabled = NO;
    }else if ([_model.orderStatus isEqualToString:@"cancel"] || [_model.orderStatus isEqualToString:@"refund"]){//取消或退款的订单
        [self.button setTitle:@"重新取号" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.backgroundColor = RGBMAIN;
        self.button.userInteractionEnabled = YES;
    }
}

-(void)btnTypeAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"评价"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickMyCutOrdersSubBtnType:model:)]) {
            [self.delegate clickMyCutOrdersSubBtnType:MyCutOrdersSubButtonTypeEva model:_model];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickMyCutOrdersSubBtnType:model:)]) {
            [self.delegate clickMyCutOrdersSubBtnType:MyCutOrdersSubButtonTypeRegetNo model:_model];
        }
    }
}

#pragma mark -- 创建UI




- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
