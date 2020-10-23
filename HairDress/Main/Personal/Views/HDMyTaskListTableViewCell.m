//
//  HDTaskListTableViewCell.m
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyTaskListTableViewCell.h"

@interface HDMyTaskListTableViewCell ()

@property (nonatomic,weak) UIView *backView;
@property (nonatomic,weak) UILabel *lblTaskName;//任务名

@property (nonatomic,weak) UILabel *lblMoney;//奖励
@property (nonatomic,weak) UILabel *lblMyTaskType;//任务进行状态

@property (nonatomic,weak) UIImageView *taskImgView;//任务图片
@property (nonatomic,weak) UILabel *lblType;//任务类型
@property (nonatomic,weak) UILabel *lblTimeText;//
@property (nonatomic,weak) UILabel *lblTime;//

@property(nonatomic,strong)HDMyTaskListModel *model;

@end

@implementation HDMyTaskListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(11*SCALE, 9*SCALE, kSCREEN_WIDTH-21*SCALE-24*SCALE, 105*SCALE)];
        backView.layer.cornerRadius = 9.8;
        backView.layer.borderWidth = 1;
        self.backView = backView;
        backView.layer.borderColor = HexRGBAlpha(0xEBEBEB, 1).CGColor;
        [self.contentView addSubview:backView];
        
        UIImageView *taskImgView = [[UIImageView alloc] initWithFrame:CGRectMake(17*SCALE, 18*SCALE, 49*SCALE, 49*SCALE)];
        self.taskImgView = taskImgView;
        taskImgView.layer.cornerRadius = 49*SCALE/2;
        taskImgView.layer.masksToBounds = YES;
        taskImgView.contentMode = 2;
        [backView addSubview:self.taskImgView];
        
        UILabel *lblType = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(self.taskImgView.frame)+12*SCALE, 19*SCALE, 25*SCALE, 12*SCALE) title:@"分享" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:8*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
        lblType.layer.cornerRadius = 2;
        self.lblType = lblType;
        [backView addSubview:self.lblType];
        
        UILabel *lblMyTaskType = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 100, 12) title:@"进行中" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(255, 194, 63) titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
        lblMyTaskType.centerY = lblType.centerY;
        self.lblMyTaskType = lblMyTaskType;
        [backView addSubview:lblMyTaskType];
        
        UILabel *lblTaskName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(self.lblType.frame)+5*SCALE, 0, kSCREEN_WIDTH-CGRectGetMaxX(self.lblType.frame)-7*SCALE-16*SCALE-46*SCALE-15*SCALE, 12*SCALE) title:@"" bgColor:[UIColor whiteColor] titleColor:RGBLIGHT_TEXTINFO titleFont:13*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblTaskName = lblTaskName;
        lblTaskName.centerY = lblType.centerY;
        lblTaskName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 12*SCALE);
        [backView addSubview:lblTaskName];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lblType.x, lblTaskName.bottom+5*SCALE, backView.width-lblType.x-8*SCALE, 1)];
        line.backgroundColor = RGBCOLOR(251, 251, 251);
        [backView addSubview:line];
        
        UIImageView *imgModey = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mytask_ic_gold"]];
        imgModey.x = 19*SCALE;
        imgModey.y = taskImgView.bottom+7*SCALE;
        [backView addSubview:imgModey];
        
        UILabel *lblMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgModey.frame)+3*SCALE, 0, 0, 10*SCALE) title:@"" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(111, 111, 111) titleFont:10*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblMoney = lblMoney;
        self.lblMoney.centerY = imgModey.centerY;
        [backView addSubview:lblMoney];
        
        UILabel *lblTimeText = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(taskImgView.frame)+12*SCALE, 45*SCALE, backView.width-CGRectGetMaxX(taskImgView.frame)-12*SCALE, 56*SCALE) title:[NSString stringWithFormat:@"接单时间\n交付时间\n审核时间\n完成时间"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(137, 137, 137) titleFont:9*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblTimeText = lblTimeText;
        lblTimeText.numberOfLines = 0;
        [lblTimeText sizeToFit];
        [backView addSubview:lblTimeText];
        
        UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblTimeText.frame)+10*SCALE, lblTimeText.y, backView.width-CGRectGetMaxX(lblTimeText.frame)-10*SCALE-9*SCALE, 10) title:[NSString stringWithFormat:@""] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(137, 137, 137) titleFont:9*SCALE textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblTime = lblTime;
        [backView addSubview:lblTime];
        
        lblMoney.width = lblTimeText.x - imgModey.x-3*SCALE;
        lblMoney.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

-(void)setSecond:(HDMyTaskListModel *)model row:(NSInteger)row{
    _model = model;
    
    self.lblTaskName.text = model.taskName;
    self.lblMoney.text = [NSString stringWithFormat:@"+%.2f",[_model.taskMoney floatValue]];
    [self.lblMoney sizeToFit];
    
    self.lblMyTaskType.text = [NSString stringWithFormat:@"%@ >",model.checkStatus];
    [self.lblMyTaskType sizeToFit];
    self.lblMyTaskType.x = self.backView.width - self.lblMyTaskType.width-9*SCALE;
    self.lblMyTaskType.centerY = self.lblType.centerY-3;
    
    self.lblTaskName.width = self.lblMyTaskType.x - self.lblTaskName.x-10*SCALE;
    
    [self.taskImgView sd_setImageWithURL:[NSURL URLWithString:model.taskImg] placeholderImage:[UIImage imageNamed:@"barber_ic_customer"]];
    
    if ([model.checkStatus isEqualToString:@"进行中"]) {
        self.lblMyTaskType.textColor = RGBCOLOR(255, 194, 63);
    }else if ([model.checkStatus isEqualToString:@"审核中"]){
        self.lblMyTaskType.textColor = RGBMAIN;
    }else{
        self.lblMyTaskType.textColor = RGBTEXTINFO;
    }
    
    self.lblTime.width = self.backView.width-CGRectGetMaxX(self.taskImgView.frame)-12*SCALE-9*SCALE;
    
    NSString *acceptTime = [HDToolHelper StringIsNullOrEmpty:model.acceptTime] ? @"" : model.acceptTime;
    NSString *sendTime = [HDToolHelper StringIsNullOrEmpty:model.sendTime] ? @"" : model.sendTime;
    NSString *checkTime = [HDToolHelper StringIsNullOrEmpty:model.checkTime] ? @"" : model.checkTime;
    NSString *updateTime = [HDToolHelper StringIsNullOrEmpty:model.updateTime] ? @"" : model.updateTime;
    NSString *strTime = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",acceptTime,sendTime,checkTime,updateTime];
    self.lblTime.text = strTime;
    self.lblTime.numberOfLines = 0;
    [self.lblTime sizeToFit];
    self.lblTime.x = self.backView.width - self.lblTime.width - 9*SCALE;
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
