//
//  HDTaskDetailViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/20.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaskDetailViewController.h"

#import "HDTaskDetailDeonNumTableViewCell.h"
#import "HDMyTaskListViewController.h"

#import "HDTaskDetailInfoModel.h"

@interface HDTaskDetailViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) UIView *buttonView;
@property (nonatomic,weak) UIButton *buttonGet;
//任务详情
@property (nonatomic,strong) HDTaskDetailInfoModel *taskInfoModel;
//已完成人数
@property (nonatomic,strong) NSMutableArray *taskDoneNumArr;
@property (nonatomic,assign) NSInteger page;

@end

@implementation HDTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.buttonView];
    self.page = 1;
    self.taskDoneNumArr = [NSMutableArray new];
    [self requestTaskDetailInfo];
    
    [self setupRefresh];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//上提加载更多
-(void)loadMoreData{
    [self.mainTableView.mj_header endRefreshing];
    self.page ++;
    [self getFinishUserDataList:YES];
}

#pragma mark -- delegate / action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//领取任务
-(void)buttonGetAction{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
    }else{
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeAcceptTask headTitle:@"领取说明"  textTitle:@"1、领取任务前请仔细阅读任务说明，领取任务后在 2 小时内按任务步骤要求提交审核信息，过期无效； \n2、所有现金任务均享受超时垫付保障，任务提交后超过 72 小时未审核完成，我们将自动垫付奖励给您； \n3、会员做有会员加成的任务享受额外奖励，每笔最高30%；老板躺着享受好友每笔做任务的额外奖励，每笔最高50%" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            [self acceptTaskRequest];
        }];
    }
}

#pragma mark -- 数据请求
//任务详情
-(void)requestTaskDetailInfo{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.taskId forKey:@"id"];
    if (![HDToolHelper StringIsNullOrEmpty:[HDUserDefaultMethods getData:@"userId"]]) {
        [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"userId"];
    }
    
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryAppTaskDetail params:params successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.taskInfoModel = [HDTaskDetailInfoModel mj_objectWithKeyValues:[HDToolHelper nullDicToDic:returnData[@"data"]]];
            weakSelf.mainTableView.tableHeaderView = self.headerView;
            if ([self.taskInfoModel.acceptNum integerValue] == 0) {
                self.buttonGet.userInteractionEnabled = NO;
                self.buttonGet.backgroundColor = RGBCOLOR(230, 230, 230);
                [self.buttonGet setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
            }
            [weakSelf getFinishUserDataList:NO];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//已完成用户数据
-(void)getFinishUserDataList:(BOOL)more{
    NSDictionary *params = @{
        @"taskId":self.taskId,
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(20)
        }
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TaskQueryAppTaskFinishData params:params successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainTableView.mj_footer endRefreshing];
            }
            NSArray *arr = returnData[@"data"];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [self.taskDoneNumArr addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            if (arr.count == 0) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            if (more) {
                self.page --;
                [self.mainTableView.mj_footer endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainTableView.mj_footer endRefreshing];
        }
    } showHUD:YES];
}

//领取任务
-(void)acceptTaskRequest{
    NSDictionary *params = @{
        @"taskId":self.taskInfoModel.taskId,
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_TaskAcceptTask params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            HDMyTaskListViewController *myVC = [HDMyTaskListViewController new];
            [self.navigationController pushViewController:myVC animated:YES];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.taskDoneNumArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaskDetailDeonNumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDTaskDetailDeonNumTableViewCell class]) forIndexPath:indexPath];
    cell.dic = self.taskDoneNumArr[indexPath.row];
    return cell;
}

