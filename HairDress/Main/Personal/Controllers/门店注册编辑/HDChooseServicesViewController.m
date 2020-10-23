//
//  HDChooseServicesViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/28.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDChooseServicesViewController.h"

#import "HDShopEditChooseTableCell.h"

@interface HDChooseServicesViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *arrData;

@property (nonatomic,strong) UIButton *btnDone;// 确认

@end

@implementation HDChooseServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrData = [NSMutableArray new];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    
    
    if (self.singleChoose) {
        self.mainTableView.height = kSCREEN_HEIGHT-NAVHIGHT;
    }else{
        self.mainTableView.height = kSCREEN_HEIGHT-NAVHIGHT-48-40-32;
        [self.view addSubview:self.btnDone];
    }
    
    [self getConfigData];
}

#pragma mark -- delegate / action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 确认
-(void)editDoneAction{
    NSMutableArray *arr = [NSMutableArray new];
    for (HDShopEditChooseModel *model in self.arrData) {
        if ([model.select isEqualToString:@"1"]) {
            [arr addObject:model];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseConfigList:configs:)]) {
        [self.delegate chooseConfigList:self.chooseType configs:arr];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ================== 请求数据 =====================
-(void)getConfigData{
    [MHNetworkManager postReqeustWithURL:URL_ConfigList params:@{@"configType":self.chooseType} successBlock:^(NSDictionary *returnData) {
        NSLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arr = [HDShopEditChooseModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            for (HDShopEditChooseModel *model in arr) {
                model.select = @"0";
                for (HDShopEditChooseModel *modelsel in self.arrSelects) {
                    if ([modelsel.configValue isEqualToString:model.configValue]) {
                        model.select = @"1";
                    }
                }
                [self.arrData addObject:model];
            }
            [self.mainTableView reloadData];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {

    } showHUD:NO];
}

#pragma mark -- tableView delegate datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopEditChooseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDShopEditChooseTableCell class]) forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.item];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HDShopEditChooseModel *model = self.arrData[indexPath.row];
    if (self.singleChoose) {
        NSMutableArray *arr = [NSMutableArray new];
        [arr addObject:model];
        if (self.delegate && [self.delegate respondsToSelector:@selector(chooseConfigList:configs:)]) {
            [self.delegate chooseConfigList:self.chooseType configs:arr];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        if ([model.select isEqualToString:@"1"]) {
            model.select = @"0";
        }else{
            model.select = @"1";
        }
        [self.mainTableView reloadData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

#pragma mark -- 加载控件

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48-40-32) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDShopEditChooseTableCell class] forCellReuseIdentifier:NSStringFromClass([HDShopEditChooseTableCell class])];
    }
    return _mainTableView;
}

-(UIButton *)btnDone{
    if (!_btnDone) {
        _btnDone = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"确认" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _btnDone.layer.cornerRadius = 24;
        _btnDone.backgroundColor = RGBMAIN;
        
        [_btnDone addTarget:self action:@selector(editDoneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDone;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        NSString *title = @"营业周期";
        if ([self.chooseType isEqualToString:@"service_standard"]) {
            title = @"服务标准";
        }else if ([self.chooseType isEqualToString:@"tehui"]) {
            title = @"特惠活动";
        }
        
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:title bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

@end
