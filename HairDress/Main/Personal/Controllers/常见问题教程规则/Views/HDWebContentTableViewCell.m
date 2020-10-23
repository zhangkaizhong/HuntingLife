//
//  HDWebContentTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDWebContentTableViewCell.h"
#import <WebKit/WebKit.h>

@interface HDWebContentTableViewCell ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong)WKWebView *webView;
@property (nonatomic,strong)UIButton *btnArrow;
@property (nonatomic,strong)UILabel *lblTitle;

@property (nonatomic,assign)CGFloat cellHeight;

@end

@implementation HDWebContentTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.lblTitle];
        [self.contentView addSubview:self.btnArrow];
        [self.contentView addSubview:self.webView];
    }
    return self;
}

-(void)setModel:(HDWebContentModel *)model{
    _model = model;
    _lblTitle.text = _model.title;
    _lblTitle.width = kSCREEN_WIDTH-56*SCALE;
    [_lblTitle sizeToFit];
    
    [_webView loadHTMLString:_model.content baseURL:nil];
    if ([_model.isSelect isEqualToString:@"1"]) {
        _webView.height = _model.selectedCellHeight - self.lblTitle.bottom - 20*SCALE-20*SCALE;
    }
    else{
        _webView.height = 0;
    }
}

-(UILabel *)lblTitle{
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 20*SCALE, kSCREEN_WIDTH-56*SCALE, 16*SCALE) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        _lblTitle.numberOfLines = 0;
    }
    return _lblTitle;
}

-(UIButton *)btnArrow{
    if (!_btnArrow) {
        _btnArrow = [[UIButton alloc] initSystemWithFrame:CGRectMake(kSCREEN_WIDTH-40*SCALE, 0, 30*SCALE, 30*SCALE) btnTitle:@"" btnImage:@"problem_ic_down" titleColor:[UIColor clearColor] titleFont:0];
        _btnArrow.centerY = _lblTitle.centerY;
        [_btnArrow addTarget:self action:@selector(btnCheckContentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnArrow;
}

-(WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(16*SCALE, _lblTitle.bottom+20*SCALE, kSCREEN_WIDTH-32*SCALE, 0)];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.scrollEnabled = NO;
        [_webView setOpaque:NO];
        _webView.backgroundColor = [UIColor clearColor];
    }
    return _webView;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '250%'" completionHandler:nil];
//    [webView evaluateJavaScript:@"var script = document.createElement('script');"
//     "script.type = 'text/javascript';"
//     "script.text = \"function ResizeImages() { "
//     "var myimg,oldwidth;"
//     "var maxwidth = 1000.0;" // UIWebView中显示的图片宽度
//     "for(i=1;i <document.images.length;i++){"
//     "myimg = document.images[i];"
//     "oldwidth = myimg.width;"
//     "myimg.width = maxwidth;"
//     "}"
//     "}\";"
//     "document.getElementsByTagName('head')[0].appendChild(script);ResizeImages();" completionHandler:nil];
    
    // 获取webView的高度
    WeakSelf;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          
          [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result,NSError*_Nullable error) {
              
              CGFloat web_h = [result floatValue];
              weakSelf.cellHeight = web_h + weakSelf.lblTitle.bottom + 40*SCALE;
              
          }];
     });
    
}

-(void)btnCheckContentAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"problem_ic_up"] forState:UIControlStateNormal];
        _model.isSelect = @"1";
    }else{
        [sender setImage:[UIImage imageNamed:@"problem_ic_down"] forState:UIControlStateNormal];
        _model.isSelect = @"0";
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadHeight:model:)]) {
        [self.delegate reloadHeight:_cellHeight model:_model];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.lblTitle.frame = self.model.titleFrame;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
