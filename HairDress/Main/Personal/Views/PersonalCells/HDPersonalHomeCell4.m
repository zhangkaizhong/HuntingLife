//
//  HDPersonalHomeCell4.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalHomeCell4.h"

@interface HDPersonalHomeCell4 ()

@end

@implementation HDPersonalHomeCell4

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8)];
        line1.backgroundColor = RGBBG;
        [self.contentView addSubview:line1];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 76, kSCREEN_WIDTH, 8)];
        line2.backgroundColor = RGBBG;
        [self.contentView addSubview:line2];
        
        NSArray *arr = @[@"钱包",@"余额",@"优惠券",@"红包"];
        
        for (int i=0; i<arr.count; i++) {
            
            UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(i*(kSCREEN_WIDTH/arr.count), 8, kSCREEN_WIDTH/arr.count, 56)];
            
            if (i!=0 && i!=1) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 21, 1, 24)];
                line.backgroundColor = RGBCOLOR(245, 245, 245);
                [viewBack addSubview:line];
            }
            
            if (i==0) {
                UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(19, 24, 19, 18)];
                image.image = [UIImage imageNamed:@"personal_ic_03_wallet"];
                [viewBack addSubview:image];
                
                UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(image.frame)+10, 0, viewBack.width-CGRectGetMaxX(image.frame)-10, 14) title:arr[i] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
                lblTitle.centerY = image.centerY;
                [viewBack addSubview:lblTitle];
            }else{
                UILabel *lblNumber = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 19, viewBack.width, 14) title:@"300" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
                [viewBack addSubview:lblNumber];
                
                UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblNumber.bottom+9, viewBack.width, 10) title:arr[i] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
                [viewBack addSubview:lblTitle];
            }
            
            [self.contentView addSubview:viewBack];
        }
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
