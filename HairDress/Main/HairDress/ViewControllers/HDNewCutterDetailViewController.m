//
//  HDNewCutterDetailViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/4/1.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDNewCutterDetailViewController.h"

#import "HDCutterDetailModel.h"
#import "HDEvaluateModel.h"
#import "HDCutterResumeExpModel.h"
#import "HDCutterWorkShowsModel.h"
#import "SDPhotoBrowser.h"

#import "HDGetCutNumberViewController.h"
#import "HDNewServiceEvaluateViewController.h"
#import "HDCutterShowsCollectionViewCell.h"

@interface HDNewCutterDetailViewController ()<navViewDelegate,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,SDPhotoBrowserDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong)UICollectionView *cellCollectView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flow;

@property (nonatomic,strong) UIView *headerInfoView;//头部详情
@property (nonatomic,strong) UIView *menuView;//菜单切换
@property (nonatomic,strong) UIView *bottomView;//底部视图
@property (nonatomic,strong) UIView *evaView;//服务评价
@property (nonatomic,strong) UIView *expView;//剪发经验
@property (nonatomic,strong) UIView *showsView;//作品集
@property (nonatomic,strong) UIButton *collectBtn;//收藏按钮
@property (nonatomic,weak) UIView *viewBlock;//滑块
@property (nonatomic,strong) UIView *emptyShowView;//空视图

@property (nonatomic, copy) NSString *isCollect;//是否收藏
@property (nonatomic, assign) BOOL isClickBtn;//是否点击按钮切换
@property (nonatomic,strong) HDCutterDetailModel *detailModel;//发型师详情
@property (nonatomic,strong) NSMutableDictionary *dicEvaInfo;//评价数据
@property (nonatomic,strong) NSMutableArray *arrExpList;//剪发经验
@property (nonatomic,strong) NSMutableArray *arrShowsList;//作品集
@property (nonatomic,assign)NSInteger page;

@end

@implementation HDNewCutterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.view.backgroundColor = RGBBG;
    self.dicEvaInfo = [NSMutableDictionary new];
    self.arrExpList = [NSMutableArray new];
    self.arrShowsList = [NSMutableArray new];
    
    [self.view addSubview:self.navView];
    
    [self getCutterDetail];
}

#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
//    NSLog(@"offsetY:%f",offsetY);
    if (offsetY <= _headerInfoView.height) {
        _menuView.y = _headerInfoView.bottom;
    }else{//移动过程
        if (offsetY>NAVHIGHT) {
            _menuView.y =offsetY;
        }
        CGFloat scrollY = offsetY+_menuView.height;
        if (!_isClickBtn) {
            //选中服务评价视图
            if (_evaView.y< scrollY && scrollY<_evaView.bottom) {
                [self resetBtns:0];
            }
            //选中剪发经验视图
            else if (_expView.y< scrollY && scrollY<_expView.bottom){
                [self resetBtns:1];
            }
            //选中剪发经验视图
            else if (_showsView.y< scrollY && scrollY<_showsView.bottom) {
                [self resetBtns:2];
            }
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _isClickBtn = NO;
}

// 取号
-(void)btnGetNoAction:(UIButton *)sender{
    HDGetCutNumberViewController *getVC = [[HDGetCutNumberViewController alloc] init];
    getVC.cutter_id = self.cutter_id;
    [self.navigationController pushViewController:getVC animated:YES];
}

//查看更多评价
-(void)btnMoreEvaAction{
    HDNewServiceEvaluateViewController *evaVC = [HDNewServiceEvaluateViewController new];
    evaVC.tonyId = self.cutter_id;
    [self.navigationController pushViewController:evaVC animated:YES];
}

#pragma mark --菜单视图切换
-(void)btnMenuAction:(UIButton *)sender{
    _isClickBtn = YES;
    NSInteger i = sender.tag -200;
    [self resetBtns:i];
    if (i==0) {
        [_mainScrollView scrollRectToVisible:CGRectMake(0, _evaView.y-_menuView.height, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-57*SCALE) animated:YES];
    }
    if (i==1) {
        [_mainScrollView scrollRectToVisible:CGRectMake(0, _expView.y-_menuView.height, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-57*SCALE) animated:YES];
    }
    if (i==2) {
        [_mainScrollView scrollRectToVisible:CGRectMake(0, _showsView.y-_menuView.height, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-57*SCALE) animated:YES];
    }
}

#pragma mark --收藏（取消收藏）
-(void)btnCollectAction{
    if ([self.isCollect isEqualToString:@"0"]) {
        //收藏
        [self collectTonyRequest];
    }else{
        //取消收藏
        [self cancelCollectTonyRequest];
    }
}

//更改菜单按钮选中状态
-(void)resetBtns:(NSInteger)seletedIndex{
    for (int i=0; i<3; i++) {
        UIButton *btn = (UIButton *)[_menuView viewWithTag:200+i];
        btn.selected = NO;
        btn.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Regular, 14*SCALE);
    }
    
    if (seletedIndex > 2) {
        return;
    }
    UIButton *btn = (UIButton *)[_menuView viewWithTag:200+seletedIndex];
    if (!btn.selected) {
        btn.selected = YES;
        btn.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
        [UIView animateWithDuration:0.3 animations:^{
            self.viewBlock.centerX = btn.centerX;
        }];
    }
}

