//
//  HDTaoGoodsDetailViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoGoodsDetailViewController.h"
#import "XHWebImageAutoSize.h"
#import "HDTaoGoodsDetailImageCell.h"
#import "HDTaoShareViewController.h"
#import "HDWebViewController.h"
#import "ALiTradeWebViewController.h"

#import <AlibcTradeSDK/AlibcTradeSDK.h>
#import <AlibabaAuthEntrance/ALBBSDK.h>
#import <AlibabaAuthEntrance/ALBBCompatibleSession.h>
#import <SDCycleScrollView.h>
#import "HDTaoDetailInfoModel.h"

@interface HDTaoGoodsDetailViewController ()<ALiTradeWebViewDelegate,UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate>
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}
@property (nonatomic,strong) UIView *navView;
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UIButton *homeBtn;//返回首页
@property (nonatomic,strong) UIButton *whiteBackBtn;//白色返回按钮
@property (nonatomic,strong) UILabel *titleLbl;//标题

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;//头部滚动视图
@property (nonatomic,strong) UIView *priceView;//价格视图
@property (nonatomic,strong) UIView *couponView;//优惠券视图
@property (nonatomic,strong) UIView *reasonView;//推荐理由视图
@property (nonatomic,strong) UIView *shopView;//推荐理由视图
@property (nonatomic,strong) UIView *goodsDetailCloseView;//关闭详情视图
@property (nonatomic,strong) UIView *bottomView;//底部视图

@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,assign)BOOL isCloseDes;
@property (nonatomic,strong) UILabel *lblDetailDes;//是否关闭详情
@property (nonatomic,strong) UIImageView *imgClose;//关闭按钮
@property (nonatomic,strong) HDTaoDetailInfoModel *detailModel;
@property (nonatomic,strong) NSDictionary *couponInfoDic;//优惠券详情(分享领券)

@property (nonatomic,copy) NSString *isShare;
@property (nonatomic,copy) NSString *isCollect;//是否收藏

@property (nonatomic,weak) UIButton *btnCollect;

@end

@implementation HDTaoGoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray new];
    self.isCloseDes = NO;
    self.view.backgroundColor = RGBBG;
    
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.homeBtn];
    
    [self requestDetailInfoData];
    [self getCouponInfoData];
}

#pragma mark ================== 监听网络变化后重新加载数据 =====================
-(void)getLoadDataBase:(NSNotification *)text{
    [super getLoadDataBase:text];
    if ([text.userInfo[@"netType"] integerValue] != 0) {
        if (self.detailModel == nil) {
            [self requestDetailInfoData];
        }
    }
}

