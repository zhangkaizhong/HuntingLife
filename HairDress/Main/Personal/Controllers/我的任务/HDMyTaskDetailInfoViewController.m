//
//  HDTaskDetailViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDMyTaskDetailInfoViewController.h"

#import "HDTaskCompletingViewController.h"
#import "HDTaskDetailViewController.h"
#import "HDMyTaskDetailInfoModel.h"
#import "HDMyTaskListViewController.h"

@interface HDMyTaskDetailInfoViewController ()<navViewDelegate,UIScrollViewDelegate>
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}
@property (nonatomic,strong) HDBaseNavView *navView;
//头部背景图
@property (nonatomic,strong) UIImageView *imageHeadBack;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIView *buttonView;
@property (nonatomic,strong) UIView *taskInfoView;
@property (nonatomic,strong) UIView *taskInfoNewView;
@property (nonatomic,weak) UILabel *lblRetime;
@property (nonatomic,weak) UILabel *lblClickLable;
@property (nonatomic,weak) UILabel *lblClickTimeLable;
//任务详情
@property (nonatomic,strong) HDMyTaskDetailInfoModel *detailModel;
@property (nonatomic,strong) ZXLGCDTimer *timer;

@end

//倒计时总秒数
static NSInteger secondsCountDown = 0;

@implementation HDMyTaskDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    
    [self requestTaskDetailInfo];
}

