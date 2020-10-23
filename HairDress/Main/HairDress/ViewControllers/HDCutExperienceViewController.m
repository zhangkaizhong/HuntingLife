//
//  HDCutExperienceViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/24.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCutExperienceViewController.h"

#import "HDCutterExperienceTableViewCell.h"

#define Cell_ID @"CellForWork"

@interface HDCutExperienceViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * mainTableView;  // 主视图
@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDCutExperienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    self.arrData = [NSMutableArray new];
    
    [self initUI];
    
    [self getExpListRequest];
}

#pragma mark ================== 获取剪发经验列表数据=====================
-(void)getExpListRequest{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(1),
                @"pageSize":@(1000)
        },
        @"tonyId":self.tonyId,
    };
    [MHNetworkManager postReqeustWithURL:URL_TonyExpManageList params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arr = [HDCutterResumeExpModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark ================== 加载视图 =====================
- (void)initUI{

    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-49-KTarbarHeight-16) style:UITableViewStylePlain];
    self.mainTableView.delegate   = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView registerClass:[HDCutterExperienceTableViewCell class] forCellReuseIdentifier:Cell_ID];
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellheader"];
}

#pragma mark ==================table delegate =====================

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        return 24+28+1;
    }
    return 32+10+38;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellheader" forIndexPath:indexPath];
        UILabel *lblYears = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 24, 131, 28) title:self.workLife bgColor:RGBCOLOR(25, 24, 29) titleColor:[UIColor whiteColor] titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
        lblYears.layer.cornerRadius = 4;
        lblYears.layer.masksToBounds = YES;
        [cell.contentView addSubview:lblYears];
        return cell;
    }
    
    HDCutterExperienceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_ID forIndexPath:indexPath];
    cell.model = self.arrData[indexPath.row-1];
    return cell;
}



@end
