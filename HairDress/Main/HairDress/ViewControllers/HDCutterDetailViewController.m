//
//  PersonalCenterViewController.m
//  
//
//  Created by hyw on 2018/11/14.
//  Copyright © 2018年 bksx. All rights reserved.
//

#import "HDCutterDetailViewController.h"
#import "CenterTouchTableView.h"

#import "HDCutterDetailModel.h"
#import <SDCycleScrollView.h>

#import "HDServiceEvaluateViewController.h"
#import "HDCutExperienceViewController.h"
#import "HDCutterShowsViewController.h"
#import "HDGetCutNumberViewController.h"

#import "YWPageHeadView.h"

#import "ZJSegmentStyle.h"
#import "ZJScrollPageView.h"

@interface HDCutterDetailViewController () <navViewDelegate,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,SDCycleScrollViewDelegate>
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}
@property (nonatomic,strong) UIView *navView;
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UIButton *collectBtn;//收藏按钮
@property (nonatomic,strong) UILabel *titleLbl;//标题

@property (nonatomic, strong) CenterTouchTableView *mainTableView;

@property (nonatomic,strong) HDCutterDetailModel *detailModel;

@property (nonatomic, strong) ZJScrollPageView *segmentView;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@property (nonatomic, assign) BOOL canScroll;//mainTableView是否可以滚动
@property (nonatomic, assign) BOOL isBacking;//是否正在pop

@property (nonatomic, copy) NSString *isCollect;//是否收藏

//空白view，可以加空间
@property (nonatomic, strong) UIView *tabHeadView;
//头部总高度
@property (nonatomic, assign) CGFloat offHeight;

@property (nonatomic,strong) UIView * viewGetNo;  // 取号视图

@property (nonatomic,strong) YWPageHeadView *pageHeadView;
@end


@implementation HDCutterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navView];
    [self getCutterDetail];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //注册允许外层tableView滚动通知-解决和分页视图的上下滑动冲突问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
    //分页的scrollView左右滑动的时候禁止mainTableView滑动，停止滑动的时候允许mainTableView滑动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"IsEnablePersonalCenterVCMainTableViewScroll" object:nil];
    
    //这三个高度必须先算出来，建议请求完数据知道高度以后再调用下面代码
    self.offHeight = 151 + 375;
}

#pragma mark - createUI
- (void)setupSubViews {
    self.mainTableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.tableHeaderView = self.pageHeadView;
    
    [self.pageHeadView addSubview:self.cycleScrollView];
    [self.pageHeadView addSubview:self.tabHeadView];
    
    self.pageHeadView.parentScrollView = self.mainTableView;
//    self.pageHeadView.chidlScrollView = self.cycleScrollView.mainView;
    
    [self.view addSubview:self.viewGetNo];
    
    //记录初始值
    initialFrame       = _cycleScrollView.frame;
    defaultViewHeight  = initialFrame.size.height;
    
    self.pageHeadView.height = self.offHeight;
}

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isBacking = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PersonalCenterVCBackingStatus" object:nil userInfo:@{@"isBacking":@(self.isBacking)}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isBacking = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PersonalCenterVCBackingStatus" object:nil userInfo:@{@"isBacking":@(self.isBacking)}];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//接收是否滚动通知
- (void)acceptMsg:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if ([notification.name isEqualToString:@"leaveTop"]) {
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    } else if ([notification.name isEqualToString:@"IsEnablePersonalCenterVCMainTableViewScroll"]) {
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.mainTableView.scrollEnabled = YES;
        } else if([canScroll isEqualToString:@"0"]) {
            self.mainTableView.scrollEnabled = NO;
        }
    }
}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if ([text.userInfo[@"netType"] integerValue] != 0) {
        if (self.detailModel==nil) {
            [self getCutterDetail];
        }
    }
}