#pragma mark -- delegate / action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//去提交
-(void)buttonCompleteAction:(UIGestureRecognizer *)sender{
    if ([self.lblClickLable.text isEqualToString:@"去提交"]) {
        HDTaskCompletingViewController *completeVC = [HDTaskCompletingViewController new];
        completeVC.memberTaskId = self.detailModel.memberTaskId;
        [self.navigationController pushViewController:completeVC animated:YES];
    }
    else{
        HDTaskDetailViewController *detailVC = [HDTaskDetailViewController new];
        detailVC.taskId = self.detailModel.taskInfoModel.taskId;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

//实现倒计时动作
-(void)countDownAction{
    //倒计时-1
    secondsCountDown--;
    
    if (secondsCountDown <=0) {
        self.lblRetime.text = [NSString stringWithFormat:@"剩余时间 00:00:00"];
        return;
    }

    //重新计算 时/分/秒
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",secondsCountDown/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(secondsCountDown%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",secondsCountDown%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    //修改倒计时标签及显示内容
    self.lblRetime.text = [NSString stringWithFormat:@"剩余时间 %@",format_time];
}

#pragma mark -- 数据请求
//任务详情
-(void)requestTaskDetailInfo{
    NSDictionary *params = @{
        @"id":self.memberTaskId
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryUserTaskDetail params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.detailModel = [HDMyTaskDetailInfoModel mj_objectWithKeyValues:[HDToolHelper nullDicToDic:returnData[@"data"]]];
            [self.view addSubview:weakSelf.mainScrollView];
            if ([self.detailModel.checkStatus isEqualToString:@"进行中"]) {
                [self.view addSubview:self.buttonView];
                weakSelf.mainScrollView.y = NAVHIGHT;
                weakSelf.mainScrollView.height = kSCREEN_HEIGHT-64-NAVHIGHT;
            }else if ([self.detailModel.checkStatus isEqualToString:@"审核拒绝"] || [self.detailModel.checkStatus isEqualToString:@"已超时"]){
                [self.view addSubview:self.buttonView];
                self.lblClickLable.text = @"重新领取";
                self.lblClickTimeLable.hidden = YES;
                self.lblClickLable.centerX = self.buttonView.width/2;
                weakSelf.mainScrollView.height = kSCREEN_HEIGHT-64;
            }
            
            [self.view bringSubviewToFront:weakSelf.navView];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- delegate datasource
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (![self.detailModel.checkStatus isEqualToString:@"进行中"]){
        //当前y轴偏移量
        CGFloat currentOffsetY  = scrollView.contentOffset.y;
        if (currentOffsetY <= NAVHIGHT) {//下拉，隐藏 navView
            _navView.backgroundColor = [RGBMAIN colorWithAlphaComponent:0];
            // 背景拉伸
            CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
            initialFrame.origin.y = - offsetY * 1;
            initialFrame.size.height = defaultViewHeight + offsetY;
            _imageHeadBack.frame = initialFrame;
        }else if(currentOffsetY > NAVHIGHT){//移动过程
            _navView.backgroundColor = [RGBMAIN colorWithAlphaComponent:1];
        }
//    }
}

#pragma mark -- UI
//导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"任务详情" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        _mainScrollView.delegate = self;
        
//        if ([self.detailModel.checkStatus isEqualToString:@"进行中"]){
//            [self createOldTaskInfoView];
//            //任务步骤
//            [self createViewStep:self.taskInfoView.bottom+20];
//        }
//        else{
            _navView.backgroundColor = [UIColor clearColor];
            [_mainScrollView addSubview:self.imageHeadBack];
            initialFrame       = _imageHeadBack.frame;
            defaultViewHeight  = initialFrame.size.height;
            UIButton *btnBack = [_navView viewWithTag:5000];
            [btnBack setImage:[UIImage imageNamed:@"common_ic_arrow_back_w"] forState:UIControlStateNormal];
            UILabel *lblTitle = [_navView viewWithTag:6000];
            lblTitle.textColor = [UIColor whiteColor];
            //任务详情
            [self createOldTaskInfoView];
            //任务步骤
            [self createViewStep:self.taskInfoView.bottom+20];
//        }
    }
    return _mainScrollView;
}

//新版任务详情
-(void)createViewInfoNew{
    UIView *viewInfoNew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    self.taskInfoNewView = viewInfoNew;
    [_mainScrollView addSubview:viewInfoNew];
    //奖励
    UILabel *lblMoeny = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 15*SCALE, 0, 12*SCALE) title:[NSString stringWithFormat:@"+%.2f",[self.detailModel.taskInfoModel.taskMoney floatValue]] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(111, 111, 111) titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:YES];
    lblMoeny.height = 12*SCALE;
    [viewInfoNew addSubview:lblMoeny];
    lblMoeny.x = viewInfoNew.width - lblMoeny.width - 15*SCALE;
    
    UIImageView *imgMoney = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_gold"]];
    imgMoney.centerY = lblMoeny.centerY;
    imgMoney.x = lblMoeny.x - imgMoney.width - 8*SCALE;
    [viewInfoNew addSubview:imgMoney];
    
    //任务名
    UILabel *lblTaskName = [[UILabel alloc] initWithFrame:CGRectMake(12*SCALE, 13*SCALE, imgMoney.x-24*SCALE, 14*SCALE)];
    lblTaskName.textColor = RGBTEXT;
    lblTaskName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
    lblTaskName.text = self.detailModel.taskInfoModel.taskName;
    lblTaskName.numberOfLines = 0;
    [lblTaskName sizeToFit];
    if (lblTaskName.height<14*SCALE) {
        lblTaskName.height = 14*SCALE;
    }
    [viewInfoNew addSubview:lblTaskName];
    
    //截止时间
    UILabel *lblValidTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imgMoney.bottom+20*SCALE, 0, 12*SCALE) title:[NSString stringWithFormat:@"截止时间：%@",self.detailModel.taskInfoModel.validTime] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12*SCALE textAlignment:NSTextAlignmentRight isFit:NO];
    lblValidTime.numberOfLines = 0;
    [lblValidTime sizeToFit];
    if (lblValidTime.height < 12*SCALE) {
        lblValidTime.height = 12*SCALE;
    }
    lblValidTime.x = viewInfoNew.width - 8*SCALE-lblValidTime.width;
    
    viewInfoNew.height = lblValidTime.bottom+16;
    [viewInfoNew addSubview:lblValidTime];
    
    //标签
    NSArray *arr = [self.detailModel.taskInfoModel.taskTags componentsSeparatedByString:@","];
    if (![HDToolHelper StringIsNullOrEmpty:self.detailModel.taskInfoModel.taskTags] && arr.count == 1) {
        arr = [self.detailModel.taskInfoModel.taskTags componentsSeparatedByString:@"，"];
    }
    UIView *viewTags = [[UIView alloc] initWithFrame:CGRectMake(14*SCALE, lblTaskName.bottom+12*SCALE, lblValidTime.x-14*SCALE-12*SCALE, 18)];
    [viewInfoNew addSubview:viewTags];
    if ([self.detailModel.taskInfoModel.taskTags isEqualToString:@""]) {
        viewTags.height = 20*SCALE;
    }else{
        for (int i=0; i<arr.count; i++) {
            if (![HDToolHelper StringIsNullOrEmpty:arr[i]]) {
                UILabel *lbltag = [[UILabel alloc] initCommonWithFrame:CGRectMake(i*58, 0, viewTags.width, 20*SCALE) title:arr[i] bgColor:RGBCOLOR(254, 232, 234) titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
                lbltag.layer.cornerRadius = 2;
                lbltag.numberOfLines = 0;
                [lbltag sizeToFit];
                lbltag.width = lbltag.width+5;
                if (lbltag.height<=20*SCALE) {
                    lbltag.height = 20*SCALE;
                }
                else{
                    lbltag.height = lbltag.height+5;
                }

                lbltag.tag = 100+i;
                UILabel *lbltagLast = (UILabel *)[viewTags viewWithTag:100+i-1];
                if(i==0){
                    lbltag.x = 0;
                    lbltag.y = 0;
                }else{
                    lbltag.x = CGRectGetMaxX(lbltagLast.frame)+8;
                    if (CGRectGetMaxX(lbltag.frame)>viewTags.width) {
                        lbltag.x = 0;
                        lbltag.y = CGRectGetMaxY(lbltagLast.frame)+4;
                    }else{
                        lbltag.y = lbltagLast.y;
                    }
                }
                [viewTags addSubview:lbltag];
                
                viewTags.height = lbltag.bottom;
            }
        }
    }
    
    //完成数
    UIImageView *imgDone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_finish"]];
    imgDone.x = 12*SCALE;
    imgDone.y = viewTags.bottom + 20*SCALE;
    [viewInfoNew addSubview:imgDone];
    
    UILabel *lblNumDone = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgDone.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@个",self.detailModel.taskInfoModel.finishNum] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
    lblNumDone.centerY = imgDone.centerY;
    [viewInfoNew addSubview:lblNumDone];
    
    //剩余
    UIImageView *imgLast = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_last"]];
    imgLast.x = CGRectGetMaxX(lblNumDone.frame)+12*SCALE;
    imgLast.centerY = imgDone.centerY;
    [viewInfoNew addSubview:imgLast];
    
    UILabel *lblLastNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgLast.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@个",self.detailModel.taskInfoModel.acceptNum] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
    lblLastNum.centerY = imgLast.centerY;
    [viewInfoNew addSubview:lblLastNum];
    
    //审核
    UIImageView *imgAudit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_audit"]];
    imgAudit.x = CGRectGetMaxX(lblLastNum.frame)+12*SCALE;
    imgAudit.centerY = imgDone.centerY;
    [viewInfoNew addSubview:imgAudit];
    
    UILabel *lblAudit = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgAudit.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@小时内",self.detailModel.taskInfoModel.checkHour] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
    lblAudit.centerY = imgAudit.centerY;
    [viewInfoNew addSubview:lblAudit];
    
    //通过率
    UIImageView *imgPassRate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_passingrate"]];
    imgPassRate.x = CGRectGetMaxX(lblAudit.frame)+12*SCALE;
    imgPassRate.centerY = imgDone.centerY;
    [viewInfoNew addSubview:imgPassRate];
    
    UILabel *lblPassRate = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgPassRate.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@%%",self.detailModel.taskInfoModel.passRate] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
    lblPassRate.centerY = imgPassRate.centerY;
    [viewInfoNew addSubview:lblPassRate];
    
    if (CGRectGetMaxX(lblPassRate.frame)+12*SCALE>viewInfoNew.width) {
        imgPassRate.x = 12*SCALE;
        imgPassRate.y = imgDone.bottom+20*SCALE;
        lblPassRate.x = CGRectGetMaxX(imgPassRate.frame)+3;
        lblPassRate.centerY = imgPassRate.centerY;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(11*SCALE, imgPassRate.bottom+14*SCALE, kSCREEN_WIDTH-22*SCALE, 1)];
    line.backgroundColor = RGBCOLOR(216, 216, 216);
    [viewInfoNew addSubview:line];
    
    //任务说明
    UILabel *lblDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(10*SCALE, line.bottom+8*SCALE, kSCREEN_WIDTH-20*SCALE, 14) title:self.detailModel.taskInfoModel.taskDesc bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblDesc.numberOfLines = 0;
    [lblDesc sizeToFit];
    [viewInfoNew addSubview:lblDesc];
    if (lblDesc.height < 14) {
        lblDesc.height = 14;
    }
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, lblDesc.bottom+11*SCALE, kSCREEN_WIDTH, 1)];
    line1.backgroundColor = RGBCOLOR(223, 223, 223);
    [viewInfoNew addSubview:line1];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, lblDesc.bottom+11*SCALE, kSCREEN_WIDTH, 8)];
    line2.backgroundColor = RGBCOLOR(238, 243, 250);
    [viewInfoNew addSubview:line2];
    
    self.taskInfoNewView.height = line2.bottom;
}

