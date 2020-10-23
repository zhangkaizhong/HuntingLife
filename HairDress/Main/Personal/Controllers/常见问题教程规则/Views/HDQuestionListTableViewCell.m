//
//  HDQuestionListTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDQuestionListTableViewCell.h"

@interface HDQuestionListTableViewCell ()

@property (nonatomic,strong) UIView *questionView;
@property (nonatomic,strong) UIImageView *questionImage;
@property (nonatomic,strong) UILabel *lblQuestionTitle;
@property (nonatomic,strong) UIButton *btnArrow;
@property (nonatomic,strong) UIView *line;

@end

@implementation HDQuestionListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.questionImage];
        [self.contentView addSubview:self.lblQuestionTitle];
        [self.contentView addSubview:self.btnArrow];
        
        [self.contentView addSubview:self.questionView];
        
        [self.contentView addSubview:self.line];
    }
    return self;
}

#pragma mark -- UI

-(UIImageView *)questionImage{
    if (!_questionImage) {
        _questionImage = [[UIImageView alloc] initWithFrame:CGRectMake(36*SCALE, 25*SCALE, 24*SCALE, 24*SCALE)];
        _questionImage.centerX = 111*SCALE/2;
    }
    return _questionImage;
}

-(UILabel *)lblQuestionTitle{
    if (!_lblQuestionTitle) {
        _lblQuestionTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, _questionImage.bottom+16*SCALE, 111*SCALE, 14*SCALE) title:@"关于商品" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
    }
    return _lblQuestionTitle;
}

-(UIButton *)btnArrow{
    if (!_btnArrow) {
        _btnArrow = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, _lblQuestionTitle.bottom+15*SCALE, 24*SCALE, 24*SCALE) btnTitle:@"" btnImage:@"problem_ic_down" titleColor:[UIColor clearColor] titleFont:0];
        _btnArrow.centerX = _lblQuestionTitle.centerX;
        [_btnArrow addTarget:self action:@selector(checkMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnArrow;
}

-(UIView *)questionView{
    if (!_questionView) {
        _questionView = [[UIView alloc] initWithFrame:CGRectMake(111*SCALE, 0, kSCREEN_WIDTH-111*SCALE, 100)];
        
        for (int i = 0; i<30; i++) {
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, i*10, _questionView.width, 50*SCALE)];
            subView.tag = 100+i;
            
            UITapGestureRecognizer *tapQuestion = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(questionDetailAction:)];
            subView.userInteractionEnabled = YES;
            [subView addGestureRecognizer:tapQuestion];
            
            [_questionView addSubview:subView];
            
            UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 20*SCALE, _questionView.width-23*SCALE, 10) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
            lblTitle.tag = 1000;
            [subView addSubview:lblTitle];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, lblTitle.bottom+20*SCALE, _questionView.width, 1)];
            line.backgroundColor = HexRGBAlpha(0xEEEEEE,1);
            line.tag = 2000;
            [subView addSubview:line];
        }
    }
    return _questionView;
}

-(UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-32*SCALE, 1)];
        _line.backgroundColor = HexRGBAlpha(0xEEEEEE,1);
    }
    return _line;
}

#pragma mark -- setModel

-(void)setModel:(HDQuestionModel *)model{
    _model = model;
    
    [_questionImage sd_setImageWithURL:[NSURL URLWithString:_model.icon] placeholderImage:[UIImage imageNamed:@"problem_ic_order"]];
    _lblQuestionTitle.text = _model.title;
    
    for (int i = 0; i<30; i++) {
        UIView *view = (UIView *)[_questionView viewWithTag:100+i];
        view.hidden = YES;
    }
    
    NSMutableArray *arrList = [NSMutableArray new];
    if ([_model.isSelect isEqualToString:@"1"]) {
        [arrList addObjectsFromArray:_model.list];
    }else{
        if (_model.list.count > 2) {
            [arrList addObjectsFromArray:[_model.list subarrayWithRange:NSMakeRange(0, 2)]];
        }else{
            [arrList addObjectsFromArray:_model.list];
        }
    }
    
    for (int i = 0; i<arrList.count; i++) {
        if (i<30) {
            NSDictionary *dic = arrList[i];
            UIView *view = (UIView *)[_questionView viewWithTag:100+i];
            
            view.hidden = NO;
            UILabel *lbl = (UILabel *)[view viewWithTag:1000];
            lbl.width = view.width-23*SCALE;
            lbl.text = dic[@"title"];
            lbl.numberOfLines = 0;
            [lbl sizeToFit];
            
            UIView *line = (UIView *)[view viewWithTag:2000];
            line.y = lbl.bottom + 20*SCALE;
            line.hidden = NO;
            
            view.height = CGRectGetMaxY(line.frame);
            
            UIView *viewlast = (UIView *)[_questionView viewWithTag:100+i-1];
            if (i==0) {
                view.y = 0;
            }else{
                view.y = CGRectGetMaxY(viewlast.frame);
            }
            
            if (i == arrList.count-1) {
                line.hidden = YES;
            }
        }
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.btnArrow.frame = self.model.btnArrowFrame;
    self.questionView.frame = self.model.questionListFrame;
    self.line.frame = self.model.lineFrame;
    
    if (_model.list.count < 2) {
        self.questionView.centerY = _model.cellHeight/2;
    }
    
    if (_model.list.count <= 2) {
        self.btnArrow.hidden = YES;
    }else{
        self.btnArrow.hidden = NO;
    }
}

//查看更多
-(void)checkMoreAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"problem_ic_up"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"problem_ic_down"] forState:UIControlStateNormal];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCheckMoreQuestionWithModel:)]) {
        [self.delegate clickCheckMoreQuestionWithModel:_model];
    }
}

//查看问题详情
-(void)questionDetailAction:(UIGestureRecognizer *)sender{
    NSInteger tag = sender.view.tag;
    NSInteger index = tag - 100;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCheckQuestionDetailWithDic:)]) {
        [self.delegate clickCheckQuestionDetailWithDic:self.model.list[index]];
    }
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
