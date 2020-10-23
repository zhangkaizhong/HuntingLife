//
//  HDWebViewController.m
//  HairDress
//
//  Created by Apple on 2020/1/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDWebViewController.h"

@interface HDWebViewController ()<navViewDelegate,WKUIDelegate, WKNavigationDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;

//网页加载进度视图
@property (nonatomic, strong) UIProgressView * progressView;

@end

@implementation HDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    
    [self.view addSubview:self.navView];
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
//    [SVHUDHelper showLoadingHUD];
}

#pragma mark ================== delegate action =====================
-(void)navBackClicked{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//刷新
-(void)navRightClicked{
    [_webView reload];
}

//关闭
-(void)navCloseClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WKNavigationDelegate
- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}
 
#pragma mark 数据返回 开始在界面上显示
- (void) webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
    
}
 
#pragma mark 数据加载完毕
- (void) webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
}
 
#pragma mark 加载数据错误
- (void) webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error{
    
}

#pragma mark ================== UI =====================
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:self.title_str bgColor:[UIColor whiteColor] backBtn:YES rightBtn:@"" rightBtnImage:@"shuaxin_black" theDelegate:self];
    }
    return _navView;
}

#pragma mark - KVO
//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {
        
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
        
    }else if([keyPath isEqualToString:@"title"]
             && object == _webView){
        self.navigationItem.title = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


#pragma mark - Getter
- (UIProgressView *)progressView {
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, 2)];
        _progressView.tintColor = RGBMAIN;
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

- (WKWebView *)webView{
    if(!_webView){
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        
        if (self.url_str) {
            NSURL *url = [NSURL URLWithString:self.url_str];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [_webView loadRequest:request];
        }
        else{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"register.html" ofType:nil];
              NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            //加载本地html文件
              [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        }
    }
    return _webView;
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
//    UIEdgeInsets insets = self.view.safeAreaInsets;
    self.progressView.frame = CGRectMake(0, NAVHIGHT, self.view.frame.size.width, 2);
}

- (void)dealloc{
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
}

@end