#pragma mark ================== 加载控件 =====================
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"发型师详情" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"info_nav_ic_favorite_b" theDelegate:self];
        self.collectBtn = (UIButton *)[_navView viewWithTag:10000];
        [self.collectBtn addTarget:self action:@selector(btnCollectAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navView;
}

#pragma mark - 添加刷新控件
-(void)setupRefresh{
    self.mainScrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//上提加载更多
-(void)loadMoreData{
    self.page ++;
    [self getWorksShowListRequest:YES];
}

#pragma mark --主视图
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-57*SCALE)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        _mainScrollView.delegate = self;
        
        [_mainScrollView addSubview:self.headerInfoView];
        
        if (CGRectGetMaxY(self.headerInfoView.frame)<_mainScrollView.height) {
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _mainScrollView.height);
        }
        else{
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, CGRectGetMaxY(self.headerInfoView.frame));
        }

        [self setupRefresh];
    }
    return _mainScrollView;
}

#pragma mark --头部发型师信息视图
-(UIView *)headerInfoView{
    if (!_headerInfoView) {
        _headerInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 300)];
        _headerInfoView.backgroundColor = [UIColor whiteColor];
        
        //头部大图
        UIImageView *imageBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 210*SCALE)];
        imageBg.contentMode = 2;
        imageBg.layer.masksToBounds = YES;
        [_headerInfoView addSubview:imageBg];
        
        //发型师头像
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(16, imageBg.bottom+16, 60, 60)];
        headImg.contentMode = 2;
        headImg.layer.masksToBounds = YES;
        headImg.layer.cornerRadius = 4;
        [_headerInfoView addSubview:headImg];
        
        //发型师名称
        UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(headImg.frame)+10, imageBg.bottom+20, 50, 30) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblName.font = TEXT_SC_TFONT(TEXT_SC_Regular, 16);
        [_headerInfoView addSubview:lblName];
        
        //工作年限
        UILabel *lblExpYears = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblName.frame)+10, lblName.y, 50, 16) title:@"" bgColor:RGBCOLOR(241, 135, 112) titleColor:[UIColor whiteColor] titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
        lblExpYears.font = TEXT_SC_TFONT(TEXT_SC_Regular, 10);
        [_headerInfoView addSubview:lblExpYears];
        lblExpYears.layer.cornerRadius = 2;
        
        //价格
        UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(0,imageBg.bottom+20,100,20)];
        [_headerInfoView addSubview:lblPrice];
        
        if (self.detailModel) {
            [imageBg sd_setImageWithURL:[NSURL URLWithString:self.detailModel.headImg]];
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
            }
        }
        [_headerInfoView addSubview:_fetureView];
        
        // 地址视图
        CGFloat shopNameY = _fetureView.bottom+16;
        if (_fetureView.bottom < headImg.bottom) {
            shopNameY = headImg.bottom+16;
        }
        UIView *_shopNameView = [[UIView alloc] initWithFrame:CGRectMake(0, shopNameY, kSCREEN_WIDTH, 58*SCALE)];
        [_headerInfoView addSubview:_shopNameView];
        
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
        
        _headerInfoView.height = _shopNameView.bottom;
    }
    return _headerInfoView;
}

