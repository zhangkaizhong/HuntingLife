//
//  HDTaoGoodsDetailImageCell.m
//  HairDress
//
//  Created by Apple on 2020/1/16.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoGoodsDetailImageCell.h"

#import "XHWebImageAutoSize.h"

@interface HDTaoGoodsDetailImageCell ()


@end

@implementation HDTaoGoodsDetailImageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imagev = [[UIImageView alloc] init];
        [self.contentView addSubview:imagev];
        imagev.contentMode = 2;
        imagev.layer.masksToBounds = YES;
        self.imageV = imagev;
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