//旧版详情
-(void)createOldTaskInfoView{
    UIView *oldviewTaskInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    self.taskInfoView = oldviewTaskInfo;
    [_mainScrollView addSubview:oldviewTaskInfo];
    
    UIView *viewTaskInfo = [[UIView alloc] initWithFrame:CGRectMake(12, NAVHIGHT+12, kSCREEN_WIDTH-24, 148)];
    viewTaskInfo.layer.borderWidth = 1;
    viewTaskInfo.layer.borderColor = RGBCOLOR(245, 245, 245).CGColor;
    viewTaskInfo.layer.backgroundColor = [UIColor whiteColor].CGColor;
    viewTaskInfo.layer.cornerRadius = 4;
    viewTaskInfo.layer.shadowColor = RGBAlpha(0, 0, 0, 0.03).CGColor;
    viewTaskInfo.layer.shadowOffset = CGSizeMake(0,6);
    viewTaskInfo.layer.shadowOpacity = 1;
    viewTaskInfo.layer.shadowRadius = 6;
    [oldviewTaskInfo addSubview:viewTaskInfo];
    
    //任务奖励
    UIView *moneyView = [[UIView alloc] initWithFrame:CGRectMake(16, 16, 64, 64)];
    moneyView.backgroundColor = [UIColor whiteColor];
    moneyView.layer.borderWidth = 1;
    moneyView.layer.borderColor = RGBCOLOR(232, 94, 95).CGColor;
    moneyView.layer.cornerRadius = 4;
    [viewTaskInfo addSubview:moneyView];
    
    UILabel *lblMoeny = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, moneyView.width, 40) title:[NSString stringWithFormat:@"%.2f",[self.detailModel.taskInfoModel.taskMoney floatValue]] bgColor:RGBCOLOR(232, 94, 95) titleColor:[UIColor whiteColor] titleFont:21 textAlignment:NSTextAlignmentCenter isFit:NO];
    [moneyView addSubview:lblMoeny];
    lblMoeny.adjustsFontSizeToFitWidth = YES;
    CGFloat corner1 = 4;
    CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
    shapeLayer1.path = [UIBezierPath bezierPathWithRoundedRect:lblMoeny.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(corner1, corner1)].CGPath;
    lblMoeny.layer.mask = shapeLayer1;
    
    lblMoeny.layer.borderWidth = 1;
    lblMoeny.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UILabel *lblMoenyText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblMoeny.bottom, moneyView.width, moneyView.height-40) title:@"奖励 (元)" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
    [moneyView addSubview:lblMoenyText];
    
    //置顶
    UILabel *lblZhiding = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(moneyView.frame)+16, 16, 32, 18) title:@"热门" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
    lblZhiding.layer.cornerRadius = 2;
    lblZhiding.layer.masksToBounds = YES;
    [viewTaskInfo addSubview:lblZhiding];
    
    //任务名
    UILabel *lblTaskName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblZhiding.frame)+6, 16, viewTaskInfo.width-CGRectGetMaxX(lblZhiding.frame)-6-12, 16)];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.detailModel.taskInfoModel.taskName attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 16],NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]}];
    lblTaskName.attributedText = string;
    [viewTaskInfo addSubview:lblTaskName];
    
    if ([self.detailModel.taskInfoModel.topFlag isEqualToString:@"F"]) {
        lblZhiding.hidden = YES;
        lblTaskName.x = CGRectGetMaxX(moneyView.frame)+16;
        lblTaskName.width = viewTaskInfo.width-CGRectGetMaxX(moneyView.frame)-16-12;
    }
    
    //标签
    NSArray *arr = [self.detailModel.taskInfoModel.taskTags componentsSeparatedByString:@","];
    if (![HDToolHelper StringIsNullOrEmpty:self.detailModel.taskInfoModel.taskTags] && arr.count == 1) {
        arr = [self.detailModel.taskInfoModel.taskTags componentsSeparatedByString:@"，"];
    }
    UIView *viewTags = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moneyView.frame)+16, lblTaskName.bottom+8, viewTaskInfo.width-CGRectGetMaxX(moneyView.frame)-32, 18)];
    [viewTaskInfo addSubview:viewTags];
    if ([self.detailModel.taskInfoModel.taskTags isEqualToString:@""]) {
        viewTags.height = 18;
    }else{
        for (int i=0; i<arr.count; i++) {
            if (![HDToolHelper StringIsNullOrEmpty:arr[i]]) {
                UILabel *lbltag = [[UILabel alloc] initCommonWithFrame:CGRectMake(i*58, 0, viewTags.width, 18) title:arr[i] bgColor:RGBCOLOR(254, 232, 234) titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
                lbltag.layer.cornerRadius = 2;
                lbltag.numberOfLines = 0;
                [lbltag sizeToFit];
                lbltag.width = lbltag.width+5;
                if (lbltag.height<=18) {
                    lbltag.height = 18;
                }
                else{
                    lbltag.height = lbltag.height+5;
                }

                lbltag.tag = 100+i;
                UILabel *lbltagLast = (UILabel *)[viewTags viewWithTag:100+i-1];
                if(i==0){
                    lbltag.x = 0;
                    lbltag.y = 0;
                }else{
                    lbltag.x = CGRectGetMaxX(lbltagLast.frame)+8;
                    if (CGRectGetMaxX(lbltag.frame)>viewTags.width) {
                        lbltag.x = 0;
                        lbltag.y = CGRectGetMaxY(lbltagLast.frame)+4;
                    }else{
                        lbltag.y = lbltagLast.y;
                    }
                }
                [viewTags addSubview:lbltag];
                
                viewTags.height = lbltag.bottom;
            }
        }
    }
    
    //完成数
    UILabel *lblNumDone = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(moneyView.frame)+16, viewTags.bottom+7, viewTaskInfo.width-CGRectGetMaxX(moneyView.frame)-28, 12) title:[NSString stringWithFormat:@"%@人完成·平均通过率%@%%",self.detailModel.taskInfoModel.finishNum,self.detailModel.taskInfoModel.passRate] bgColor:[UIColor whiteColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewTaskInfo addSubview:lblNumDone];
    
    CGFloat bottomY = lblNumDone.bottom > moneyView.bottom ? lblNumDone.bottom : moneyView.bottom;
    //任务状态
    UILabel *lblCheckStatus = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, bottomY+16, viewTaskInfo.width/2-16, 14) title:@"" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewTaskInfo addSubview:lblCheckStatus];
    lblCheckStatus.attributedText = [[NSString alloc] setCustomAttrText:[NSString stringWithFormat:@"任务状态：%@",self.detailModel.checkStatus] textColor:RGBTEXTINFO setBeginIndex:0  setLongth:5 setColor:RGBTEXT textFont:14];
    [lblCheckStatus sizeToFit];
    
    //更新时间
    UILabel *lblUpdateTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblCheckStatus.bottom+8, viewTaskInfo.width-32, 14) title:[NSString stringWithFormat:@"更新时间：%@",self.detailModel.updateTime] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    self.lblRetime = lblUpdateTime;
    if ([self.detailModel.checkStatus isEqualToString:@"进行中"]) {
        secondsCountDown = [self.detailModel.invalidSecond integerValue];
        //设置定时器
        if (!self.timer) {
            self.timer = [[ZXLGCDTimer alloc] initWithTimeInterval:1 target:self selector:@selector(countDownAction) parameter:0];
        }
        //重新计算 时/分/秒
        NSString *str_hour = [NSString stringWithFormat:@"%02ld",secondsCountDown/3600];
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(secondsCountDown%3600)/60];
        NSString *str_second = [NSString stringWithFormat:@"%02ld",secondsCountDown%60];
        NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
        self.lblRetime.text = [NSString stringWithFormat:@"剩余时间：%@",format_time];
        
        lblCheckStatus.attributedText = [[NSString alloc] setCustomAttrText:[NSString stringWithFormat:@"任务状态：%@",self.detailModel.checkStatus] textColor:RGBCOLOR(255, 194, 63) setBeginIndex:0  setLongth:5 setColor:RGBTEXT textFont:14];
    }else if ([self.detailModel.checkStatus isEqualToString:@"审核中"]) {
        
        //修改倒计时标签及显示内容
        self.lblRetime.text = [NSString stringWithFormat:@"提交时间：%@",self.detailModel.updateTime];
        
        lblCheckStatus.attributedText = [[NSString alloc] setCustomAttrText:[NSString stringWithFormat:@"任务状态：%@",self.detailModel.checkStatus] textColor:RGBMAIN setBeginIndex:0  setLongth:5 setColor:RGBTEXT textFont:14];
    }
    [viewTaskInfo addSubview:lblUpdateTime];
    
    //原因
    if ([self.detailModel.checkStatus isEqualToString:@"已超时"]){
        self.detailModel.checkDesc = @"订单已超时";
    }
    UILabel *lblReason = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblCheckStatus.x, lblUpdateTime.bottom+8, viewTaskInfo.width-24, 14) title:[NSString stringWithFormat:@"原因：%@",self.detailModel.checkDesc] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
    lblReason.numberOfLines = 0;
    [lblReason sizeToFit];
    if (lblReason.height < 14) {
        lblReason.height = 14;
    }
    [viewTaskInfo addSubview:lblReason];
    
    if ([self.detailModel.checkStatus isEqualToString:@"进行中"] || [self.detailModel.checkStatus isEqualToString:@"审核通过"] || [self.detailModel.checkStatus isEqualToString:@"审核中"]) {
        lblReason.hidden = YES;
        viewTaskInfo.height = lblUpdateTime.bottom + 16;
    }
    else{
        lblReason.hidden = NO;
        viewTaskInfo.height = lblReason.bottom + 16;
    }
    
    //任务说明
    UILabel *lblDescText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, viewTaskInfo.bottom+20, kSCREEN_WIDTH-24, 16) title:@"任务说明" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
    [oldviewTaskInfo addSubview:lblDescText];
    
    UILabel *lblDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, lblDescText.bottom+12, kSCREEN_WIDTH-24, 14) title:self.detailModel.taskInfoModel.taskDesc bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    lblDesc.numberOfLines = 0;
    [lblDesc sizeToFit];
    [oldviewTaskInfo addSubview:lblDesc];
    if (lblDesc.height < 14) {
        lblDesc.height = 14;
    }
    
    self.taskInfoView.height = lblDesc.bottom;
}