#pragma mark --菜单切换按钮视图
-(UIView *)menuView{
    if (!_menuView) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerInfoView.bottom, kSCREEN_WIDTH, 48*SCALE)];
        _menuView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _menuView.height-1, kSCREEN_WIDTH, 1)];
        line.backgroundColor = RGBLINE;
        [_menuView addSubview:line];
        
        UIView *viewBlock = [[UIView alloc] initWithFrame:CGRectMake(0, _menuView.height-3, 40, 3)];
        viewBlock.backgroundColor = RGBMAIN;
        [_menuView addSubview:viewBlock];
        self.viewBlock = viewBlock;
        
        NSArray *menuArr = @[@"服务评价",@"剪发经验",@"作品集"];
        for (int i=0; i<menuArr.count; i++) {
            UIButton *btn = [[UIButton alloc] initSystemWithFrame:CGRectMake(i*kSCREEN_WIDTH/menuArr.count, 0, kSCREEN_WIDTH/menuArr.count, _menuView.height) btnTitle:menuArr[i] btnImage:@"" titleColor:RGBTEXT titleFont:14*SCALE];
            [btn setTitleColor:RGBMAIN forState:UIControlStateSelected];
            btn.tag = 200+i;
            self.viewBlock.width = btn.width/2;
            if (i==0) {
                btn.selected = YES;
                btn.titleLabel.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
                self.viewBlock.centerX = btn.centerX;
            }
            [btn addTarget:self action:@selector(btnMenuAction:) forControlEvents:UIControlEventTouchUpInside];
            [_menuView addSubview:btn];
        }
    }
    return _menuView;
}