#pragma mark -- 获取发型师详情
-(void)getCutterDetail{
    [MHNetworkManager postReqeustWithURL:URL_TonyDetail params:@{@"tonyId":self.cutter_id} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.detailModel = [HDCutterDetailModel mj_objectWithKeyValues:[HDToolHelper nullDicToDic:returnData[@"data"]]];
            [self setupSubViews];
            [self.view bringSubviewToFront:self.backBtn];
            [self.view bringSubviewToFront:self.collectBtn];
            
            //查询是否已收藏
            [self checkCollectRequest];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- 获取tony是否已收藏
-(void)checkCollectRequest{
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        return;
    }
    NSDictionary *params = @{
        @"collectId":self.cutter_id,
        @"collectType":@"tony",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_CollectCheckCollect params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        //是否收藏
        if ([returnData[@"respCode"] integerValue] == 200) {
            if ([returnData[@"data"] isEqualToString:@"F"]) {
                self.isCollect = @"0";
                [self.collectBtn setImage:[UIImage imageNamed:@"details_ic_favorite"] forState:UIControlStateNormal];
            }else{
                self.isCollect = @"1";
                [self.collectBtn setImage:[UIImage imageNamed:@"details_ic_favorite_selected"] forState:UIControlStateNormal];
            }
        }else{
            self.isCollect = @"0";
            [self.collectBtn setImage:[UIImage imageNamed:@"details_ic_favorite"] forState:UIControlStateNormal];
        }
        
    } failureBlock:^(NSError *error) {
            
    } showHUD:NO];
}

//发送店铺收藏请求
-(void)collectTonyRequest{
    NSDictionary *params = @{
        @"collectId":self.cutter_id,
        @"collectType":@"tony",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_CollectStoreOrTony params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.isCollect = @"1";
            [self.collectBtn setImage:[UIImage imageNamed:@"details_ic_favorite_selected"] forState:UIControlStateNormal];
            [SVHUDHelper showSuccessDoneMsg:@"收藏成功"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickCollectActionRefreshList)]) {
                [self.delegate clickCollectActionRefreshList];
            }
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//取消收藏请求
-(void)cancelCollectTonyRequest{
    NSDictionary *params = @{
        @"ids":@[self.cutter_id],
        @"collectType":@"tony",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_CollectDelCollect params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.isCollect = @"0";
            [self.collectBtn setImage:[UIImage imageNamed:@"details_ic_favorite"] forState:UIControlStateNormal];
            [SVHUDHelper showSuccessDoneMsg:@"取消收藏"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickCollectActionRefreshList)]) {
                [self.delegate clickCollectActionRefreshList];
            }
            
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark - UiScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    //通知分页子控制器列表返回顶部
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SegementViewChildVCBackToTop" object:nil];
    return YES;
}

//收藏（取消收藏）
-(void)btnCollectAction{
    if ([self.isCollect isEqualToString:@"0"]) {
        //收藏
        [self collectTonyRequest];
    }else{
        //取消收藏
        [self cancelCollectTonyRequest];
    }
}

/**
 * 处理联动
 * 因为要实现下拉头部放大的问题，tableView设置了contentInset，所以试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理，
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //当前y轴偏移量
    CGFloat currentOffsetY  = scrollView.contentOffset.y;
    CGFloat criticalPointOffsetY = [self.mainTableView rectForSection:0].origin.y;
    //利用contentOffset处理内外层scrollView的滑动冲突问题
    if (currentOffsetY >= criticalPointOffsetY) {
        scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
        self.canScroll = NO;
    } else {
        if (!self.canScroll) {
            scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        }
    }
    
    // 头部下拉放大
    CGRect f     = _cycleScrollView.frame;
    f.size.width = _mainTableView.frame.size.width;
    _cycleScrollView.frame  = f;
    if(currentOffsetY < 0){
        // 背景拉伸
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        initialFrame.origin.y = - offsetY;
        initialFrame.size.height = defaultViewHeight + offsetY;
        _cycleScrollView.frame = initialFrame;
    }else{
        _cycleScrollView.y = currentOffsetY/2;
        if (currentOffsetY >=_cycleScrollView.height) {
            _cycleScrollView.y = 0;
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.setPageViewControllers];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSCREEN_HEIGHT - NAVHIGHT;
}

//导航栏
-(UIView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"发型师详情" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"details_ic_favorite" theDelegate:self];
        self.backBtn = (UIButton *)[_navView viewWithTag:5000];
        self.titleLbl = (UILabel *)[_navView viewWithTag:6000];
        self.collectBtn = (UIButton *)[_navView viewWithTag:10000];
        [self.collectBtn addTarget:self action:@selector(btnCollectAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navView;
}

/*
 * 这里可以设置替换你喜欢的segmentView
 */
- (UIView *)setPageViewControllers {
    if (!_segmentView) {
        
        //必要的设置, 如果没有设置可能导致内容显示不正常
        self.automaticallyAdjustsScrollViewInsets = NO;
        ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
        //显示滚动条
        style.showLine = YES;
        style.scrollTitle = NO;
        style.selectedTitleColor = RGBMAIN;
        style.scrollLineColor = RGBMAIN;
        style.normalTitleColor = RGBTEXT;
        // 颜色渐变
        style.gradualChangeTitleColor = YES;
        // 设置子控制器 --- 注意子控制器需要设置title, 将用于对应的tag显示title
        NSArray *childVcs = [NSArray arrayWithArray:[self setupChildVcAndTitle]];
        // 初始化
        ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0,0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) segmentStyle:style childVcs:childVcs parentViewController:self];
        _segmentView = scrollPageView;
    }
    return _segmentView;
}