#pragma mark ================== 请求详情数据 =====================
//获取用户信息
-(void)getMemberInfo{
    [MHNetworkManager postReqeustWithURL:URL_UserGetMemberInfo params:@{@"id":[HDUserDefaultMethods getData:@"userId"]} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            // 缓存用户信息
            NSDictionary *userInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            [HDUserDefaultMethods saveData:userInfo[@"relationId"] andKey:@"relationId"];
            //授权成功
            if (![userInfo[@"relationId"] isEqualToString:@""]) {
                if ([self.isShare isEqualToString:@"1"]) {//分享
                    [self btnToShareAction];
                }else{//领券
                    [self btnToGetCupponAction];
                }
            }
            else{
                [SVHUDHelper showWorningMsg:@"授权失败" timeInt:1];
            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:NO];
}

//商品详情
-(void)requestDetailInfoData{
    [MHNetworkManager postReqeustWithURL:URL_TaoGoodsDetail params:@{@"id":self.taoId} successBlock:^(NSDictionary *returnData) {
        
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSDictionary *dicInfo = [HDToolHelper nullDicToDic:returnData[@"data"]];
            if ([dicInfo allKeys].count == 0) {
                [self.mainTableView addSubview:self.viewEmpty];
                self.viewEmpty.hidden = NO;
                self.emptyStr = returnData[@"respMsg"];
            }else{
                self.viewEmpty.hidden = YES;
                self.detailModel = [HDTaoDetailInfoModel mj_objectWithKeyValues:dicInfo];
                [self.dataArray addObjectsFromArray:self.detailModel.contentImages];
                self.mainTableView.tableHeaderView = self.headerView;
                [self.view addSubview:self.bottomView];
                [self.mainTableView reloadData];
                
                //查询商品是否收藏
                [self getGoodsIsCollect];
            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//查询是否已收藏
-(void)getGoodsIsCollect{
    if ([HDToolHelper StringIsNullOrEmpty:[HDUserDefaultMethods getData:@"userId"]]) {
        return;
    }
    NSDictionary *params = @{@"taoId":self.taoId,@"userId":[HDUserDefaultMethods getData:@"userId"]};
    [MHNetworkManager postReqeustWithURL:URL_TaoCheckUserGoods params:params successBlock:^(NSDictionary *returnData) {
        //是否收藏
        if ([returnData[@"respCode"] integerValue] == 200) {
            if ([returnData[@"data"] isEqualToString:@"F"]) {
                self.isCollect = @"0";
                self.btnCollect.selected = NO;
            }else{
                self.isCollect = @"1";
                self.btnCollect.selected = YES;
            }
        }else{
            self.isCollect = @"0";
            self.btnCollect.selected = NO;
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//发送收藏请求
-(void)collectGoodsRequest{
    NSDictionary *params = @{
        @"couponInfoMoney":self.detailModel.couponInfoMoney,
        @"memberType":@"F",
        @"nick":self.detailModel.shopTitle,
        @"pictUrl":self.detailModel.pictUrl,
        @"profit":self.detailModel.profit,
        @"quanhoujiage":self.detailModel.quanhouJiage,
        @"shopTitle":self.detailModel.shopTitle,
        @"size":self.detailModel.size,
        @"title":self.detailModel.title,
        @"volume":self.detailModel.volume,
        @"userType":self.detailModel.userType,
        @"taoId":self.taoId,
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoAddUserGoods params:params successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.isCollect = @"1";
            self.btnCollect.selected = YES;
            [SVHUDHelper showSuccessDoneMsg:@"收藏成功"];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(clickCollectGoodsActionRefreshList)]) {
                    [self.delegate clickCollectGoodsActionRefreshList];
                }
            }];
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//取消请求
-(void)cancelCollectGoodsRequest{
    NSDictionary *params = @{
        @"ids":@[self.taoId],
        @"memberType":@"F",
        @"userId":[HDUserDefaultMethods getData:@"userId"]
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoDelUserGoods params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.isCollect = @"0";
            self.btnCollect.selected = NO;
            [SVHUDHelper showSuccessDoneMsg:@"取消收藏"];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(clickCollectGoodsActionRefreshList)]) {
                    [self.delegate clickCollectGoodsActionRefreshList];
                }
            }];
        }else{
            [SVHUDHelper showDarkWarningMsg:returnData[@"respMsg"]];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

//获取优惠券详情
-(void)getCouponInfoData{
    if ([[HDUserDefaultMethods getData:@"relationId"] isEqualToString:@""]) {
        return;
    }
    NSDictionary *params = @{
        @"relationId":[HDUserDefaultMethods getData:@"relationId"],
        @"taoId":self.taoId
    };
    [MHNetworkManager postReqeustWithURL:URL_TaoFormatGoods params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            if ([returnData[@"data"] isKindOfClass:[NSDictionary class]]) {
                self.couponInfoDic = returnData[@"data"];
            }
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}
 
//获取优惠券链接
-(void)getFormatGoods{
    if (self.couponInfoDic) {
        AlibcTradeShowParams* showParam = [[AlibcTradeShowParams alloc] init];
        showParam.openType = AlibcOpenTypeNative;
        showParam.isNeedPush=YES;
        showParam.linkKey = @"taobao"; //淘宝，天猫tmall
        showParam.isNeedCustomNativeFailMode = NO;
        showParam.nativeFailMode=AlibcNativeFailModeJumpDownloadPage;

        [[AlibcTradeSDK sharedInstance].tradeService openByUrl:self.couponInfoDic[@"coupon_click_url"] identity:@"trade" webView:nil parentController:self.navigationController showParams:showParam taoKeParams:nil trackParam:nil tradeProcessSuccessCallback: nil tradeProcessFailedCallback:nil];
    }else{
        NSDictionary *params = @{
            @"relationId":[HDUserDefaultMethods getData:@"relationId"],
            @"taoId":self.taoId
        };
        [MHNetworkManager postReqeustWithURL:URL_TaoFormatGoods params:params successBlock:^(NSDictionary *returnData) {
            if ([returnData[@"respCode"] integerValue] == 200) {
                
                if ([returnData[@"data"] isKindOfClass:[NSDictionary class]]) {
                    self.couponInfoDic = returnData[@"data"];
                }else{
                    [SVHUDHelper showDarkWarningMsg:@"暂无优惠券相关数据"];
                    return;
                }
                
                AlibcTradeShowParams* showParam = [[AlibcTradeShowParams alloc] init];
                showParam.openType = AlibcOpenTypeNative;
                showParam.isNeedPush=YES;
                showParam.linkKey = @"taobao"; //淘宝，天猫tmall
                showParam.isNeedCustomNativeFailMode = NO;
                showParam.nativeFailMode=AlibcNativeFailModeJumpDownloadPage;

                [[AlibcTradeSDK sharedInstance].tradeService openByUrl:self.couponInfoDic[@"coupon_click_url"] identity:@"trade" webView:nil parentController:self.navigationController showParams:showParam taoKeParams:nil trackParam:nil tradeProcessSuccessCallback: nil tradeProcessFailedCallback:nil];
            }
        } failureBlock:^(NSError *error) {
            
        } showHUD:YES];
    }
}

#pragma mark ================== delegate action =====================
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//返回精选首页
-(void)homeClickedAction{
    [HDToolHelper chooseToJumpHome:self selectIndex:self.indexTab];
}

//收藏商品
-(void)btnToCollectAction:(UIButton *)sender{
    if ([HDToolHelper StringIsNullOrEmpty:[HDUserDefaultMethods getData:@"userId"]]) {
        [HDToolHelper preToLoginView];
        return;
    }
    if ([self.isCollect isEqualToString:@"0"]) {
     //收藏
     [self collectGoodsRequest];
    }else{
     //取消收藏
     [self cancelCollectGoodsRequest];
    }
}

//关闭详情
-(void)closeDetailView{
    self.isCloseDes = !self.isCloseDes;
    if (self.isCloseDes) {
        self.lblDetailDes.text = @"点击展开详情";
        self.imgClose.image = [UIImage imageNamed:@"filter_ic_up"];
    }else{
        self.lblDetailDes.text = @"点击关闭详情";
        self.imgClose.image = [UIImage imageNamed:@"filter_ic_down"];
    }
    [_mainTableView reloadData];
}

//去分享
-(void)btnToShareAction{
    self.isShare = @"1";
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    if ([[HDUserDefaultMethods getData:@"relationId"] isEqualToString:@""]) {
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeTaoBao headTitle:@"申请淘宝授权" textTitle:@"淘宝授权后购买或分享商品才能产生佣金收益" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            [self authTaobao];
        }];
    }
    else{
        if (!self.couponInfoDic) {
            NSDictionary *params = @{
                @"relationId":[HDUserDefaultMethods getData:@"relationId"],
                @"taoId":self.taoId
            };
            [MHNetworkManager postReqeustWithURL:URL_TaoFormatGoods params:params successBlock:^(NSDictionary *returnData) {
                
                if ([returnData[@"respCode"] integerValue] == 200) {
                    
                    if ([returnData[@"data"] isKindOfClass:[NSDictionary class]]) {
                        self.couponInfoDic = returnData[@"data"];
                    }else{
                        [SVHUDHelper showDarkWarningMsg:@"暂无优惠券相关数据"];
                        return;
                    }
                    
                    HDTaoShareViewController *shareVC = [HDTaoShareViewController new];
                    shareVC.detailModel = self.detailModel;
                    shareVC.clickUrl = self.couponInfoDic[@"coupon_click_url"];
                    [self.navigationController pushViewController:shareVC animated:YES];
                }
            } failureBlock:^(NSError *error) {
                
            } showHUD:YES];
        }else{
            HDTaoShareViewController *shareVC = [HDTaoShareViewController new];
            shareVC.detailModel = self.detailModel;
            shareVC.clickUrl = self.couponInfoDic[@"coupon_click_url"];
            [self.navigationController pushViewController:shareVC animated:YES];
        }
    }
}

//领券
-(void)btnToGetCupponAction{
    self.isShare = @"0";
    if ([[HDUserDefaultMethods getData:@"userId"] isEqualToString:@""]) {
        [HDToolHelper preToLoginView];
        return;
    }
    if ([[HDUserDefaultMethods getData:@"relationId"] isEqualToString:@""]) {
        [[WMZAlert shareInstance] showAlertWithType:AlertTypeTaoBao headTitle:@"申请淘宝授权" textTitle:@"淘宝授权后购买或分享商品才能产生佣金收益" viewController:self leftHandle:^(id anyID) {
            //取消
        }rightHandle:^(id any) {
            //确定
            [self authTaobao];
        }];
    }
    else{
        [self getFormatGoods];
    }
}

//进入店铺
-(void)tapShopAction:(UIGestureRecognizer *)sender{
    [self btnToGetCupponAction];
}

#pragma mark - 授权后淘宝跳转
//应用授权
-(void)authTaobao{
    if([[ALBBCompatibleSession sharedInstance] isLogin]) {
        [self authSuccessHandle];
        
    } else {
        [[ALBBSDK sharedInstance] setH5Only:NO];
        [[ALBBSDK sharedInstance] auth:self successCallback:^{
            [self authSuccessHandle];
        } failureCallback:^(NSError *error) {
            
        }];
    }
}

-(void)authSuccessHandle{
    NSString *webURl = [HDUserDefaultMethods getData:@"relationAuthUrl"];
    if ([webURl isEqualToString:@""]) {
        [SVHUDHelper showDarkWarningMsg:@"淘宝授权失败"];
        return;
    }
    AlibcTradeShowParams* showParam = [[AlibcTradeShowParams alloc] init];
    showParam.openType = AlibcOpenTypeAuto;
    showParam.isNeedPush=YES;
    showParam.linkKey = @"taobao";
    
    ALiTradeWebViewController *webViewVC = [ALiTradeWebViewController new];
    webViewVC.delegate = self;
    NSInteger res = [[AlibcTradeSDK sharedInstance].tradeService openByUrl:webURl identity:@"trade" webView:webViewVC.webView parentController:webViewVC showParams:showParam taoKeParams:nil trackParam:nil tradeProcessSuccessCallback:nil tradeProcessFailedCallback:nil];
    if (res == 1) {
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
}

//用户授权回调
-(void)doAliAuthDone{
    [self getMemberInfo];
}

//退出淘宝
-(void)logoutTaoBao{
    ALBBSDK *albbSDK = [ALBBSDK sharedInstance];
    [albbSDK logout];
}
    
#pragma mark ================== tableView delegate datasource =====================
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isCloseDes) {
        return 0;
    }
    return self.dataArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *url = self.dataArray[indexPath.row];
    return [XHWebImageAutoSize imageHeightForURL:[NSURL URLWithString:url] layoutWidth:kSCREEN_WIDTH-16 estimateHeight:200];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDTaoGoodsDetailImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDTaoGoodsDetailImageCell class])];
    
    NSString *url = self.dataArray[indexPath.row];
    
    [cell.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cell.contentView.mas_top).offset(8);
        make.bottom.equalTo(cell.contentView.mas_bottom).offset(-8);
        make.left.equalTo(cell.contentView.mas_left).offset(8);
        make.right.equalTo(cell.contentView.mas_right).offset(-8);
    }];
    
    [cell.imageV sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        /** 缓存image size */
        [XHWebImageAutoSize storeImageSize:image forURL:imageURL completed:^(BOOL result) {
            /** reload  */
            if(result)  [tableView  xh_reloadDataForURL:imageURL];
        }];
    }];
    
    return cell;
}

