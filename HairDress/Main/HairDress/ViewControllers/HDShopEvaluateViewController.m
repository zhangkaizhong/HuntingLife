//
//  HDSearchShopsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDShopEvaluateViewController.h"

#import "HDServiceEvaTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HDEvaluateModel.h"
#import "HDShopEditChooseModel.h"

#define Cell_ID @"CellForShopEvaluate"

@interface HDShopEvaluateViewController ()<UITableViewDelegate,UITableViewDataSource>

//页码
@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) NSMutableArray *arrMenu;

@property (nonatomic,strong) UIView *viewHeader;

@property (nonatomic,copy) NSString *configValue;

@end

@implementation HDShopEvaluateViewController


- (void)viewDidLoad{
    [super viewDidLoad];
      
    self.page = 1;
    self.configValue = @"";
    self.arrMenu = [NSMutableArray new];
    
    [self initUI];
    
    //刷新控件
    [self setupRefresh];
    
    //获取评价标签
    [self getEvaLabelsRequest];
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//上提加载更多
-(void)loadMoreData{
    self.page ++;
    [self getEvaListRequest:YES];
}

#pragma mark ================== 请求数据 =====================
//获取评价列表数据
-(void)getEvaListRequest:(BOOL)more{
    NSDictionary *params = @{
        @"storeId": self.shop_id,
        @"page":@{@"pageIndex":@(self.page),@"pageSize":@"10"},
        @"configValue":self.configValue
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_EvaluateList params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        returnData = [HDToolHelper nullDicToDic:returnData];
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (!more) {
                [self.dataArray removeAllObjects];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            NSArray *arr = [HDEvaluateModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [self.dataArray addObjectsFromArray:arr];
            [self.tableView reloadData];
            
//            if (self.dataArray.count == 0) {
//                [self.tableView addSubview:self.viewEmpty];
//                self.viewEmpty.y = self.viewHeader.height + 48;
//                self.viewEmpty.hidden = NO;
//            }else{
//                self.viewEmpty.hidden = YES;
//            }
            
            if (arr.count == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            if (more) {
                self.page --;
                [self.tableView.mj_footer endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.tableView.mj_footer endRefreshing];
        }
    } showHUD:YES];
}

#pragma mark -- 请求评价类型数据
-(void)getEvaLabelsRequest{
    [MHNetworkManager postReqeustWithURL:URL_CountStoreEvaluate params:@{@"storeId":self.shop_id} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if([returnData[@"respCode"] integerValue] == 200){
            if ([returnData[@"data"] isKindOfClass:[NSArray class]]) {
                
                [self.arrMenu addObjectsFromArray:returnData[@"data"]];
                
                self.tableView.tableHeaderView = [self createHeader];
                
                //获取评价列表
                NSDictionary *dic = self.arrMenu[0];
                self.configValue = dic[@"configValue"];
                [self getEvaListRequest:NO];
            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 创建视图UI =====================
- (void)initUI{

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-49) style:UITableViewStyleGrouped];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGBBG;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[HDServiceEvaTableViewCell class] forCellReuseIdentifier:Cell_ID];
    self.tableView.tableHeaderView = [self createHeader];
}

// 头部视图
-(UIView *)createHeader{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    self.viewHeader = headView;
    headView.backgroundColor = [UIColor whiteColor];
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 1)];
    line1.backgroundColor = RGBLINE;
    [headView addSubview:line1];
    
    for (int i =0 ; i<self.arrMenu.count; i++) {
        NSDictionary *dic = self.arrMenu[i];
        UILabel *lblMenu = [[UILabel alloc] init];
        lblMenu.width = 50;
        lblMenu.text = [NSString stringWithFormat:@"%@(%ld)",dic[@"configName"],(long)[dic[@"count"] integerValue]];
        lblMenu.backgroundColor = [UIColor whiteColor];
        lblMenu.textColor = RGBMAIN;
        lblMenu.layer.cornerRadius = 4;
        lblMenu.layer.masksToBounds = YES;
        lblMenu.layer.borderColor = [RGBMAIN colorWithAlphaComponent:0.3].CGColor;
        lblMenu.layer.borderWidth = 1;
        [lblMenu sizeToFit];
        lblMenu.font = [UIFont systemFontOfSize:12];
        lblMenu.textAlignment = NSTextAlignmentCenter;
        
        UILabel *lblLast = (UILabel *)[headView viewWithTag:100+i-1];
        
//        lblMenu.width = lblMenu.width + 12;
        lblMenu.height = 24;
        
        lblMenu.tag = 100+i;
        
        // 添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        lblMenu.userInteractionEnabled = YES;
        [lblMenu addGestureRecognizer:tap];
        
        if (i == 0) {
            lblMenu.backgroundColor = RGBMAIN;
            lblMenu.textColor = [UIColor whiteColor];
            lblMenu.x = 16;
            lblMenu.y = 16;
        }else{
            lblMenu.x = CGRectGetMaxX(lblLast.frame)+16;
            if (CGRectGetMaxX(lblMenu.frame)+16 > kSCREEN_WIDTH) {
                lblMenu.x = 16;
                lblMenu.y = CGRectGetMaxY(lblLast.frame)+12;
            }else{
                lblMenu.y = lblLast.y;
            }
        }
        
        [headView addSubview:lblMenu];
        headView.height = lblMenu.bottom+16;
    }
    UIView *viewNew = [[UIView alloc] initWithFrame:CGRectMake(0, headView.bottom, kSCREEN_WIDTH, 38)];
    viewNew.backgroundColor = RGBBG;
    [headView addSubview:viewNew];
    
    //最新评价
    UILabel *lblnew = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 14) title:@"最新评价" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewNew addSubview:lblnew];
    
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, viewNew.bottom, kSCREEN_WIDTH, 1)];
    line2.backgroundColor = RGBLINE;
    [headView addSubview:line2];
    
    headView.height = line2.bottom;
    
    return headView;
}

// 评价类型s点击手势
-(void)tapAction:(UIGestureRecognizer *)sender{
    for (int i =0; i<self.arrMenu.count; i++) {
        UILabel *lbl = (UILabel *)[self.viewHeader viewWithTag:100 + i];
        lbl.backgroundColor = [UIColor whiteColor];
        lbl.textColor = RGBMAIN;
    }
    UILabel *lbl = (UILabel *)[self.viewHeader viewWithTag:sender.view.tag];
    lbl.backgroundColor = RGBMAIN;
    lbl.textColor = [UIColor whiteColor];
    
    NSDictionary *dic = self.arrMenu[sender.view.tag-100];
    self.configValue = dic[@"configValue"];
    [self getEvaListRequest:NO];
}


#pragma mark - Lazy Load
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_ID];;
    
    HDEvaluateModel *model  = self.dataArray[indexPath.row];
    
    HDServiceEvaTableViewCell  *cell1 = nil;
    cell1 = (HDServiceEvaTableViewCell *)cell;
    cell1.model = model;
    return cell1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.tableView fd_heightForCellWithIdentifier:Cell_ID configuration:^(HDServiceEvaTableViewCell *cell) {
        [self configureOriCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureOriCell:(HDServiceEvaTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    if (indexPath.row < _dataArray.count) {
        cell.model = _dataArray[indexPath.row];
    }  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%ld",(long)indexPath.item);
}



@end