#pragma mark --服务评价视图
-(UIView *)evaView{
    if (!_evaView) {
        _evaView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerInfoView.bottom+48*SCALE, kSCREEN_WIDTH, 600)];
        _evaView.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 32, kSCREEN_WIDTH-32, 20) title:@"服务评价" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:20 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_evaView addSubview:lblText];
        
        UIView *viewScore = [[UIView alloc] initWithFrame:CGRectMake(0, lblText.bottom, kSCREEN_WIDTH, 84)];
        [_evaView addSubview:viewScore];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH/2, 0, 1, 46)];
        line1.centerY = viewScore.height/2;
        line1.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewScore addSubview:line1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(16, viewScore.height, kSCREEN_WIDTH-32, 1)];
        line2.backgroundColor = RGBCOLOR(241, 241, 241);
        [viewScore addSubview:line2];
        
        UILabel *lblScroeNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 24, kSCREEN_WIDTH/2, 20) title:@"0" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:20 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewScore addSubview:lblScroeNum];
        UILabel *lblScroe = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, CGRectGetMaxY(lblScroeNum.frame)+9, kSCREEN_WIDTH/2, 12) title:@"评分" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewScore addSubview:lblScroe];
        
        UIView *viewComment = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2, 86)];
        [viewScore addSubview:viewComment];
        
        UILabel *lblCommentNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 24, kSCREEN_WIDTH/2, 20) title:@"0" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:20 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewComment addSubview:lblCommentNum];
        UILabel *lblComment = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, CGRectGetMaxY(lblScroeNum.frame)+9, kSCREEN_WIDTH/2, 12) title:@"评论数" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewComment addSubview:lblComment];
        
        if (![HDToolHelper StringIsNullOrEmpty:self.dicEvaInfo[@"score"]]) {
            lblScroeNum.text = self.dicEvaInfo[@"score"];
        }
        if (![HDToolHelper StringIsNullOrEmpty:self.dicEvaInfo[@"count"]]) {
            lblCommentNum.text = self.dicEvaInfo[@"count"];
        }
        
        //评价view
        UIView *evaDesView = [[UIView alloc] initWithFrame:CGRectMake(0, viewScore.bottom, kSCREEN_WIDTH, 100)];
        [_evaView addSubview:evaDesView];
        
        //评价
        NSArray *arrEvaList = self.dicEvaInfo[@"evaList"];
        if (arrEvaList.count > 0) {
            HDEvaluateModel *model = arrEvaList[0];
            
            //头像
            UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(16, 24, 40, 40)];
            headImg.layer.cornerRadius = 20;
            headImg.layer.masksToBounds = YES;
            [headImg sd_setImageWithURL:[NSURL URLWithString:model.headImg]];
            [evaDesView addSubview:headImg];
            
            //姓名
            UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(headImg.frame)+12, headImg.y, kSCREEN_WIDTH-81-CGRectGetMaxX(headImg.frame)-12, 14) title:model.userName bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            [evaDesView addSubview:lblName];
            
            //手机号
            UILabel *lblPhone = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(headImg.frame)+12, lblName.bottom+6, kSCREEN_WIDTH-16-CGRectGetMaxX(headImg.frame)-12, 12) title:[model.phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(144, 151, 170) titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
            [evaDesView addSubview:lblPhone];
            
            // 分数
            for (int i = 0; i<5; i++) {
                UIImageView *imageScroe = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-57+i*12, 0, 9, 8)];
                imageScroe.centerY = lblName.centerY;
                imageScroe.image = [UIImage imageNamed:@"evaluation_s_nor"];
                imageScroe.tag = 1000+i;
                [evaDesView addSubview:imageScroe];
                if ([model.totalStars integerValue] == 1) {
                    if (i > 3) {
                        imageScroe.image = [UIImage imageNamed:@"evaluation_s_selected"];
                    }
                }
                if ([model.totalStars integerValue] == 2) {
                    if (i > 2) {
                        imageScroe.image = [UIImage imageNamed:@"evaluation_s_selected"];
                    }
                }
                if ([model.totalStars integerValue] == 3) {
                    if (i > 1) {
                        imageScroe.image = [UIImage imageNamed:@"evaluation_s_selected"];
                    }
                }
                if ([model.totalStars integerValue] == 4) {
                    if (i > 0) {
                        imageScroe.image = [UIImage imageNamed:@"evaluation_s_selected"];
                    }
                }
                if ([model.totalStars integerValue] == 5) {
                    imageScroe.image = [UIImage imageNamed:@"evaluation_s_selected"];
                }
            }
            
            //评论内容
            UILabel *lblContent = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(headImg.frame)+12, lblPhone.bottom+16, kSCREEN_WIDTH-CGRectGetMaxX(headImg.frame)-12-16, 14) title:model.content bgColor:[UIColor clearColor] titleColor:RGBCOLOR(95, 95, 105) titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            lblContent.numberOfLines = 0;
            [lblContent sizeToFit];
            if (lblContent.height < 14) {
                lblContent.height = 14;
            }
            [evaDesView addSubview:lblContent];
            evaDesView.height = lblContent.bottom + 16;
            
            //评论图片
            for (int i=0; i<model.imgList.count; i++) {
                CGFloat gw = (kSCREEN_WIDTH-CGRectGetMaxX(headImg.frame)-12-16-32)/3;
                CGFloat gx = CGRectGetMaxX(headImg.frame)+12+(gw+16)*(i%3);
                CGFloat gy = lblContent.bottom+12.5+ceil((i/3))*(gw+16);
                if (model.imgList.count == 1) {
                    gw = 120;
                }else if (model.imgList.count > 1 && model.imgList.count < 5){
                    gw = (kSCREEN_WIDTH-CGRectGetMaxX(headImg.frame)-12-16-32)/2;
                    gx = CGRectGetMaxX(headImg.frame)+12+(gw+16)*(i%2);
                    gy = lblContent.bottom+12.5+ceil((i/2))*(gw+16);
                }
                
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(gx, gy, gw, gw)];
                [img sd_setImageWithURL:[NSURL URLWithString:model.imgList[i]]];
                [evaDesView addSubview:img];
                evaDesView.height = img.bottom + 16;
            }
            
            //发型师
            UILabel *lblCutterName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(headImg.frame)+12, evaDesView.height, 100, 12) title:[NSString stringWithFormat:@"发型师：%@",model.tonyName] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(143, 151, 170) titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
            [evaDesView addSubview:lblCutterName];
            
            //时间
            UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblCutterName.y, 100, 12) title:model.createTime bgColor:[UIColor clearColor] titleColor:RGBCOLOR(143, 151, 170) titleFont:12 textAlignment:NSTextAlignmentRight isFit:NO];
            [lblTime sizeToFit];
            lblTime.height = 12;
            lblTime.x = kSCREEN_WIDTH - lblTime.width - 16;
            [evaDesView addSubview:lblTime];
            lblCutterName.width = lblTime.x - CGRectGetMaxX(headImg.frame)-12-10;
            
            //查看更多评价
            UIButton *btnMore = [[UIButton alloc] initSystemWithFrame:CGRectMake(0, lblCutterName.bottom+32, 102, 30) btnTitle:@"查看全部评价" btnImage:@"" titleColor:RGBTEXT titleFont:14];
            btnMore.centerX = evaDesView.width/2;
            btnMore.layer.borderWidth = 1;
            btnMore.layer.borderColor = HexRGBAlpha(0x3A464E,1).CGColor;
            btnMore.layer.cornerRadius = 2;
            [btnMore addTarget:self action:@selector(btnMoreEvaAction) forControlEvents:UIControlEventTouchUpInside];
            [evaDesView addSubview:btnMore];
            evaDesView.height = btnMore.bottom+32;
            
        }else{
            [evaDesView addSubview:self.viewEmpty];
            self.viewEmpty.hidden = NO;
            self.viewEmpty.y = 32;
            self.emptyStr = @"暂无评价";
            evaDesView.height = self.viewEmpty.bottom + 32;
        }
        
        _evaView.height = evaDesView.bottom;
    }
    return _evaView;
}