// 头部下拉放大
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {//下拉，隐藏 navView
        self.backBtn.alpha = 1;
        [self.homeBtn setImage:[UIImage imageNamed:@"detail_home"] forState:UIControlStateNormal];
        self.whiteBackBtn.alpha = 0;
        self.titleLbl.alpha = 0;
        self.navView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        // 背景拉伸
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        initialFrame.origin.y = - offsetY;
        initialFrame.size.height = defaultViewHeight + offsetY;
        _cycleScrollView.frame = initialFrame;
    }else{
        self.backBtn.alpha = 1-offsetY/_cycleScrollView.height;
        if (1-offsetY/_cycleScrollView.height <= 0) {
            [self.homeBtn setImage:[UIImage imageNamed:@"detail_white_home"] forState:UIControlStateNormal];
        }else{
            [self.homeBtn setImage:[UIImage imageNamed:@"detail_home"] forState:UIControlStateNormal];
        }
        self.whiteBackBtn.alpha = offsetY/_cycleScrollView.height;
        self.titleLbl.alpha = offsetY/_cycleScrollView.height;
        self.navView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:offsetY/_cycleScrollView.height];
    }
}

#pragma mark ================== UI =====================
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-48) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[HDTaoGoodsDetailImageCell class] forCellReuseIdentifier:NSStringFromClass([HDTaoGoodsDetailImageCell class])];
    }
    return _mainTableView;
}