// 创建自控制器
- (NSArray *)setupChildVcAndTitle {
    HDServiceEvaluateViewController *vc1 = [[HDServiceEvaluateViewController alloc] init];
    vc1.title = @"服务评价";
    vc1.tonyId = self.cutter_id;
    HDCutExperienceViewController *vc2 = [[HDCutExperienceViewController alloc] init];
    vc2.title = @"剪发经验";
    vc2.tonyId = self.cutter_id;
    vc2.workLife = self.detailModel.workingLifeText;
    HDCutterShowsViewController *vc3 = [[HDCutterShowsViewController alloc] init];
    vc3.title = @"作品集";
    vc3.tonyId = self.cutter_id;

    NSArray *childVcs = [NSArray arrayWithObjects:vc1, vc2, vc3,nil];
    return childVcs;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        self.canScroll = YES;
        
        self.mainTableView = [[CenterTouchTableView alloc]initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
    }
    return _mainTableView;
}

// 发型师详情视图
-(UIView *)tabHeadView{
    if (!_tabHeadView) {
        _tabHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, self.cycleScrollView.bottom, kSCREEN_WIDTH, self.offHeight)];
        _tabHeadView.backgroundColor = [UIColor whiteColor];
        
        //发型师头像
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 60, 60)];
        headImg.contentMode = 2;
        headImg.layer.masksToBounds = YES;
        headImg.layer.cornerRadius = 4;
        [_tabHeadView addSubview:headImg];
        
        //发型师名称
        UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(headImg.frame)+10, 20, 50, 30) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblName.font = TEXT_SC_TFONT(TEXT_SC_Regular, 16);
        [_tabHeadView addSubview:lblName];
        
        //工作年限
        UILabel *lblExpYears = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblName.frame)+10, lblName.y, 50, 16) title:@"" bgColor:RGBCOLOR(241, 135, 112) titleColor:[UIColor whiteColor] titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
        lblExpYears.font = TEXT_SC_TFONT(TEXT_SC_Regular, 10);
        [_tabHeadView addSubview:lblExpYears];
        lblExpYears.layer.cornerRadius = 2;
        
        //价格
        UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(0,20,100,20)];
        [_tabHeadView addSubview:lblPrice];
        
        if (self.detailModel) {
            [headImg sd_setImageWithURL:[NSURL URLWithString:self.detailModel.headImg]];
            
            lblName.text = self.detailModel.userName;
            [lblName sizeToFit];
            if (lblName.height<16) {
                lblName.height = 16;
            }
            
            lblExpYears.text = self.detailModel.workingLifeText;
            [lblExpYears sizeToFit];
            lblExpYears.height = 16;
            lblExpYears.width = lblExpYears.width+6;
            
            lblPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[self.detailModel.amount floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
            [lblPrice sizeToFit];
            lblPrice.x = kSCREEN_WIDTH-lblPrice.width-16;
            
            lblExpYears.x = CGRectGetMaxX(lblName.frame)+10;
            lblExpYears.centerY = lblName.centerY;
            if (CGRectGetMaxX(lblExpYears.frame)+8 > lblPrice.x) {
                lblExpYears.x = lblPrice.x - lblExpYears.width - 8;
                lblName.width = lblExpYears.x -CGRectGetMaxX(headImg.frame) -18;
                lblName.numberOfLines = 0;
                [lblName sizeToFit];
                lblExpYears.y = lblName.y + 7;
            }
        }
        
        UIView *_fetureView = [[UIView alloc] initWithFrame:CGRectMake(lblName.x, CGRectGetMaxY(lblName.frame)+10, kSCREEN_WIDTH-lblName.x-16, 16)];
        
        UIImageView *_imgFeture = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barber_ic_label"]];
        _imgFeture.x = 0;
        _imgFeture.y = 3;
        [_fetureView addSubview:_imgFeture];
        
        if (self.detailModel) {
            if (self.detailModel.labels.count > 0) {
                for (int i = 0; i<self.detailModel.labels.count; i++) {
                    
                    UILabel *lblFeture = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_imgFeture.frame)+11 + i*56, 0, 48, 16) title:self.detailModel.labels[i] bgColor:RGBAlpha(245, 34, 45, 0.08) titleColor:RGBMAIN titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
                    [lblFeture sizeToFit];
                    lblFeture.width = lblFeture.width+5;
                    lblFeture.height = 16;
                    
                    lblFeture.tag = 100+i;

                    UILabel *lblLast = (UILabel *)[_fetureView viewWithTag:100+i-1];
                    
                    if (i==0) {
                        lblFeture.y = 0;
                        lblFeture.x = CGRectGetMaxX(_imgFeture.frame)+11;
                    }else{
                        lblFeture.x = CGRectGetMaxX(lblLast.frame)+11;
                        if (CGRectGetMaxX(lblFeture.frame)+16 > _fetureView.width) {
                            lblFeture.x = CGRectGetMaxX(_imgFeture.frame)+11;
                            lblFeture.y = CGRectGetMaxY(lblLast.frame)+5;
                        }else{
                            lblFeture.y = lblLast.y;
                        }
                    }
                    
                    lblFeture.layer.cornerRadius = 2;
                    
                    [_fetureView addSubview:lblFeture];
                    
                    _fetureView.height = CGRectGetMaxY(lblFeture.frame);
                }
            }else{
                _imgFeture.hidden = YES;
            }
        }
        [_tabHeadView addSubview:_fetureView];
        
        // 地址视图
        CGFloat shopNameY = _fetureView.bottom+16;
        if (_fetureView.bottom < headImg.bottom) {
            shopNameY = headImg.bottom+16;
        }
        UIView *_shopNameView = [[UIView alloc] initWithFrame:CGRectMake(0, shopNameY, kSCREEN_WIDTH, 58*SCALE)];
        [_tabHeadView addSubview:_shopNameView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 1)];
        line.backgroundColor = RGBBG;
        [_shopNameView addSubview:line];
        
        UILabel *_lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16*SCALE, kSCREEN_WIDTH-32, 16*SCALE) title:@"" bgColor:[UIColor whiteColor] titleColor:RGBTEXT titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        [_shopNameView addSubview:_lblShopName];
        _lblShopName.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
        if (self.detailModel) {
            _lblShopName.text = self.detailModel.storeName;
        }
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 50*SCALE, kSCREEN_WIDTH, 8*SCALE)];
        line1.backgroundColor = RGBBG;
        [_shopNameView addSubview:line1];
        
        _tabHeadView.height = _shopNameView.bottom;
        self.offHeight = _tabHeadView.height + 210*SCALE;
    }
    return _tabHeadView;
}

