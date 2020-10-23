//
//  CellForQAList.m
//  github:  https://github.com/samuelandkevin
//  CSDN:  http://blog.csdn.net/samuelandkevin
//  Created by samuelandkevin on 16/8/29.
//  Copyright © 2016年 HKP. All rights reserved.
//

#import "HDServiceEvaTableViewCell.h"

#import "YHWorkGroupPhotoContainer.h"

const CGFloat contentLabelFontSize = 14.0;
CGFloat maxContentLabelHeight = 0;  //根据具体font而定
CGFloat kMarginContentLeft    = 10; //动态内容左边边距
CGFloat kMarginContentRight   = 10; //动态内容右边边边距
const CGFloat deleteBtnHeight = 30;
const CGFloat deleteBtnWidth  = 60;
const CGFloat moreBtnHeight   = 30;
const CGFloat moreBtnWidth    = 60;

@interface HDServiceEvaTableViewCell ()

@property (nonatomic,strong)UIImageView *imgvAvatar;
@property (nonatomic,strong)UILabel     *labelName;
@property (nonatomic,strong)UILabel     *labelPubTime;
@property (nonatomic,strong)UILabel     *labelPhone;
@property (nonatomic,strong)UILabel     *labelContent;

@property (nonatomic,strong)UILabel     *labelDelete;
@property (nonatomic,strong)UILabel     *labelMore;

@property (nonatomic,strong) UILabel * lblCutterName;  // 发型师
@property (nonatomic,strong) UIView * viewScroe;;  // 评分

@property (nonatomic,strong)YHWorkGroupPhotoContainer *picContainerView;
@property (nonatomic,strong)UIView      *viewSeparator;

@end

@implementation HDServiceEvaTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup{
    
    self.imgvAvatar = [UIImageView new];
    self.imgvAvatar.layer.cornerRadius = 20;
    self.imgvAvatar.layer.masksToBounds = YES;
    [self.contentView addSubview:self.imgvAvatar];
    
    self.labelName  = [UILabel new];
    self.labelName.font = [UIFont systemFontOfSize:14.0f];
    self.labelName.textColor = RGBTEXT;
    [self.contentView addSubview:self.labelName];
    
    // scroeView
    self.viewScroe = [[UIView alloc] init];
    [self.contentView addSubview:self.viewScroe];
    
    // 分数
    for (int i = 0; i<5; i++) {
        UIImageView *imageScroe = [[UIImageView alloc] initWithFrame:CGRectMake(i*12, 0, 9, 8)];
        imageScroe.image = [UIImage imageNamed:@"evaluation_s_nor"];
        imageScroe.tag = 1000+i;
        [self.viewScroe addSubview:imageScroe];
    }
    
    self.labelPhone = [UILabel new];
    self.labelPhone.font = [UIFont systemFontOfSize:12.0f];
    self.labelPhone.textColor = RGBAlpha(153, 153, 153, 1);
    [self.contentView addSubview:self.labelPhone];
    
    self.labelContent = [UILabel new];
    self.labelContent.font = [UIFont systemFontOfSize:contentLabelFontSize];
    self.labelContent.numberOfLines = 0;
    [self.contentView addSubview:self.labelContent];
    
     self.labelDelete = [UILabel new];
     [self.contentView addSubview:self.labelDelete];
    
     self.labelMore = [UILabel new];
     [self.contentView addSubview:self.labelMore];
    

     self.picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:kSCREEN_WIDTH-68-16];
     [self.contentView addSubview:self.picContainerView];
    
     self.viewBottom = [UIView new];
     [self.contentView addSubview:self.viewBottom];
    // 发型师名称，时间
    self.lblCutterName = [[UILabel alloc] initCommonWithFrame:CGRectMake(68, 0, 150, 12) title:@"发型师：Tony老师" bgColor:[UIColor clearColor] titleColor:RGBAlpha(153, 153, 153, 1) titleFont:12 textAlignment:NSTextAlignmentLeft isFit:YES];
    [self.viewBottom addSubview:self.lblCutterName];

    self.labelPubTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 150, 12) title:@"2019-09-08" bgColor:[UIColor clearColor] titleColor:RGBAlpha(153, 153, 153, 1) titleFont:12 textAlignment:NSTextAlignmentRight isFit:YES];
    self.labelPubTime.x = kSCREEN_WIDTH-_labelPubTime.width-16;
    [self.viewBottom addSubview:self.labelPubTime];
    
     self.viewSeparator = [UIView new];
     self.viewSeparator.backgroundColor = RGBBG;
     [self.contentView addSubview:self.viewSeparator];

     [self layoutUI];
}