//头视图
-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 0)];
        if (self.detailModel) {
            SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0,kSCREEN_WIDTH, 375) delegate:self placeholderImage:[UIImage imageNamed:@""]];
            cycleScrollView.delegate = self;
            cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
            cycleScrollView.layer.masksToBounds = YES;
            cycleScrollView.backgroundColor = [UIColor clearColor];
            cycleScrollView.currentPageDotColor = RGBMAIN;
            cycleScrollView.autoScrollTimeInterval = 3;
            self.cycleScrollView = cycleScrollView;
            self.cycleScrollView.imageURLStringsGroup = self.detailModel.smallImagesArr;
            
            [_headerView addSubview:self.cycleScrollView];
            
            //记录初始值
            initialFrame       = _cycleScrollView.frame;
            defaultViewHeight  = initialFrame.size.height;
            
            [_headerView addSubview:self.priceView];
            [_headerView addSubview:self.couponView];
            [_headerView addSubview:self.reasonView];
            [_headerView addSubview:self.shopView];
            if (self.dataArray.count > 0) {
                [_headerView addSubview:self.goodsDetailCloseView];
                _headerView.height = _goodsDetailCloseView.bottom;
            }
            else{
                _headerView.height = _shopView.bottom;
            }
        }
    }
    return _headerView;
}