// 取号视图
-(UIView *)viewGetNo{
    if (!_viewGetNo) {
        _viewGetNo = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-KTarbarHeight, kSCREEN_WIDTH, KTarbarHeight)];
        _viewGetNo.backgroundColor = [UIColor whiteColor];
        
        UIButton *buttonGet = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-76*SCALE-16, 6*SCALE, 76*SCALE, 36) btnTitle:@"取号" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        buttonGet.backgroundColor = RGBMAIN;
        buttonGet.layer.cornerRadius = 2;
        [_viewGetNo addSubview:buttonGet];
        
        [buttonGet addTarget:self action:@selector(btnGetNoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lblWaitNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-42*SCALE-76*SCALE, 14) title:@"" bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(102, 102, 102) titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblWaitNum.centerY = buttonGet.centerY;
        if (self.detailModel) {
            lblWaitNum.text = [NSString stringWithFormat:@"前面有%ld人，约等待%ld分钟",(long)[self.detailModel.queueNumber integerValue],(long)[self.detailModel.waitTime integerValue]];
        }
        [_viewGetNo addSubview:lblWaitNum];
    }
    return _viewGetNo;
}

// 取号
-(void)btnGetNoAction:(UIButton *)sender{
    HDGetCutNumberViewController *getVC = [[HDGetCutNumberViewController alloc] init];
    getVC.cutter_id = self.cutter_id;
    [self.navigationController pushViewController:getVC animated:YES];
}

-(YWPageHeadView *)pageHeadView{
    if (!_pageHeadView) {
        _pageHeadView = [[YWPageHeadView alloc]init];
        _pageHeadView.frame = CGRectMake(0, 0,kSCREEN_WIDTH, 0);
        
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 210*SCALE) imageNamesGroup:@[@"barber_bg"]];
        cycleScrollView.delegate = self;
        cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleNone;
        cycleScrollView.layer.masksToBounds = YES;
        
        self.cycleScrollView = cycleScrollView;
        
        [_pageHeadView addSubview:self.cycleScrollView];
    }
    return _pageHeadView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
