//
//  HDBaseViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDBaseViewController.h"

@interface HDBaseViewController ()

@property (nonatomic,weak) UILabel *lblEmpty;

@end

@implementation HDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewEmpty.hidden = YES;
    
    //网络监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoadDataBase:) name:KLoadDataBase object:nil];
}

-(UIView *)viewEmpty{
    if (!_viewEmpty) {
        _viewEmpty = [[UIView alloc] initWithFrame:CGRectMake(0, NAVHIGHT+72, kSCREEN_WIDTH, 100)];
        _viewEmpty.backgroundColor = [UIColor clearColor];
        _viewEmpty.hidden = YES;
        
        UIImageView *imageEmpty = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_ic_default"]];
        imageEmpty.centerX = kSCREEN_WIDTH/2;
        imageEmpty.y = 0;
        [_viewEmpty addSubview:imageEmpty];
        
        UILabel *lblEmpty = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, imageEmpty.bottom+16, kSCREEN_WIDTH, 14) title:@"暂无数据" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentCenter isFit:NO];
        [_viewEmpty addSubview:lblEmpty];
        self.lblEmpty = lblEmpty;
        
        _viewEmpty.height = lblEmpty.bottom;
    }
    return _viewEmpty;
}

-(void)setEmptyStr:(NSString *)emptyStr{
    _emptyStr = emptyStr;
    
    self.lblEmpty.text = emptyStr;
}

//重新加载数据
- (void)getLoadDataBase:(NSNotification *)text{
    DTLog(@"开始重新加载网络");
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter ]removeObserver:self name:KLoadDataBase object:nil];
}

@end