#pragma mark --剪发经验视图
-(UIView *)expView{
    if (!_expView) {
        _expView = [[UIView alloc] initWithFrame:CGRectMake(0, _evaView.bottom+8, kSCREEN_WIDTH, 600)];
        _expView.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 32, kSCREEN_WIDTH-32, 20) title:@"剪发经验" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:20 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_expView addSubview:lblText];
        
        UILabel *lblExp = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblText.bottom+24, kSCREEN_WIDTH-32, 28) title:[NSString stringWithFormat:@"%@年剪发经验",self.detailModel.workingLife] bgColor:RGBCOLOR(25, 24, 29) titleColor:[UIColor whiteColor] titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
        [lblExp sizeToFit];
        lblExp.height = 28;
        lblExp.width = lblExp.width + 40;
        lblExp.layer.cornerRadius = 2;
        [_expView addSubview:lblExp];
        _expView.height = lblExp.bottom+24;
        
        for (int i=0; i<self.arrExpList.count; i++) {
            HDCutterResumeExpModel *model = self.arrExpList[i];
            UIView *viewExp = [[UIView alloc] initWithFrame:CGRectMake(0, lblExp.bottom+i*80, kSCREEN_WIDTH, 80)];
            viewExp.tag = 100+i;
            UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(19, 0, 1, 32)];
            line1.backgroundColor = RGBCOLOR(216, 216, 216);
            [viewExp addSubview:line1];
            
            UIView *block = [[UIView alloc] initWithFrame:CGRectMake(0, line1.bottom+2, 6, 6)];
            block.backgroundColor = RGBCOLOR(216, 216, 216);
            block.centerX = line1.centerX;
            [viewExp addSubview:block];
            
            UIView *viewlast = (UIView *)[_expView viewWithTag:100+i-1];
            if (i==0) {
                viewExp.y = lblExp.bottom;
            }else{
                viewExp.y = viewlast.bottom;
            }
            
            //店铺名称
            UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(block.frame)+4, 30, kSCREEN_WIDTH-CGRectGetMaxX(block.frame)-4-16, 14) title:model.storeName bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            lblShopName.numberOfLines = 0;
            [lblShopName sizeToFit];
            if (lblShopName.height < 14) {
                lblShopName.height = 14;
            }
            [viewExp addSubview:lblShopName];
            
            //年限
            UILabel *lblYears = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(block.frame)+4, lblShopName.bottom+12, kSCREEN_WIDTH-CGRectGetMaxX(block.frame)-4-16, 14) title:[NSString stringWithFormat:@"在职时间：%@-%@",model.startTime,model.endTime] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            lblYears.numberOfLines = 0;
            [lblYears sizeToFit];
            if (lblYears.height < 14) {
                lblYears.height = 14;
            }
            [viewExp addSubview:lblYears];
            viewExp.height = lblYears.bottom+10;
            
            if (i !=self.arrExpList.count-1) {
                UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, block.bottom+2, 1, viewExp.height-block.bottom-2)];
                line2.backgroundColor = RGBCOLOR(216, 216, 216);
                line2.centerX = block.centerX;
                [viewExp addSubview:line2];
            }
            
            [_expView addSubview:viewExp];
            _expView.height = viewExp.bottom+30;
        }
    }
    return _expView;
}