//价格优惠券视图
-(UIView *)priceView{
    if (!_priceView) {
        _priceView = [[UIView alloc] initWithFrame:CGRectMake(0, _cycleScrollView.bottom, kSCREEN_WIDTH, 108)];
        if (self.detailModel) {
            UILabel *lblPriceText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, 17, 30, 20) title:@"券后" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:14 textAlignment:NSTextAlignmentLeft isFit:YES];
            lblPriceText.height = 14;
            [_priceView addSubview:lblPriceText];
            
            //券后价
            UILabel *lblPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblPriceText.frame)+4, 20, 30, 20) title:[NSString stringWithFormat:@"¥%.2f",[self.detailModel.quanhouJiage floatValue]] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:20 textAlignment:NSTextAlignmentLeft isFit:YES];
            lblPrice.height = 20;
            lblPrice.bottom = lblPriceText.bottom;
            [_priceView addSubview:lblPrice];
            
            //原价
            UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblPrice.frame)+4, 0, 100, 14) title:self.detailModel.size bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            [lblOldPrice sizeToFit];
            lblOldPrice.height = 14;
            lblOldPrice.bottom = lblPrice.bottom-2;
            lblPriceText.bottom = lblPrice.bottom-2;
            [_priceView addSubview:lblOldPrice];
            
            UIView *linePrice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 0.5)];
            linePrice.centerY = lblOldPrice.height/2;
            linePrice.backgroundColor = RGBTEXTINFO;
            [lblOldPrice addSubview:linePrice];
            
            //销量
            UILabel *lblVolume = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 100, 20) title:[NSString stringWithFormat:@"已售%ld件",(long)[self.detailModel.volume integerValue]] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            [lblVolume sizeToFit];
            lblVolume.height = 14;
            lblVolume.centerY = lblPrice.centerY;
            lblVolume.x = kSCREEN_WIDTH-12-lblVolume.width;
            [_priceView addSubview:lblVolume];
            
            //商品名称
            UILabel *lblGoodsName = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, lblPrice.bottom+20, kSCREEN_WIDTH-24, 20) title:self.detailModel.title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:NO];
            lblGoodsName.numberOfLines = 0;
            [lblGoodsName sizeToFit];
            [_priceView addSubview:lblGoodsName];
            
            //分割线
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, lblGoodsName.bottom+16, kSCREEN_WIDTH, 8)];
            line.backgroundColor = RGBCOLOR(242, 242, 242);
            [_priceView addSubview:line];
            
            _priceView.height = line.bottom;
        }
    }
    return _priceView;
}