#pragma mark -- UI
//导航栏
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"任务详情" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        //奖励
        UILabel *lblMoeny = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 15*SCALE, 0, 12*SCALE) title:[NSString stringWithFormat:@"+%.2f",[self.taskInfoModel.taskMoney floatValue]] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(111, 111, 111) titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:YES];
        lblMoeny.height = 12*SCALE;
        [_headerView addSubview:lblMoeny];
        lblMoeny.x = _headerView.width - lblMoeny.width - 15*SCALE;
        
        UIImageView *imgMoney = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_gold"]];
        imgMoney.centerY = lblMoeny.centerY;
        imgMoney.x = lblMoeny.x - imgMoney.width - 8*SCALE;
        [_headerView addSubview:imgMoney];
        
        //任务名
        UILabel *lblTaskName = [[UILabel alloc] initWithFrame:CGRectMake(12*SCALE, 13*SCALE, imgMoney.x-24*SCALE, 14*SCALE)];
        lblTaskName.textColor = RGBTEXT;
        lblTaskName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
        lblTaskName.text = self.taskInfoModel.taskName;
        lblTaskName.numberOfLines = 0;
        [lblTaskName sizeToFit];
        if (lblTaskName.height<14*SCALE) {
            lblTaskName.height = 14*SCALE;
        }
        [_headerView addSubview:lblTaskName];
        
        //截止时间
        UILabel *lblValidTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imgMoney.bottom+20*SCALE, 0, 12*SCALE) title:[NSString stringWithFormat:@"截止时间：%@",self.taskInfoModel.validTime] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12*SCALE textAlignment:NSTextAlignmentRight isFit:NO];
        lblValidTime.numberOfLines = 0;
        [lblValidTime sizeToFit];
        if (lblValidTime.height < 12*SCALE) {
            lblValidTime.height = 12*SCALE;
        }
        lblValidTime.x = _headerView.width - 8*SCALE-lblValidTime.width;
        
        _headerView.height = lblValidTime.bottom+16;
        [_headerView addSubview:lblValidTime];
        
        //标签
        NSArray *arr = [self.taskInfoModel.taskTags componentsSeparatedByString:@","];
        if (![HDToolHelper StringIsNullOrEmpty:self.taskInfoModel.taskTags] && arr.count == 1) {
            arr = [self.taskInfoModel.taskTags componentsSeparatedByString:@"，"];
        }
        UIView *viewTags = [[UIView alloc] initWithFrame:CGRectMake(14*SCALE, lblTaskName.bottom+12*SCALE, lblValidTime.x-14*SCALE-12*SCALE, 18)];
        [_headerView addSubview:viewTags];
        if ([self.taskInfoModel.taskTags isEqualToString:@""]) {
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
        [_headerView addSubview:imgDone];
        
        UILabel *lblNumDone = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgDone.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@个",self.taskInfoModel.finishNum] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblNumDone.centerY = imgDone.centerY;
        [_headerView addSubview:lblNumDone];
        
        //剩余
        UIImageView *imgLast = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_last"]];
        imgLast.x = CGRectGetMaxX(lblNumDone.frame)+12*SCALE;
        imgLast.centerY = imgDone.centerY;
        [_headerView addSubview:imgLast];
        
        UILabel *lblLastNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgLast.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@个",self.taskInfoModel.acceptNum] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblLastNum.centerY = imgLast.centerY;
        [_headerView addSubview:lblLastNum];
        
        //审核
        UIImageView *imgAudit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_audit"]];
        imgAudit.x = CGRectGetMaxX(lblLastNum.frame)+12*SCALE;
        imgAudit.centerY = imgDone.centerY;
        [_headerView addSubview:imgAudit];
        
        UILabel *lblAudit = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgAudit.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@小时内",self.taskInfoModel.checkHour] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblAudit.centerY = imgAudit.centerY;
        [_headerView addSubview:lblAudit];
        
        //通过率
        UIImageView *imgPassRate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taskdetails_ic_passingrate"]];
        imgPassRate.x = CGRectGetMaxX(lblAudit.frame)+12*SCALE;
        imgPassRate.centerY = imgDone.centerY;
        [_headerView addSubview:imgPassRate];
        
        UILabel *lblPassRate = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imgPassRate.frame)+3, 0, 0, 14*SCALE) title:[NSString stringWithFormat:@"%@%%",self.taskInfoModel.passRate] bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(104, 104, 104) titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblPassRate.centerY = imgPassRate.centerY;
        [_headerView addSubview:lblPassRate];
        
        if (CGRectGetMaxX(lblPassRate.frame)+12*SCALE>_headerView.width) {
            imgPassRate.x = 12*SCALE;
            imgPassRate.y = imgDone.bottom+20*SCALE;
            lblPassRate.x = CGRectGetMaxX(imgPassRate.frame)+3;
            lblPassRate.centerY = imgPassRate.centerY;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(11*SCALE, imgPassRate.bottom+14*SCALE, kSCREEN_WIDTH-22*SCALE, 1)];
        line.backgroundColor = RGBCOLOR(216, 216, 216);
        [_headerView addSubview:line];
        
        //任务说明
        UILabel *lblDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(10*SCALE, line.bottom+8*SCALE, kSCREEN_WIDTH-20*SCALE, 14) title:self.taskInfoModel.taskDesc bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblDesc.numberOfLines = 0;
        [lblDesc sizeToFit];
        [_headerView addSubview:lblDesc];
        if (lblDesc.height < 14) {
            lblDesc.height = 14;
        }
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, lblDesc.bottom+11*SCALE, kSCREEN_WIDTH, 1)];
        line1.backgroundColor = RGBCOLOR(223, 223, 223);
        [_headerView addSubview:line1];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, lblDesc.bottom+11*SCALE, kSCREEN_WIDTH, 8)];
        line2.backgroundColor = RGBCOLOR(238, 243, 250);
        [_headerView addSubview:line2];
        
        //任务步骤
        UILabel *lblStepText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, line2.bottom+12*SCALE, kSCREEN_WIDTH-24, 16) title:@"任务步骤" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_headerView addSubview:lblStepText];
        
        UIView *viewStep = [[UIView alloc] initWithFrame:CGRectMake(0, lblStepText.bottom, kSCREEN_WIDTH, 100)];
        [_headerView addSubview:viewStep];
        
        if (self.taskInfoModel.taskSteps.count == 0) {
            lblStepText.height = 0;
            lblStepText.hidden = YES;
            viewStep.y = lblStepText.bottom;
            viewStep.height = 0;
        }
        
        for (int i=0; i<self.taskInfoModel.taskSteps.count; i++) {
            NSDictionary *dic = self.taskInfoModel.taskSteps[i];
            
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
                
                if (i!=self.taskInfoModel.taskSteps.count-1) {
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
                NSDictionary *dicLast = self.taskInfoModel.taskSteps[i-1];
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
            viewStep.height = viewSubStep.bottom+20*SCALE;
        }
        
        //任务步骤
        UILabel *lblDoneText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, viewStep.bottom, kSCREEN_WIDTH-24, 16) title:@"完成人数" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_headerView addSubview:lblDoneText];
        
        UILabel *lblDoneDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, lblDoneText.bottom+8, kSCREEN_WIDTH-24, 12) title:[NSString stringWithFormat:@"平均通过率%@%% 超时自动打款",self.taskInfoModel.passRate] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_headerView addSubview:lblDoneDesc];
        
        _headerView.height = lblDoneDesc.bottom+16;
    }
    return _headerView;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-NAVHIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDTaskDetailDeonNumTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDTaskDetailDeonNumTableViewCell class])];
        
    }
    return _mainTableView;
}

-(UIView *)buttonView{
    if (!_buttonView) {
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-64, kSCREEN_WIDTH, 64)];
        _buttonView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBBG;
        [_buttonView addSubview:line];
        
        UIButton *button = [[UIButton alloc] initSystemWithFrame:CGRectMake(12, 8, kSCREEN_WIDTH-24, 48) btnTitle:@"立即申请任务" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        button.backgroundColor = RGBMAIN;
        button.layer.cornerRadius = 2;
        self.buttonGet = button;
        [_buttonView addSubview:button];
        [button addTarget:self action:@selector(buttonGetAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonView;
}

@end
