//
//  HDWebViewController.h
//  HairDress
//
//  Created by Apple on 2020/1/14.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWebViewController : HDBaseViewController

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic,copy) NSString *url_str;
@property (nonatomic,copy) NSString *title_str;
@property (nonatomic,copy) NSString *webH5;

@end

NS_ASSUME_NONNULL_END
