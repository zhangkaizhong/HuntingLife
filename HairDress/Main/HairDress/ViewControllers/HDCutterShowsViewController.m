//
//  HDCutterShowsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/24.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCutterShowsViewController.h"

#import "HDCutterShowsTableViewCell.h"
#import "HDCutterWorkShowsModel.h"
#import "SDPhotoBrowser.h"

@interface HDCutterShowsViewController ()<UITableViewDelegate,UITableViewDataSource,SDPhotoBrowserDelegate,HDCutterShowsImageDelegate>

@property (nonatomic,assign)NSInteger page;
@property (nonatomic,strong)UITableView *mainTableView;
@property (nonatomic,strong)NSMutableArray *arrData;
@property (nonatomic,strong)UICollectionView *cellCollectView;
@property (nonatomic,weak)UIImageView *scaleImage;
@property (nonatomic,copy)NSString *scaleImageUrl;

@end

@implementation HDCutterShowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.arrData = [NSMutableArray new];
    [self setupUI];
    
    [self setupRefresh];
    
    [self getWorksShowListRequest:NO];
}

-(void)setupUI{
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.mainTableView];
}

//查看大图
-(void)clickShowBigImage:(NSInteger)indexCount currentView:(UIImageView *)img{
    self.scaleImage = img;
    HDCutterWorkShowsModel *model = self.arrData[indexCount];
    self.scaleImageUrl = model.imgUrl;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = indexCount;
    browser.sourceImagesContainerView = self.cellCollectView;
    browser.imageCount = self.arrData.count;
    browser.delegate = self;
    browser.isNotScroll = YES;
    [browser show];
}

#pragma mark - SDPhotoBrowserDelegate
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:self.scaleImageUrl];
}
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    return self.scaleImage.image;
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//上提加载更多
-(void)loadMoreData{
    self.page ++;
    [self getWorksShowListRequest:YES];
}

#pragma mark ================== 获取作品集列表 =====================
-(void)getWorksShowListRequest:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(10)
        },
        @"tonyId":self.tonyId,
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TonyWorkShowsManageList params:params successBlock:^(NSDictionary *returnData) {
        
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            if (more) {
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.arrData removeAllObjects];
                [self.mainTableView.mj_header endRefreshing];
            }
            NSArray *arr = [HDCutterWorkShowsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (more && arr.count == 0) {
                weakSelf.page --;
            }
            [self.arrData addObjectsFromArray:arr];
            [self.mainTableView reloadData];
            if (arr.count == 0) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            if (more) {
                self.page --;
                [self.mainTableView.mj_footer endRefreshing];
            }else{
                [self.mainTableView.mj_header endRefreshing];
            }
        }
    } failureBlock:^(NSError *error) {
        if (more) {
            self.page --;
            [self.mainTableView.mj_footer endRefreshing];
        }else{
            [self.mainTableView.mj_header endRefreshing];
        }
    } showHUD:NO];
}

#pragma mark -- 加载控件
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48-KTarbarHeight-16) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_mainTableView registerClass:[HDCutterShowsTableViewCell class] forCellReuseIdentifier:@"cellid"];
    }
    return _mainTableView;
}

#pragma mark -- delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterShowsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    self.cellCollectView = cell.collectView;
    cell.arrData = self.arrData;
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kSCREEN_HEIGHT-NAVHIGHT-49-KTarbarHeight-8;
}

@end
