//
//  HDChooseStorePostViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDChooseStorePostViewController.h"

@interface HDChooseStorePostViewController ()<navViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIButton *buttonComfirn;

@property (nonatomic,strong) NSMutableArray *arrList;
@property (nonatomic,strong) NSDictionary *selDic;

@end

@implementation HDChooseStorePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrList = [NSMutableArray new];
    [self.view addSubview:self.navView];
    
    [self requestStorePostList];
}

#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//选择岗位
-(void)tapAction:(UIGestureRecognizer *)sender{
    NSInteger viewTag = sender.view.tag;
    
    for (int i=0; i<self.arrList.count; i++) {
        UIView *view = (UIView *)[_mainScrollView viewWithTag:1000+i];
        UIImageView *imgSel = (UIImageView *)[view viewWithTag:3000];
        imgSel.hidden = YES;
    }
    
    UIView *view = (UIView *)[_mainScrollView viewWithTag:viewTag];
    UIImageView *imgSel = (UIImageView *)[view viewWithTag:3000];
    imgSel.hidden = NO;
    
    self.selDic = self.arrList[viewTag-1000];
}

//确认
-(void)btnComfirnAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseStorePostAction:)]) {
        [self.delegate chooseStorePostAction:self.selDic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 数据请求
//请求门店你岗位列表
-(void)requestStorePostList{
    [MHNetworkManager postReqeustWithURL:URL_StorePostList params:@{} successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrList addObjectsFromArray:returnData[@"data"]];
            [self.view addSubview:self.mainScrollView];
            [self.view addSubview:self.buttonComfirn];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- UI

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-32-48)];
        _mainScrollView.backgroundColor = RGBBG;
        
        for (int i=0; i<self.arrList.count; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, i*55, kSCREEN_WIDTH, 55)];
            view.backgroundColor = [UIColor whiteColor];
            view.tag = 1000+i;
            
            UILabel *lblDesc = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 200, 14) title:self.arrList[i][@"desc"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            [view addSubview:lblDesc];
            lblDesc.tag = 2000;
            
            UIImageView *imageSel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_ic_selected"]];
            imageSel.x = kSCREEN_WIDTH - imageSel.width-19;
            imageSel.centerY = lblDesc.centerY;
            [view addSubview:imageSel];
            imageSel.hidden = YES;
            imageSel.tag = 3000;
            
            if (i != self.arrList.count -1) {
                UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32, 1)];
                viewLine.backgroundColor = RGBCOLOR(241, 241, 241);
                [view addSubview:viewLine];
            }
            
            //点击动作
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            view.userInteractionEnabled = YES;
            [view addGestureRecognizer:tap];
            
            [_mainScrollView addSubview:view];
            
            _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, view.bottom);
        }
    }
    return _mainScrollView;
}

//确认
-(UIButton *)buttonComfirn{
    if (!_buttonComfirn) {
        _buttonComfirn = [[UIButton alloc] initCommonWithFrame:CGRectMake(16, kSCREEN_HEIGHT-32-48, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:14];
        _buttonComfirn.layer.cornerRadius = 24;
        
        [_buttonComfirn addTarget:self action:@selector(btnComfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonComfirn;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"岗位" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}
@end
