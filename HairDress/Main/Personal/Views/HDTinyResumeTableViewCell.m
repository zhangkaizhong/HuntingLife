//
//  HDTinyResumeTableViewCell.m
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDTinyResumeTableViewCell.h"

@interface HDTinyResumeTableViewCell ()

@property (nonatomic,strong) UILabel * lblShop;  // 店名
@property (nonatomic,strong) UILabel * lblTime;  // 在职时间
@property (nonatomic,weak) UIView *line;
@end

@implementation HDTinyResumeTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.lblShop];
        [self.contentView addSubview:self.lblTime];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        self.line = line;
        [self.contentView addSubview:line];
    }
    return self;
}

-(void)setModel:(HDCutterResumeExpModel *)model{
    _model = model;
    
    _lblShop.text = model.storeName;
    _lblShop.width = kSCREEN_WIDTH-32;
    _lblShop.numberOfLines = 0;
    [_lblShop sizeToFit];
    
    _lblTime.y = _lblShop.bottom+12;
    _lblTime.text = [NSString stringWithFormat:@"%@-%@",_model.startTime,_model.endTime];
}

-(void)setRowIndex:(NSInteger)rowIndex{
    _rowIndex = rowIndex;
    if (_rowIndex == 0) {
        self.line.hidden = YES;
    }
}

-(UILabel *)lblShop{
    if (!_lblShop) {
        _lblShop = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 21, kSCREEN_WIDTH-32, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblShop;
}

-(UILabel *)lblTime{
    if (!_lblTime) {
        _lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, _lblShop.bottom+12, kSCREEN_WIDTH, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblTime;
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
