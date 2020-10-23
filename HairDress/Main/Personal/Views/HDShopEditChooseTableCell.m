//
//  HDShopEditChooseTableCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDShopEditChooseTableCell.h"

@interface HDShopEditChooseTableCell ()

@property (nonatomic,strong) UILabel *lblChooseContent;
@property (nonatomic,strong) UIImageView *imageSelect;

@end

@implementation HDShopEditChooseTableCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.lblChooseContent];
        [self.contentView addSubview:self.imageSelect];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setModel:(HDShopEditChooseModel *)model{
    _model = model;
    
    self.lblChooseContent.text = model.configName;
    if ([model.select isEqualToString:@"1"]) {
        self.imageSelect.hidden = NO;
    }
    else{
        self.imageSelect.hidden = YES;
    }
}

-(UILabel *)lblChooseContent{
    if (!_lblChooseContent) {
        _lblChooseContent = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-40, 14) title:@"专注剪发服务" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblChooseContent;
}

-(UIImageView *)imageSelect{
    if (!_imageSelect) {
        _imageSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_ic_selected"]];
        _imageSelect.x = kSCREEN_WIDTH-17-16;
        _imageSelect.centerY = _lblChooseContent.centerY;
    }
    return _imageSelect;
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
