//
//  ALiTradeWantViewController.m
//  ALiSDKAPIDemo
//
//  Created by com.alibaba on 16/6/1.
//  Copyright © 2016年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiTradeWebViewController.h"
#import <AlibcTradeSDK/AlibcTradeSDK.h>
#import <WindVane/WindVane.h>

//#import "ALiCartService.h"

@interface ALiTradeWebViewController()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,assign) BOOL isDone;

@end

@implementation ALiTradeWebViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        [WVURLProtocolService setSupportWKURLProtocol:YES];
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scrollView.scrollEnabled = YES;
        _webView.navigationDelegate = self;
        [self.view addSubview:_webView];
    }
    return self;
}

#pragma mark ================== delegate action =====================
-(void)navBackClicked{
    if (self.isDone) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(doAliAuthDone)]) {
            [self.delegate doAliAuthDone];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.navView];
    [SVHUDHelper showLoadingHUD];
}

#pragma mark ================== UI =====================
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"淘你喜欢" bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(void)dealloc
{
    TLOG_INFO(@"dealloc  view");
    [WVURLProtocolService setSupportWKURLProtocol:YES];
    _webView =  nil;
}

-(void)setOpenUrl:(NSString *)openUrl {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:openUrl]]];
}

-(WKWebView *)getWebView{
    return  _webView;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    //截取到当前地址
    NSString *url1 = navigationAction.request.URL.absoluteString;
    DTLog(@"%@",url1);
    if ([url1 isEqualToString:@"https://oauth.taobao.com/authorize.do"]) {
        DTLog(@"同意授权");
        self.isDone = YES;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKNavigationDelegate
- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}
 
#pragma mark 数据返回 开始在界面上显示
- (void) webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    [SVProgressHUD dismiss];
}
 
#pragma mark 数据加载完毕
- (void) webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [SVProgressHUD dismiss];
}
 
#pragma mark 加载数据错误
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [SVProgressHUD dismiss];
}

@end