- (void)layoutUI{
      __weak typeof(self)weakSelf = self;
     [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(weakSelf.contentView).offset(24);
         make.left.equalTo(weakSelf.contentView).offset(16);
         make.width.height.mas_equalTo(40);
     }];
    
    [self.labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView).offset(24);
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(12);
        make.right.equalTo(weakSelf.viewScroe.mas_left).offset(-10);
    }];
   
    [self.viewScroe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.labelName.mas_bottom);
        make.right.equalTo(weakSelf.contentView).offset(-16);
        make.width.mas_equalTo(57);
        make.height.mas_equalTo(8);
    }];

    [self.labelPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelName.mas_bottom).offset(6);
        make.left.equalTo(weakSelf.labelName.mas_left);
        make.right.equalTo(weakSelf.contentView).offset(-16);
    }];
    
    [self.labelContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView).offset(68);
        make.right.equalTo(weakSelf.contentView).offset(-16);
        make.bottom.equalTo(weakSelf.labelMore.mas_top).offset(0);
    }];

    // 不然在6/6plus上就不准确了
    self.labelContent.preferredMaxLayoutWidth = kSCREEN_WIDTH - 68-16;
    
    
    [self.labelMore mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(weakSelf.labelContent.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(80);
    }];
    
    [self.labelDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.labelMore.mas_centerY);
        make.left.equalTo(weakSelf.labelMore.mas_right).offset(10);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(80);
    }];
    

    [self.picContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelMore.mas_bottom).offset(12);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.height.mas_equalTo(0);
        make.right.mas_greaterThanOrEqualTo(weakSelf.contentView).offset(-10);
    }];
    [self.picContainerView setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [self.picContainerView setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];
    
    
    [self.viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.picContainerView.mas_bottom).offset(12).priorityLow();
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(36);
    }];
    
    [self.viewSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.viewBottom.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(8);
        make.bottom.equalTo(weakSelf.contentView);
    }];
    
}


- (void)setModel:(HDEvaluateModel *)model{
    _model = model;
    [self.imgvAvatar sd_setImageWithURL:[NSURL URLWithString:_model.headImg] placeholderImage:[UIImage imageNamed:@"barber_ic_customer"]];
    self.labelName.text   = _model.userName;
    NSString *phoneNum = [_model.phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    self.labelPhone.text  = [NSString stringWithFormat:@"%@",phoneNum];
    self.lblCutterName.text = [NSString stringWithFormat:@"发型师：%@",_model.tonyName];
    self.labelPubTime.text = _model.createTime;
    [self.labelPubTime sizeToFit];
    self.labelPubTime.x = kSCREEN_WIDTH - self.labelPubTime.width-16;
    self.lblCutterName.width = self.labelPubTime.x - self.lblCutterName.x - 10;
    
    UIImageView *image1 = (UIImageView *)[self.viewScroe viewWithTag:1000];
    UIImageView *image2 = (UIImageView *)[self.viewScroe viewWithTag:1001];
    UIImageView *image3 = (UIImageView *)[self.viewScroe viewWithTag:1002];
    UIImageView *image4 = (UIImageView *)[self.viewScroe viewWithTag:1003];
    UIImageView *image5 = (UIImageView *)[self.viewScroe viewWithTag:1004];
    if ([_model.totalStars integerValue] == 1) {
        image1.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image2.image = [UIImage imageNamed:@"evaluation_s_nor"];
        image3.image = [UIImage imageNamed:@"evaluation_s_nor"];
        image4.image = [UIImage imageNamed:@"evaluation_s_nor"];
        image5.image = [UIImage imageNamed:@"evaluation_s_nor"];
    }
    if ([_model.totalStars integerValue] == 2) {
        image1.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image2.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image3.image = [UIImage imageNamed:@"evaluation_s_nor"];
        image4.image = [UIImage imageNamed:@"evaluation_s_nor"];
        image5.image = [UIImage imageNamed:@"evaluation_s_nor"];
    }
    if ([_model.totalStars integerValue] == 3) {
        image1.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image2.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image3.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image4.image = [UIImage imageNamed:@"evaluation_s_nor"];
        image5.image = [UIImage imageNamed:@"evaluation_s_nor"];
    }
    if ([_model.totalStars integerValue] == 4) {
        image1.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image2.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image3.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image4.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image5.image = [UIImage imageNamed:@"evaluation_s_nor"];
    }
    if ([_model.totalStars integerValue] == 5) {
        image1.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image2.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image3.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image4.image = [UIImage imageNamed:@"evaluation_s_selected"];
        image5.image = [UIImage imageNamed:@"evaluation_s_selected"];
    }
    
    /*************动态内容*************/
    maxContentLabelHeight   = _labelContent.font.pointSize * 6;
    self.labelContent.text  = _model.content;
    WeakSelf;
    [self.labelContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView).offset(68);
        make.right.equalTo(weakSelf.contentView).offset(-16);
        make.bottom.equalTo(weakSelf.labelMore.mas_top).offset(-11);
    }];
    
    CGFloat picTop = 0;
    [_picContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelMore.mas_bottom).offset(picTop);
        make.left.equalTo(weakSelf.mas_left).offset(68);
    }];


    self.picContainerView.picUrlArray = _model.imgList;
    self.picContainerView.picOriArray = _model.imgList;

    CGFloat viewBottomTop = 0;
    if(_model.imgList.count){
        viewBottomTop = 15;
    }
    [_viewBottom mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.picContainerView.mas_bottom).offset(viewBottomTop).priorityLow();
    }];
}

#pragma mark - Action
#pragma mark - Gesture
- (void)onAvatar:(UITapGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if (_delegate && [_delegate respondsToSelector:@selector(onAvatarInCell:)]) {
            [_delegate onAvatarInCell:self];
        }
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