#pragma mark --作品集视图
-(UIView *)showsView{
    if (!_showsView) {
        _showsView = [[UIView alloc] initWithFrame:CGRectMake(0, _expView.bottom+8, kSCREEN_WIDTH, 100)];
        _showsView.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 32, kSCREEN_WIDTH-32, 20) title:@"Ta的作品" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:20 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_showsView addSubview:lblText];
        
        [_showsView addSubview:self.emptyShowView];
        self.emptyShowView.y = lblText.bottom+24;
        
        [self createCollectView];
        self.cellCollectView.y = lblText.bottom+24;
        _showsView.height = _cellCollectView.bottom;
    }
    return _showsView;
}

//空数据视图
-(UIView *)emptyShowView{
    if (!_emptyShowView) {
        _emptyShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
        _emptyShowView.hidden = YES;
        
        UIImageView *imageEmpty = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_ic_default"]];
        imageEmpty.centerX = kSCREEN_WIDTH/2;
        imageEmpty.y = 0;
        [_emptyShowView addSubview:imageEmpty];
        
        UILabel *lblEmpty = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageEmpty.bottom+16, kSCREEN_WIDTH, 14) title:@"Ta太忙了，什么也没留下" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_emptyShowView addSubview:lblEmpty];
        
        _emptyShowView.height = lblEmpty.bottom;
    }
    return _emptyShowView;
}

#pragma mark --作品集cell
-(void)createCollectView{
    _flow = [[UICollectionViewFlowLayout alloc] init];
    _cellCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) collectionViewLayout:_flow];
    _cellCollectView.delegate = self;
    _cellCollectView.dataSource = self;
    _cellCollectView.backgroundColor = [UIColor clearColor];
    [_cellCollectView registerClass:[HDCutterShowsCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([HDCutterShowsCollectionViewCell class])];
    [_showsView addSubview:_cellCollectView];
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;//可以根据section 设置不同section item的行间距
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;// 可以根据section 设置不同section item的列间距

}

/** 边缘之间的间距*/
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 16, 8, 15);
}

//返回每个item大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterWorkShowsModel *model = self.arrShowsList[indexPath.item];
    return CGSizeMake((kSCREEN_WIDTH-32-15)/2, model.cellHegiht);//可以根据indexpath 设置item 的size
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;//设置section 个数
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrShowsList.count;//根据section设置每个section的item个数
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterShowsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HDCutterShowsCollectionViewCell class]) forIndexPath:indexPath];
    cell.tag = 1000+indexPath.item;
    cell.model = self.arrShowsList[indexPath.item];
    return cell;
}

//查看图片
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = indexPath.item;
    browser.sourceImagesContainerView = self.cellCollectView;
    browser.imageCount = self.arrShowsList.count;
    browser.delegate = self;
    [browser show];
}

#pragma mark - SDPhotoBrowserDelegate
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSURL *url = [NSURL new];
    if (index < self.arrShowsList.count) {
        HDCutterWorkShowsModel *model = self.arrShowsList[index];
        url = [NSURL URLWithString:model.imgUrl];
    }
    return url;
}
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    HDCutterShowsCollectionViewCell *cell = (HDCutterShowsCollectionViewCell *)[self.cellCollectView viewWithTag:1000+index];
    UIImageView *imageView = cell.imageShow;
    return imageView.image;
}

#pragma mark -- 取号视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-49*SCALE, kSCREEN_WIDTH, 49*SCALE)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        UIButton *buttonGet = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-76*SCALE-16, 6*SCALE, 76*SCALE, 36*SCALE) btnTitle:@"取号" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14*SCALE];
        buttonGet.backgroundColor = RGBMAIN;
        buttonGet.layer.cornerRadius = 2;
        [_bottomView addSubview:buttonGet];
        
        [buttonGet addTarget:self action:@selector(btnGetNoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lblWaitNum = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 0, kSCREEN_WIDTH-42*SCALE-76*SCALE, 14) title:@"" bgColor:[UIColor whiteColor] titleColor:RGBCOLOR(102, 102, 102) titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblWaitNum.centerY = buttonGet.centerY;
        if (self.detailModel) {
            lblWaitNum.text = [NSString stringWithFormat:@"前面有%ld人,约等待%ld分钟",(long)[self.detailModel.queueNumber integerValue],(long)[self.detailModel.waitTime integerValue]];
        }
        [_bottomView addSubview:lblWaitNum];
    }
    return _bottomView;
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
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.detailModel = [HDCutterDetailModel mj_objectWithKeyValues:[HDToolHelper nullDicToDic:returnData[@"data"]]];
            [self.view addSubview:self.mainScrollView];
            [self.view addSubview:self.bottomView];
            //查询是否已收藏
            [self checkCollectRequest];
            //获取评价列表
            [self getCountTonyEvaRequest];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark --获取评论数统计列表
