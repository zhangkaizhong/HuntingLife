//
//  HDSuperEquityViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDSuperEquityViewController.h"
#import <WebKit/WebKit.h>

#import "HDQuestionViewModel.h"

#import "HDWebContentTableViewCell.h"

@interface HDSuperEquityViewController ()<navViewDelegate,HDWebContentTableViewCellDelegate,WKUIDelegate,WKNavigationDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HDBaseNavView *navView;// 导航栏
@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDSuperEquityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainTableView];
    self.arrData = [NSMutableArray new];
    
    if ([self.type isEqualToString:@"1"]) {
        [HDQuestionViewModel getSuperEquityListData:^(NSDictionary * _Nonnull result) {
            if ([result[@"respCode"] integerValue] == 200) {
                NSArray *arr = [HDWebContentModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
                for (HDWebContentModel *model in arr) {
                    model.isSelect = @"0";
                }
                [self.arrData addObjectsFromArray:arr];
                [self.mainTableView reloadData];
                
            }
        }];
    }
    else{
        [HDQuestionViewModel getUserTutorialListData:^(NSDictionary * _Nonnull result) {
            if ([result[@"respCode"] integerValue] == 200) {
                NSArray *arr = [HDWebContentModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
                for (HDWebContentModel *model in arr) {
                    model.isSelect = @"0";
                }
                [self.arrData addObjectsFromArray:arr];
                [self.mainTableView reloadData];
                
            }
        }];
    }
}

#pragma mark -- UI
-(HDBaseNavView *)navView{
    if (!_navView) {
        NSString *titleStr = [self.type isEqualToString:@"1"] ? @"超级权益" : @"新手教程";
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:titleStr bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
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
        [_mainTableView registerClass:[HDWebContentTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HDWebContentTableViewCell class])];
    }
    return _mainTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDWebContentModel *model = self.arrData[indexPath.row];
    if ([model.isSelect isEqualToString:@"1"]) {
        return model.selectedCellHeight;
    }
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HDWebContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HDWebContentTableViewCell class])];
    cell.model = self.arrData[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark -- delegate action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reloadHeight:(CGFloat)cellHeight model:(HDWebContentModel *)model{
    model.selectedCellHeight = cellHeight;
    [self.mainTableView reloadData];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '250%'" completionHandler:nil];
    [webView evaluateJavaScript:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function ResizeImages() { "
     "var myimg,oldwidth;"
     "var maxwidth = 1000.0;" // UIWebView中显示的图片宽度
     "for(i=1;i <document.images.length;i++){"
     "myimg = document.images[i];"
     "oldwidth = myimg.width;"
     "myimg.width = maxwidth;"
     "}"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);ResizeImages();" completionHandler:nil];
}

@end