//优惠券
-(UIView *)couponView{
    if (!_couponView) {
        _couponView = [[UIView alloc] initWithFrame:CGRectMake(0, _priceView.bottom, kSCREEN_WIDTH, 112*SCALE+8)];
        UIImageView *imageCoupon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 112*SCALE)];
        imageCoupon.image = [UIImage imageNamed:@"big_coupon_bg"];
        [_couponView addSubview:imageCoupon];
        
        UIButton *btnGet = [[UIButton alloc] initSystemWithFrame:CGRectMake(imageCoupon.width-28*SCALE-80*SCALE, 36*SCALE, 80*SCALE, 32*SCALE) btnTitle:@"立即领取" btnImage:@"" titleColor:RGBMAIN titleFont:14*SCALE];
        [imageCoupon addSubview:btnGet];
        imageCoupon.userInteractionEnabled = YES;
        [btnGet addTarget:self action:@selector(btnToGetCupponAction) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lblM = [[UILabel alloc] initCommonWithFrame:CGRectMake(24*SCALE, 44*SCALE, 10*SCALE, 10*SCALE) title:@"¥" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblM.height = 10*SCALE;
        [imageCoupon addSubview:lblM];
        
        UILabel *lblCouponMoney = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblM.frame), 24*SCALE, 10*SCALE, 40*SCALE) title:self.detailModel.couponInfoMoney bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:40*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblCouponMoney.height = 40*SCALE;
        lblM.bottom = lblCouponMoney.bottom - 4*SCALE;
        [imageCoupon addSubview:lblCouponMoney];
        
        UILabel *lblCouponText = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblCouponMoney.frame)+4*SCALE, 20*SCALE, 10*SCALE, 40*SCALE) title:@"优惠券" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:14*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblCouponText.height = 14*SCALE;
        lblCouponText.bottom = lblCouponMoney.bottom-4*SCALE;
        [imageCoupon addSubview:lblCouponText];
        
        UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblM.x, lblCouponMoney.bottom+4*SCALE, 10, 12*SCALE) title:[NSString stringWithFormat:@"使用期限:%@-%@",self.detailModel.couponStartTime,self.detailModel.couponEndTime] bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:12*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        [imageCoupon addSubview:lblTime];
        
        //分割线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, imageCoupon.bottom, kSCREEN_WIDTH, 8)];
        line.backgroundColor = RGBCOLOR(242, 242, 242);
        [_couponView addSubview:line];
    }
    return _couponView;
}

//推荐理由
-(UIView *)reasonView{
    if (!_reasonView) {
        _reasonView = [[UIView alloc] initWithFrame:CGRectMake(0, _couponView.bottom, kSCREEN_WIDTH, 80)];
        
        UILabel *lblReasonText = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, 16, 100, 20) title:@"推荐理由" bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:11 textAlignment:NSTextAlignmentCenter isFit:YES];
        lblReasonText.width = lblReasonText.width +8;
        lblReasonText.height = 20;
        lblReasonText.backgroundColor = RGBAlpha(245, 34, 45,0.07);
        [_reasonView addSubview:lblReasonText];
        
        if (self.detailModel) {
            UILabel *lblReason = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblReasonText.frame)+16, 18, kSCREEN_WIDTH-CGRectGetMaxX(lblReasonText.frame)-16-12, 20) title:self.detailModel.jianjie bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:11 textAlignment:NSTextAlignmentLeft isFit:NO];
            lblReason.numberOfLines = 0;
            [lblReason sizeToFit];
            [_reasonView addSubview:lblReason];
            
            _reasonView.height = (lblReason.bottom+20)>80 ? (lblReason.bottom+16) : 80;
        }
        
        //分割线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _reasonView.height-8, kSCREEN_WIDTH, 8)];
        line.backgroundColor = RGBCOLOR(242, 242, 242);
        [_reasonView addSubview:line];
        _reasonView.height = line.bottom;
    }
    return _reasonView;
}