//任务步骤
-(void)createViewStep:(CGFloat)y{
    UILabel *lblStepText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, y, kSCREEN_WIDTH-24, 16) title:@"任务步骤" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
    [_mainScrollView addSubview:lblStepText];
    UIView *viewStep = [[UIView alloc] initWithFrame:CGRectMake(0, lblStepText.bottom, kSCREEN_WIDTH, 100)];
    [_mainScrollView addSubview:viewStep];
    
    if (self.detailModel.taskInfoModel.taskSteps.count == 0) {
        lblStepText.height = 0;
        lblStepText.hidden = YES;
        viewStep.y = lblStepText.bottom;
        viewStep.height = 0;
    }
    
    for (int i=0; i<self.detailModel.taskInfoModel.taskSteps.count; i++) {
        NSDictionary *dic = self.detailModel.taskInfoModel.taskSteps[i];
        
        UIView *viewSubStep = [[UIView alloc] initWithFrame:CGRectMake(0, i*100, kSCREEN_WIDTH, 100)];
        viewSubStep.tag = 100+i;
        
        UIImageView *imageStep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"step_bg"]];
        imageStep.x = 12;
        imageStep.y = 13;
        [viewSubStep addSubview:imageStep];
    
        UILabel *lblStep = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, imageStep.width, imageStep.height) title:[NSString stringWithFormat:@"第%@步",[HDToolHelper translationArabicNum:[dic[@"sortNum"] integerValue]]] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [imageStep addSubview:lblStep];
        
        UIView *viewPod = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageStep.frame)+8, 0, 8, 8)];
        viewPod.centerY = imageStep.centerY;
        viewPod.layer.cornerRadius = 4;
        viewPod.backgroundColor = RGBMAIN;
        [viewSubStep addSubview:viewPod];
        
        UILabel *lblStepDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(viewPod.frame)+8, 12, kSCREEN_WIDTH-CGRectGetMaxX(viewPod.frame)-8-12, 20) title:dic[@"stepDesc"] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblStepDesc.numberOfLines = 0;
        [lblStepDesc sizeToFit];
        if (lblStepDesc.height < 20) {
            lblStepDesc.height = 20;
        }
        [viewSubStep addSubview:lblStepDesc];
        
        viewSubStep.height = lblStepDesc.bottom+20;
        
        //是否有图片
        if (![HDToolHelper StringIsNullOrEmpty:dic[@"stepImg"]]) {
            UIImage *img = [HDToolHelper getImageFromURL:dic[@"stepImg"]];
            UIImageView *imageTask = [[UIImageView alloc] initWithFrame:CGRectMake(lblStepDesc.x, lblStepDesc.bottom+9, img.size.width, img.size.height)];
            if (img.size.width > (kSCREEN_WIDTH-lblStepDesc.x-16)) {
                imageTask.width = kSCREEN_WIDTH-lblStepDesc.x-16;
                imageTask.height = kSCREEN_WIDTH-lblStepDesc.x-16;
            }
            imageTask.image = img;
            imageTask.contentMode = 2;
            imageTask.layer.masksToBounds = YES;
            [viewSubStep addSubview:imageTask];
            viewSubStep.height = imageTask.bottom+4;
            
            if (i!=self.detailModel.taskInfoModel.taskSteps.count-1) {
                UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, viewSubStep.height-viewPod.centerY-4)];
                viewLine.centerX = viewPod.centerX;
                viewLine.y = viewPod.centerY+4;
                viewLine.backgroundColor = RGBCOLOR(224, 224, 224);
                [viewSubStep addSubview:viewLine];
            }
        }
        
        if (i==0) {
            viewSubStep.y = 0;
        }else{
            NSDictionary *dicLast = self.detailModel.taskInfoModel.taskSteps[i-1];
            if (![HDToolHelper StringIsNullOrEmpty:dicLast[@"stepImg"]]){
                UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, viewPod.centerY-4)];
                viewLine.centerX = viewPod.centerX;
                viewLine.backgroundColor = RGBCOLOR(224, 224, 224);
                [viewSubStep addSubview:viewLine];
            }
            
            UIView *viewLast = (UIView *)[viewStep viewWithTag:100+i-1];
            viewSubStep.y = viewLast.bottom;
        }
        
        [viewStep addSubview:viewSubStep];
        viewStep.height = viewSubStep.bottom;
    }
    
    _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, viewStep.bottom+16);
}

