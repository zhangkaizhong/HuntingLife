//
//  HDTaskListTableViewCell.m
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaskListTableViewCell.h"

@interface HDTaskListTableViewCell ()

@property (nonatomic,weak) UIImageView *taskImgView;
@property (nonatomic,weak) UIImageView *imgType;//任务类型
@property (nonatomic,weak) UILabel *lblTaskName;//任务名
@property (nonatomic,weak) UILabel *lblTaskDes;//任务描述
@property (nonatomic,weak) UIImageView *imgModey;
@property (nonatomic,weak) UIImageView *imgJoin;
@property (nonatomic,weak) UILabel *lblMoney;//奖励
@property (nonatomic,weak) UILabel *lblDoneNum;//完成人数
@property (nonatomic,weak) UIView *line;//分割线

@end

@implementation HDTaskListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *taskImgView = [[UIImageView alloc] initWithFrame:CGRectMake(23*SCALE, 21*SCALE, 55*SCALE, 55*SCALE)];
        self.taskImgView = taskImgView;
        taskImgView.layer.cornerRadius = 55*SCALE/2;
        taskImgView.layer.masksToBounds = YES;
        taskImgView.contentMode = 2;
        [self.contentView addSubview:self.taskImgView];
        
        UIImageView *imgType = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(taskImgView.frame)+15*SCALE, 20*SCALE, 28*SCALE, 14*SCALE)];
        self.imgType = imgType;
        [self.contentView addSubview:self.imgType];
        
        UILabel *lblTaskName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(self.imgType.frame)+7*SCALE, 0, kSCREEN_WIDTH-CGRectGetMaxX(self.imgType.frame)-7*SCALE-16*SCALE-46*SCALE-15*SCALE, 13*SCALE) title:@"" bgColor:[UIColor whiteColor] titleColor:RGBLIGHT_TEXTINFO titleFont:13*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblTaskName = lblTaskName;
        lblTaskName.centerY = imgType.centerY;
        lblTaskName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 13*SCALE);
        [self.contentView addSubview:lblTaskName];
        
        
        UILabel *lblTaskDes = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(taskImgView.frame)+15*SCALE, imgType.bottom+7*SCALE, kSCREEN_WIDTH-CGRectGetMaxX(taskImgView.frame)-15*SCALE-16*SCALE-46*SCALE-15*SCALE, 18) title:@"" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(106, 106, 106) titleFont:10*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblTaskDes = lblTaskDes;
        [self.contentView addSubview:lblTaskDes];
        
        UIImageView *imgModey = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(taskImgView.frame)+15*SCALE, lblTaskDes.bottom+7*SCALE, 18*SCALE, 16*SCALE)];
        self.imgModey = imgModey;
        self.imgModey.image = [UIImage imageNamed:@"tasklist_ic_gold"];
        [self.contentView addSubview:self.imgModey];
        
        UILabel *lblMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgModey.frame)+5*SCALE, 0, 0, 11*SCALE) title:@"" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(111, 111, 111) titleFont:11*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblMoney = lblMoney;
        [self.contentView addSubview:lblMoney];
        
        UILabel *lblDoneNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblMoney.frame)+27*SCALE, 0, 0, 10*SCALE) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblDoneNum = lblDoneNum;
        [self.contentView addSubview:lblDoneNum];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(8*SCALE, 87, kSCREEN_WIDTH-16*SCALE, 1)];
        line.backgroundColor = RGBCOLOR(225, 225, 225);
        [self.contentView addSubview:line];
        self.line = line;
        
        UIImageView *imageJoin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tasklist_ic_participate"]];
        imageJoin.x = kSCREEN_WIDTH-16*SCALE-46*SCALE;
        self.imgJoin = imageJoin;
        self.imgJoin.centerY = self.taskImgView.centerY;
        [self.contentView addSubview:imageJoin];
    }
    return self;
}

-(void)setModel:(HDTaskListModel *)model{
    _model = model;
    
    [self.taskImgView sd_setImageWithURL:[NSURL URLWithString:model.taskImg] placeholderImage:[UIImage imageNamed:@"barber_ic_customer"]];
    
    if ([model.taskType isEqualToString:@"share"]) {
        self.imgType.image = [UIImage imageNamed:@"tasklist_ic_share"];
    }else if ([model.taskType isEqualToString:@"seem"]){
        self.imgType.image = [UIImage imageNamed:@"tasklist_ic_like"];
    }else if ([model.taskType isEqualToString:@"video"]){
        self.imgType.image = [UIImage imageNamed:@"tasklist_ic_play"];
    }
    
    self.lblTaskName.text = model.taskName;
    
    self.lblTaskDes.width = kSCREEN_WIDTH-CGRectGetMaxX(self.taskImgView.frame)-15*SCALE-16*SCALE-46*SCALE-15*SCALE;
    self.lblTaskDes.text = model.taskDesc;
    self.lblTaskDes.numberOfLines = 1;
//    [self.lblTaskDes sizeToFit];
    
    self.lblMoney.text = [NSString stringWithFormat:@"+%.2f",[model.taskMoney floatValue]];
    [self.lblMoney sizeToFit];
    
    self.lblDoneNum.text = [NSString stringWithFormat:@"%@人完成",model.finishNum];
    [self.lblDoneNum sizeToFit];
    self.lblDoneNum.x = CGRectGetMaxX(self.lblMoney.frame)+27*SCALE;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.taskImgView.frame = self.model.taskImgFrame;
    self.imgType.frame = self.model.taskTypeFrame;
    self.lblTaskDes.frame = self.model.taskDescFrame;
    self.imgModey.frame = self.model.taskMoneyImgFrame;
    self.lblMoney.bottom = self.imgModey.bottom;
    self.lblDoneNum.centerY = self.lblMoney.centerY;
    self.line.frame = self.model.lineFrame;
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