//店铺视图
-(UIView *)shopView{
    if (!_shopView) {
        _shopView = [[UIView alloc] initWithFrame:CGRectMake(0, _reasonView.bottom, kSCREEN_WIDTH, 100)];
        
        UITapGestureRecognizer *tapShop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShopAction:)];
        _shopView.userInteractionEnabled = YES;
        [_shopView addGestureRecognizer:tapShop];
        
        if (self.detailModel) {
            //店铺图片
            UIImageView *imageShop = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 48, 48)];
            [imageShop sd_setImageWithURL:[NSURL URLWithString:self.detailModel.shopIcon] placeholderImage:[UIImage imageNamed:@"mall_ic_tmall"]];
            imageShop.contentMode = 1;
            [_shopView addSubview:imageShop];
            
            //店铺名称
            UILabel *lblShopName = [[UILabel alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(imageShop.frame)+9, imageShop.y+7, kSCREEN_WIDTH-CGRectGetMaxX(imageShop.frame)-9-12, 14) title:self.detailModel.shopTitle bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14];
            [_shopView addSubview:lblShopName];
            
            //平台图标
            UIImageView *imageLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_tmall"]];
            imageLogo.x = CGRectGetMaxX(imageShop.frame)+9;
            imageLogo.y = lblShopName.bottom+8;
            [_shopView addSubview:imageLogo];
            
            UIImageView *imageGo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_arrow_right_g"]];
            imageGo.x = kSCREEN_WIDTH-12-24;
            imageGo.centerY = imageShop.centerY;
            [_shopView addSubview:imageGo];
            
            //进入店铺
            UILabel *lblEnter = [[UILabel alloc] initCustomWithFrame:CGRectMake(CGRectGetMaxX(imageShop.frame)+9, imageShop.y+7, kSCREEN_WIDTH-CGRectGetMaxX(imageShop.frame)-9-12, 12) title:@"进入店铺" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:12];
            [lblEnter sizeToFit];
            lblEnter.centerY = imageGo.centerY;
            lblEnter.x = imageGo.x - lblEnter.width;
            [_shopView addSubview:lblEnter];
            
            //评分视图
            NSArray *arrTitle = @[@"宝贝描述",@"卖家服务",@"物流服务"];
            UIView *viewScore = [[UIView alloc] initWithFrame:CGRectMake(0, imageShop.bottom+15, kSCREEN_WIDTH, 41)];
            viewScore.backgroundColor = RGBCOLOR(250, 250, 250);
            for (int i=0; i<arrTitle.count; i++) {
                UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/arrTitle.count, 0, kSCREEN_WIDTH/arrTitle.count, 41)];
                subView.backgroundColor = [UIColor clearColor];
                [viewScore addSubview:subView];
                
                NSString *strScore = [NSString stringWithFormat:@"%@ %@",arrTitle[i],self.detailModel.score1];
                if ([arrTitle[i] isEqualToString:@"卖家服务"]) {
                    strScore = [NSString stringWithFormat:@"%@ %@",arrTitle[i],self.detailModel.score2];
                }
                if ([arrTitle[i] isEqualToString:@"物流服务"]) {
                    strScore = [NSString stringWithFormat:@"%@  %@",arrTitle[i],self.detailModel.score3];
                }
                
                UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, subView.width, 41)];
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:strScore attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:12],NSForegroundColorAttributeName: RGBMAIN}];
                [string addAttributes:@{NSForegroundColorAttributeName:RGBTEXTINFO} range:NSMakeRange(0, 4)];
                lblText.attributedText = string;
                lblText.textAlignment = NSTextAlignmentCenter;
                
                [subView addSubview:lblText];
            }
            
            [_shopView addSubview:viewScore];
            
            //分割线
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, viewScore.bottom, kSCREEN_WIDTH, 8)];
            line.backgroundColor = RGBCOLOR(242, 242, 242);
            [_shopView addSubview:line];
            _shopView.height = line.bottom;
        }
        
    }
    return _shopView;
}