-(UIImageView *)imageHeadBack{
    if (!_imageHeadBack) {
        _imageHeadBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 156)];
        _imageHeadBack.image = [UIImage imageNamed:@"task_nav_bg"];
    }
    return _imageHeadBack;
}

-(UIView *)buttonView{
    if (!_buttonView) {
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-64, kSCREEN_WIDTH, 64)];
        _buttonView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBBG;
        [_buttonView addSubview:line];
        
        UIView *viewBack = [[UIView alloc] initWithFrame:CGRectMake(12, 8, kSCREEN_WIDTH-24, 48)];
        viewBack.backgroundColor = RGBMAIN;
        viewBack.layer.cornerRadius = 2;
        [_buttonView addSubview:viewBack];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonCompleteAction:)];
        viewBack.userInteractionEnabled = YES;
        [viewBack addGestureRecognizer:tap];
        
        UILabel *lbl1 = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 100, 16) title:@"去提交" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        self.lblClickLable = lbl1;
        self.lblClickLable.centerY = viewBack.height/2;
        self.lblClickLable.centerX = viewBack.width/2;
        [viewBack addSubview:self.lblClickLable];
        
//        UILabel *lbl2 = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lbl1.frame)+15, 14, 100, 19) title:@"剩余59分钟" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(216, 216, 216) titleFont:9*SCALE textAlignment:NSTextAlignmentCenter isFit:YES];
//        self.lblClickTimeLable = lbl2;
//        [viewBack addSubview:self.lblClickTimeLable];
//        self.lblClickTimeLable.layer.borderWidth = 1;
//        self.lblClickTimeLable.layer.borderColor = RGBCOLOR(216, 216, 216).CGColor;
//        self.lblClickTimeLable.layer.cornerRadius = 2;
//
//        NSString *str_hour = [NSString stringWithFormat:@"%02ld",[self.detailModel.invalidSecond integerValue]/3600];
//        NSString *str_minute = [NSString stringWithFormat:@"%02ld",([self.detailModel.invalidSecond integerValue]%3600)/60];
//        if ([str_hour intValue] > 0) {
//            self.lblClickTimeLable.text = [NSString stringWithFormat:@"剩余%@小时%@分钟",str_hour,str_minute];
//        }else{
//            self.lblClickTimeLable.text = [NSString stringWithFormat:@"剩余%@分钟",str_minute];
//        }
//        [self.lblClickTimeLable sizeToFit];
//        self.lblClickTimeLable.width = self.lblClickTimeLable.width + 10;
//        self.lblClickTimeLable.height = 19*SCALE;
        
    }
    return _buttonView;
}

@end
