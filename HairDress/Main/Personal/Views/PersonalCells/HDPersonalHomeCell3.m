//
//  HDPersonalHomeCell3.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalHomeCell3.h"

@interface HDPersonalHomeCell3 ()



@end

@implementation HDPersonalHomeCell3

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 8)];
        line.backgroundColor = RGBBG;
        [self.contentView addSubview:line];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 63, kSCREEN_WIDTH, 8)];
        line1.backgroundColor = RGBBG;
        [self.contentView addSubview:line1];
        
        NSArray *arr = @[
//  @{@"image":@"personal_ic_02_vip",@"title":@"剪发会员卡"},
  @{@"image":@"personal_ic_02_favorite",@"title":@"我的收藏"}];
        for (int i = 0; i<arr.count; i++) {
            UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(i*(kSCREEN_WIDTH/arr.count), 8, kSCREEN_WIDTH/arr.count, 56)];
            if (i !=0) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 16, 1, 24)];
                line.backgroundColor = RGBCOLOR(245, 245, 245);
                [viewBack addSubview:line];
            }
            
            viewBack.tag = 10000+i;
            
            //添加点击动作
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            viewBack.userInteractionEnabled = YES;
            [viewBack addGestureRecognizer:tap];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 32, 32)];
            image.image = [UIImage imageNamed:arr[i][@"image"]];
            image.centerY = viewBack.height/2;
            [viewBack addSubview:image];
            
            UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(image.frame)+10*SCALE, 0, viewBack.width-CGRectGetMaxX(image.frame)-50*SCALE, 14) title:arr[i][@"title"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            [viewBack addSubview:lblTitle];
            lblTitle.centerY = viewBack.height/2;
            
            UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(viewBack.width-16*SCALE-24*SCALE, 0, 24, 24)];
            imageGo.centerY = viewBack.height/2;
            imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
            [viewBack addSubview:imageGo];
            
            
            [self.contentView addSubview:viewBack];
        }
    }
    return self;
}

-(void)tapAction:(UIGestureRecognizer *)sender{
//    if (sender.view.tag == 10000) {//VIP
//        if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellThreeViews:)]) {
//            [self.delegate clickCellThreeViews:HDPersonalHomeCellThreeClickTypeVIPCard];
//        }
//    }
//    else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellThreeViews:)]) {
            [self.delegate clickCellThreeViews:HDPersonalHomeCellThreeClickTypeCollect];
        }
//    }
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