//关闭详情视图
-(UIView *)goodsDetailCloseView{
    if (!_goodsDetailCloseView) {
        _goodsDetailCloseView = [[UIView alloc] initWithFrame:CGRectMake(0, _shopView.bottom, kSCREEN_WIDTH, 44)];
        _goodsDetailCloseView.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(12, 14, 100, 16) title:@"商品详情" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16 textAlignment:NSTextAlignmentLeft isFit:YES];
        lblTitle.height = 16;
        [_goodsDetailCloseView addSubview:lblTitle];
        
        UILabel *lblTitleDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblTitle.frame)+6, 0, kSCREEN_WIDTH-CGRectGetMaxX(lblTitle.frame)-6, 44) title:@"点击关闭详情" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_goodsDetailCloseView addSubview:lblTitleDesc];
        self.lblDetailDes = lblTitleDesc;
        
        //关闭详情
        UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDetailView)];
        lblTitleDesc.userInteractionEnabled = YES;
        [lblTitleDesc addGestureRecognizer:tapClose];
        
        UIImageView *imageClose = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_ic_down"]];
        imageClose.x = kSCREEN_WIDTH-12-24;
        imageClose.centerY = lblTitle.centerY;
        [_goodsDetailCloseView addSubview:imageClose];
        self.imgClose = imageClose;
        
        //分割线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _goodsDetailCloseView.height, kSCREEN_WIDTH, 8)];
        line.backgroundColor = RGBCOLOR(242, 242, 242);
        [_goodsDetailCloseView addSubview:line];
        _goodsDetailCloseView.height = line.bottom;
    }
    return _goodsDetailCloseView;
}

//底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-48, kSCREEN_WIDTH, 48)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        UIButton *buttonCollect = [[UIButton alloc] initCustomWithFrame:CGRectMake(0, 0, 96, 48) btnTitle:@"收藏" btnImage:@"info_nav_ic_favorite" btnType:TOP bgColor:[UIColor whiteColor] titleColor:RGBTEXT titleFont:10];
        [buttonCollect setImage:[UIImage imageNamed:@"info_nav_ic_favorite_selected"] forState:UIControlStateSelected];
        [_bottomView addSubview:buttonCollect];
        self.btnCollect = buttonCollect;
        [buttonCollect addTarget:self action:@selector(btnToCollectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *buttonShare = [[UIButton alloc] initSystemWithFrame:CGRectMake(96, 0, (kSCREEN_WIDTH-96)/2, 48) btnTitle:@"分享商品" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        buttonShare.backgroundColor = RGBCOLOR(255, 194, 63);
        [_bottomView addSubview:buttonShare];
        [buttonShare addTarget:self action:@selector(btnToShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *buttonGet = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(buttonShare.frame), 0, kSCREEN_WIDTH-CGRectGetMaxX(buttonShare.frame), 48) btnTitle:@"领券购买" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        buttonGet.backgroundColor = RGBMAIN;
        [_bottomView addSubview:buttonGet];
        [buttonGet addTarget:self action:@selector(btnToGetCupponAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomView;
}

//导航栏
-(UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT)];
        _navView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.00];
        
        [_navView addSubview:self.whiteBackBtn];
        [_navView addSubview:self.titleLbl];
    }
    return _navView;
}

//白色返回按钮
-(UIButton *)whiteBackBtn{
    if (!_whiteBackBtn) {
        _whiteBackBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(10, NAVHIGHT-10-28, 32, 32) btnTitle:@"" btnImage:@"common_ic_arrow_back" titleColor:[UIColor clearColor] titleFont:0];
        _whiteBackBtn.alpha = 0;
        [_whiteBackBtn addTarget:self action:@selector(navBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _whiteBackBtn;
}

//标题
-(UILabel *)titleLbl{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(_backBtn.frame)+8, 0, kSCREEN_WIDTH-CGRectGetMaxX(_backBtn.frame)-16, 20) title:@"商品详情" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:18 textAlignment:NSTextAlignmentCenter isFit:NO];
        _titleLbl.centerY = _whiteBackBtn.centerY;
        _titleLbl.alpha = 0;
    }
    return _titleLbl;
}


//返回按钮
-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(10, NAVHIGHT-10-28, 32, 32) btnTitle:@"" btnImage:@"details_ic_back" titleColor:[UIColor clearColor] titleFont:0];
        [_backBtn addTarget:self action:@selector(navBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UIButton *)homeBtn{
    if (!_homeBtn) {
        _homeBtn = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-16-32, 0, 32, 32) btnTitle:@"" btnImage:@"detail_home" titleColor:[UIColor clearColor] titleFont:0];
        _homeBtn.centerY = _backBtn.centerY;
        [_homeBtn addTarget:self action:@selector(homeClickedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _homeBtn;
}


@end
