//
//  HDPersonalHomeCell1.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalHomeCell1.h"

@implementation HDPersonalHomeCell1

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSArray *arr = @[@{@"image":@"personal_ic_01_income",@"title":@"我的收益"},@{@"image":@"personal_ic_01_order",@"title":@"我的订单"},@{@"image":@"personal_ic_01_withdraw",@"title":@"余额提现"},@{@"image":@"personal_ic_01_team",@"title":@"我的团队"}];
        
        for (int i = 0 ; i< arr.count; i++) {
            UIView * viewBack = [[UIView alloc] initWithFrame:CGRectMake(17+i*(kSCREEN_WIDTH-34)/arr.count, 0, (kSCREEN_WIDTH-34)/arr.count, 98)];
            [self.contentView addSubview:viewBack];
            viewBack.tag = 100+i;
            // 点击动作
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            viewBack.userInteractionEnabled = YES;
            [viewBack addGestureRecognizer:tap];
            
            UIImageView *imageItem = [[UIImageView alloc] init];
            imageItem.frame = CGRectMake(0, 28, 32, 32);
            imageItem.image = [UIImage imageNamed:arr[i][@"image"]];
            imageItem.centerX = viewBack.width/2;
            [viewBack addSubview:imageItem];
            
            UILabel *lblItem = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageItem.bottom+10, viewBack.width, 12) title:arr[i][@"title"] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
            lblItem.centerX = viewBack.width/2;
            [viewBack addSubview:lblItem];
            
        }
    }
    return self;
}

-(void)tapAction:(UIGestureRecognizer *)sender{
    NSInteger tag = sender.view.tag;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellOneMenuType:)]) {
        [self.delegate clickCellOneMenuType:tag-100];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
