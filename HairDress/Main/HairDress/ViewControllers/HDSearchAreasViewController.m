//
//  HDSearchAreasViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/4.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDSearchAreasViewController.h"

#import "UITableView+SCIndexView.h"
#import "SCIndexViewHeaderView.h"
#import "BMChineseSort.h"
#import "HDAreasModel.h"

@interface HDSearchAreasViewController ()<navViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *firstLetterArray;

@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,weak) UILabel *lblLocationCity;

@end

@implementation HDSearchAreasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    self.dataArr = [NSMutableArray new];
    self.firstLetterArray = [NSMutableArray new];
    
    [MHNetworkManager postReqeustWithURL:URL_AreasFindAll params:@{} successBlock:^(NSDictionary *returnData) {
        NSLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            NSArray *arr = [HDAreasModel mj_objectArrayWithKeyValuesArray:returnData[@"data"]];
            
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2;
            //排序
            [BMChineseSort sortAndGroup:arr key:@"name" finish:^(bool isSuccess, NSMutableArray *unGroupedArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.firstLetterArray = sectionTitleArr;
                    [self.dataArr addObjectsFromArray:sortedObjArr];
                    
                    self.mainTableView.sc_indexViewDataSource = self.firstLetterArray;//索引
//                    self.mainTableView.sc_startSection = 0;
                    
                    [self.mainTableView reloadData];
                }
            }];
            
            
        }
    } failureBlock:^(NSError *error) {

    } showHUD:YES];
}


#pragma mark ================== delegate action =====================
-(void)navRightClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ================== tableView delegate datasource =====================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArr[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.firstLetterArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    HDAreasModel *model = self.dataArr[indexPath.section][indexPath.row];
    cell.textLabel.text = model.name;
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = RGBTEXT;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 46, kSCREEN_WIDTH-32, 1)];
    line.backgroundColor = RGBCOLOR(241, 241, 241);
    [cell.contentView addSubview:line];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 90+164+32;
//    }
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 46)];

    viewHeader.backgroundColor = [UIColor whiteColor];

    UILabel *lbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 12) title:@"" bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
    lbl.text = [self.firstLetterArray objectAtIndex:section];
    [viewHeader addSubview:lbl];

    return viewHeader;
}

#pragma mark ================== 懒加载 =====================
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initSearchBarWithButtonsFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) bgColor:[UIColor whiteColor] textColor:[UIColor clearColor] searchViewColor:RGBBG btnTitle:@"取消" placeHolder:@"输入城市名或拼音" theDelegate:self];
    }
    return _navView;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        
        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        
        SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
        _mainTableView.sc_indexViewConfiguration = configuration;
        _mainTableView.sc_indexViewConfiguration.indicatorBackgroundColor = RGBMAIN;
        _mainTableView.sc_indexViewConfiguration.indicatorTextFont = [UIFont systemFontOfSize:14];
        _mainTableView.sc_indexViewConfiguration.indexItemSelectedBackgroundColor = RGBMAIN;
        
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _mainTableView.tableHeaderView = self.headerView;
    }
    return _mainTableView;
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 90+164+32)];
        
        UIView *viewLocation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 82)];
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, 12) title:@"当前定位" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [viewLocation addSubview:lblText];
        
        [_headerView addSubview:viewLocation];
        
        UIImageView *imageLocation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_ic_location"]];
        imageLocation.x = 16;
        imageLocation.y = 43;
        [viewLocation addSubview:imageLocation];
        
        UILabel *lblLocationCity = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageLocation.frame)+4, 0, kSCREEN_WIDTH/2, 14) title:@"厦门市" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblLocationCity.centerY = imageLocation.centerY;
        [viewLocation addSubview:lblLocationCity];
        self.lblLocationCity = lblLocationCity;
        
        UIButton *buttonLoc = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-12-55, 0, 55, 12) btnTitle:@"重新定位" btnImage:@"" titleColor:RGBMAIN titleFont:12];
        buttonLoc.centerY = imageLocation.centerY;
        [viewLocation addSubview:buttonLoc];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, viewLocation.bottom, kSCREEN_WIDTH, 8)];
        line.backgroundColor = RGBBG;
        [_headerView addSubview:line];
        
        UILabel *lblTextHot = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, line.bottom+16, kSCREEN_WIDTH-32, 12) title:@"热门城市" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_headerView addSubview:lblTextHot];
        
        //热门城市
        NSArray *hotCitysArr = @[@"上海",@"北京",@"杭州",@"广州",@"成都",@"苏州",@"深圳",@"南京",@"天津",@"重庆",@"武汉",@"西安"];
        
        for (int i=0; i<hotCitysArr.count; i++) {
            
            CGFloat width_btn = (kSCREEN_WIDTH-32-32)/3;
            CGFloat height_btn = 32;
            
            UIButton *btn = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, lblTextHot.bottom+i*(100+16), width_btn, height_btn) btnTitle:hotCitysArr[i] btnImage:@"" titleColor:RGBTEXT titleFont:12];
            
            btn.tag = 100 + i;
            
            btn.layer.cornerRadius = 4;
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = RGBBtnLayer.CGColor;
            
            UIView *imageLast = (UIView *)[_headerView viewWithTag:100+i-1];
            
            if (i == 0) {
                btn.x = 16;
                btn.y = lblTextHot.bottom+16;
            }else{
                btn.x = CGRectGetMaxX(imageLast.frame)+16;
                if (CGRectGetMaxX(btn.frame)+15 > kSCREEN_WIDTH) {
                    btn.x = 16;
                    btn.y = CGRectGetMaxY(imageLast.frame)+8;
                }else{
                    btn.y = imageLast.y;
                }
            }
            
            [_headerView addSubview:btn];
            _headerView.height = btn.bottom+16;
        }
    }
    return _headerView;
}


@end
