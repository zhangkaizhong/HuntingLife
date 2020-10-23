//
//  HDQuestionDetailViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/9.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDQuestionDetailViewController.h"

#import "HDQuestionViewModel.h"

@interface HDQuestionDetailViewController ()<navViewDelegate,WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;// 导航栏
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UILabel *lblTitle;
@property (nonatomic,strong) WKWebView *webView;

@end

@implementation HDQuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.lblTitle];
    [self.view addSubview:self.webView];
    
    [self requestDetailData];
}

#pragma mark -- UI
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"问题详情" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UILabel *)lblTitle{
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, NAVHIGHT+16*SCALE, kSCREEN_WIDTH-32*SCALE, 1) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:18*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblTitle.font = TEXT_SC_TFONT(TEXT_SC_Medium, 18*SCALE);
    }
    return _lblTitle;
}

-(WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(16*SCALE, self.lblTitle.bottom+16*SCALE, kSCREEN_WIDTH-32*SCALE, kSCREEN_HEIGHT-NAVHIGHT)];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.bounces = NO;
        [_webView setOpaque:NO];
        _webView.backgroundColor = [UIColor clearColor];
    }
    return _webView;
}

#pragma mark -- 数据请求
-(void)requestDetailData{
    [HDQuestionViewModel getQuestionDetailDataWithID:self.dic[@"id"] compelete:^(NSDictionary * _Nonnull result) {
        if ([result[@"respCode"] integerValue] == 200) {
            self.lblTitle.text = result[@"data"][@"title"];
            self.lblTitle.numberOfLines = 0;
            [self.lblTitle sizeToFit];
            
            self.webView.y = self.lblTitle.bottom+16*SCALE;
            [self.webView loadHTMLString:result[@"data"][@"content"] baseURL:nil];
        }
    }];
}

#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '270%'" completionHandler:nil];
    [webView evaluateJavaScript:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function ResizeImages() { "
     "var myimg,oldwidth;"
     "var maxwidth = 1000.0;" // WebView中显示的图片宽度
     "for(i=1;i <document.images.length;i++){"
     "myimg = document.images[i];"
     "oldwidth = myimg.width;"
     "myimg.width = maxwidth;"
     "}"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);ResizeImages();" completionHandler:nil];
}

@end
