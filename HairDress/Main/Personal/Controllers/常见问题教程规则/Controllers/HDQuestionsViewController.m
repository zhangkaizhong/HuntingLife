//
//  HDQuestionsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDQuestionsViewController.h"

#import "HDQuestionViewModel.h"
#import "HDQuestionListTableViewCell.h"
#import "HDQuestionDetailViewController.h"

@interface HDQuestionsViewController ()<navViewDelegate,HDQuestionListDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;// 导航栏
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    
    self.arrData = [NSMutableArray new];
    
    [HDQuestionViewModel getQuestionListData:^(NSDictionary * _Nonnull result) {
        if ([result[@"respCode"] integerValue] == 200) {
            [self.arrData addObjectsFromArray:result[@"data"]];
            [self.mainTableView reloadData];
        }
    }];
}

#pragma mark -- UI
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"常见问题" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDQuestionListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDQuestionListTableViewCell class])];
    }
    return _mainTableView;
}

#pragma mark -- tableView delegate datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDQuestionModel *model = self.arrData[indexPath.row];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDQuestionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDQuestionListTableViewCell class])];
    cell.model = self.arrData[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//查看更多问题
-(void)clickCheckMoreQuestionWithModel:(HDQuestionModel *)model{
    if ([model.isSelect isEqualToString:@"1"]) {
        model.isSelect = @"0";
    }else{
        model.isSelect = @"1";
    }
    [self.mainTableView reloadData];
}

//查看问题详情
-(void)clickCheckQuestionDetailWithDic:(NSDictionary *)dicQuest{
    HDQuestionDetailViewController *detailVC = [HDQuestionDetailViewController new];
    detailVC.dic = dicQuest;
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
