//
//  HDMyCutOrderServiceTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/29.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyCutOrderServiceTableViewCell.h"

@interface HDMyCutOrderServiceTableViewCell ()

@property (nonatomic,weak) UIView *viewBack;
@property (nonatomic,strong)UILabel *lblPaiNo;//排号
@property (nonatomic,strong)UILabel *lblShopName;//门店名称
//@property (nonatomic,strong)UILabel *lblDistance;//距离
@property (nonatomic,strong)UILabel *lblServiceDes;//服务项目详情

@end

@implementation HDMyCutOrderServiceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(16, 8, kSCREEN_WIDTH-32, 302)];
        [self.contentView addSubview:viewBack];
        viewBack.layer.cornerRadius = 4;
        viewBack.backgroundColor = [UIColor whiteColor];
        self.viewBack = viewBack;
        
        [self.viewBack addSubview:self.lblPaiNo];
        
        // 门店名称/地址
        UIView *viewAddress = [[UIView alloc] initWithFrame:CGRectMake(0, self.lblPaiNo.bottom+44, self.viewBack.width, 50)];
        [self.viewBack addSubview:viewAddress];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(24, 0, viewAddress.width-48, 1)];
        line1.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewAddress addSubview:line1];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(24, 49, viewAddress.width-48, 1)];
        line2.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewAddress addSubview:line2];
        
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, 0, viewAddress.width/2+50, 16) title:@"大东城工作室" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
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
        NSString *strDes = @"发型师\n\n服务项目\n\n合计\n\n取号时间";
        UILabel *lblDesText = [[UILabel alloc] initCommonWithFrame:CGRectMake(24, viewAddress.bottom+16, self.viewBack.width/2, 100) title:strDes bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblDesText.numberOfLines = 0;
        [lblDesText sizeToFit];
        [self.viewBack addSubview:lblDesText];
        
        UILabel *lblDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(self.viewBack.width/2+12, lblDesText.y, self.viewBack.width/2, 100) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        lblDes.numberOfLines = 0;
        [lblDes sizeToFit];
        self.lblServiceDes = lblDes;
        [self.viewBack addSubview:lblDes];
    }
    return self;
}

-(UILabel *)lblPaiNo{
    if (!_lblPaiNo) {
        _lblPaiNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 32, _viewBack.width, 24) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:24 textAlignment:NSTextAlignmentCenter isFit:NO];
        
        UILabel *lblPaiText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, _lblPaiNo.bottom+8, _viewBack.width, 12) title:@"排队号码" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [self.viewBack addSubview:lblPaiText];
    }
    return _lblPaiNo;
}


-(void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    _lblPaiNo.text = _dic[@"queueNum"];
    
    _lblShopName.text = _dic[@"storeName"];
    
    _lblServiceDes.text = [NSString stringWithFormat:@"%@\n\n%@\n\n¥%.2f\n\n%@",_dic[@"tonyName"],_dic[@"serviceName"],[_dic[@"payAmount"] floatValue],_dic[@"createTime"]];
    _lblServiceDes.numberOfLines = 0;
    [_lblServiceDes sizeToFit];
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
