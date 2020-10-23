//
//  HDHtmlViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/3/7.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDHtmlViewController.h"

@interface HDHtmlViewController ()<navViewDelegate>

@property (nonatomic,strong)HDBaseNavView *navView;//导航栏
@property (nonatomic,strong) UIScrollView *mainScrollView;


@end

@implementation HDHtmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
}

// 导航栏
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ================== 加载视图 =====================

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView=[[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"用户协议" bgColor:[UIColor clearColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UILabel *lblHtml = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 16, kSCREEN_WIDTH-32, kSCREEN_HEIGHT) title:self.textHtml bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblHtml.numberOfLines = 0;
        [lblHtml sizeToFit];
        [_mainScrollView addSubview:lblHtml];
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, lblHtml.bottom+16);
    }
    return _mainScrollView;
}

@end
