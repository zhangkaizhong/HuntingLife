//
//  HDMyBankCardsViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/30.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyBankCardsViewController.h"

#import "HDMyBankCardsTableViewCell.h"
#import "HDMyBankCardInfoEditViewController.h"

@interface HDMyBankCardsViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UITableView *mainTableView;

@end

@implementation HDMyBankCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    
}

#pragma mark -- delegate / action

- (void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 添加银行卡
-(void)tapAddCardAction:(UIGestureRecognizer *)sender{
    HDMyBankCardInfoEditViewController *cardVC = [HDMyBankCardInfoEditViewController new];
    [self.navigationController pushViewController:cardVC animated:YES];
}

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDMyBankCardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDMyBankCardsTableViewCell class]) forIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 116;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 55)];
    viewFooter.backgroundColor = [UIColor whiteColor];
    
    UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-24-32, 14) title:@"添加银行卡" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewFooter addSubview:lbl];
    lbl.centerY = viewFooter.height/2;
    
    UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
    imageGo.centerY = lbl.centerY;
    imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
    [viewFooter addSubview:imageGo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddCardAction:)];
    viewFooter.userInteractionEnabled = YES;
    [viewFooter addGestureRecognizer:tap];
    
    return viewFooter;
}

#pragma mark ================== 加载视图 =====================

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDMyBankCardsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDMyBankCardsTableViewCell class])];
    }
    return _mainTableView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的银行卡" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