-(void)getCountTonyEvaRequest{
    [MHNetworkManager postReqeustWithURL:URL_CountTonyEvaluate params:@{@"tonyId":self.cutter_id} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSString *countTotal= [NSString stringWithFormat:@"%ld",(long)[returnData[@"data"][@"allNum"] integerValue]];
            NSString *evaScore = [NSString stringWithFormat:@"%.2f",[returnData[@"data"][@"score"] floatValue]];
            [self.dicEvaInfo setValue:evaScore forKey:@"score"];
            [self.dicEvaInfo setValue:countTotal forKey:@"count"];
            [self getEvaListData];
        }else{
            [self.dicEvaInfo setValue:@"0" forKey:@"score"];
            [self.dicEvaInfo setValue:@"0" forKey:@"count"];
            [self getEvaListData];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark --获取评价列表
-(void)getEvaListData{
    NSDictionary *params = @{
        @"tonyId": self.cutter_id,
        @"page":@{@"pageIndex":@(1),@"pageSize":@"10"},
    };
    [MHNetworkManager postReqeustWithURL:URL_EvaluateList params:params successBlock:^(NSDictionary *returnData) {
        [self.mainScrollView.mj_footer endRefreshing];
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arr = [HDEvaluateModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.dicEvaInfo setValue:arr forKey:@"evaList"];
            [self getExpListRequest];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

#pragma mark -- 获取剪发经验列表数据
-(void)getExpListRequest{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(1),
                @"pageSize":@(1000)
        },
        @"tonyId":self.cutter_id,
    };
    [MHNetworkManager postReqeustWithURL:URL_TonyExpManageList params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arr = [HDCutterResumeExpModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            [self.arrExpList removeAllObjects];
            [self.arrExpList addObjectsFromArray:arr];

            [self.mainScrollView addSubview:self.evaView];
            [self.mainScrollView addSubview:self.expView];
            [self.mainScrollView addSubview:self.showsView];
            [self.mainScrollView addSubview:self.menuView];
            self.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, CGRectGetMaxY(self.showsView.frame));
            //获取作品集
            [self getWorksShowListRequest:NO];
        }else{
            [SVHUDHelper showInfoWithTimestamp:1 msg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark --获取作品集列表
-(void)getWorksShowListRequest:(BOOL)more{
    NSDictionary *params = @{
        @"page":@{
                @"pageIndex":@(self.page),
                @"pageSize":@(10)
        },
        @"tonyId":self.cutter_id,
    };
    WeakSelf;
    [MHNetworkManager postReqeustWithURL:URL_TonyWorkShowsManageList params:params successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.mainScrollView.mj_footer endRefreshing];
            NSArray *arr = [HDCutterWorkShowsModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            if (arr.count == 0) {
                weakSelf.page --;
            }
            [self.arrShowsList addObjectsFromArray:arr];
            if (arr.count == 0) {
                [self.mainScrollView.mj_footer endRefreshingWithNoMoreData];
            }
            if (self.arrShowsList.count == 0) {
                self.emptyShowView.hidden = NO;
                self.showsView.height = self.emptyShowView.bottom+32;
                self.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, CGRectGetMaxY(self.showsView.frame));
            }else{
                self.emptyShowView.hidden = YES;
                [self.cellCollectView reloadData];
                CGFloat height = self.cellCollectView.collectionViewLayout.collectionViewContentSize.height;
                self.cellCollectView.height = height;
                self.showsView.height = self.cellCollectView.bottom+32;
                self.mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, CGRectGetMaxY(self.showsView.frame));
            }
            
        }else{
            weakSelf.page --;
            [self.mainScrollView.mj_footer endRefreshing];
        }
    } failureBlock:^(NSError *error) {
        weakSelf.page --;
        [self.mainScrollView.mj_footer endRefreshing];
    } showHUD:NO];
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

@end
