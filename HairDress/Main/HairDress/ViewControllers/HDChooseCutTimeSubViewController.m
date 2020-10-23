//
//  HDCancelCutQueneViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDChooseCutTimeSubViewController.h"

@interface HDChooseCutTimeSubViewController ()

@property (nonatomic,strong) UIScrollView *mainScrollView; // 主视图
@property (nonatomic,strong) UIView *viewBtns;

@property (nonatomic,strong) NSMutableArray *arrData;

@end

@implementation HDChooseCutTimeSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrData = [NSMutableArray new];
    [self getTimeList];
}

#pragma mark ================== delegate / action =====================

// 选择时间段
-(void)btnChooseTypeAction:(UIButton *)sender{
    sender.selected=!sender.selected;
    
    NSInteger index = sender.tag - 100;
    NSDictionary *dicSel = self.arrData[index];
    if ([dicSel[@"yuyueFlag"] isEqualToString:@"F"]) {
        return;
    }
    
    for (int i=0; i<self.arrData.count; i++) {
        NSDictionary *dicSel = self.arrData[i];
        if ([dicSel[@"yuyueFlag"] isEqualToString:@"F"]) {
            continue;
        }
        UIButton *btn = (UIButton *)[self.mainScrollView viewWithTag:100+i];
        btn.layer.borderColor = RGBSUBTITLE.CGColor;
        btn.backgroundColor = [UIColor whiteColor];
        UILabel *lblTime = (UILabel *)[btn viewWithTag:1000];
        UILabel *lblContent = (UILabel *)[btn viewWithTag:2000];
        lblTime.textColor = RGBTEXT;
        lblContent.textColor = RGBTEXT;
    }
    
    sender.backgroundColor = [RGBMAIN colorWithAlphaComponent:0.08];
    sender.layer.borderColor = RGBMAIN.CGColor;
    UILabel *lblTime = (UILabel *)[sender viewWithTag:1000];
    UILabel *lblContent = (UILabel *)[sender viewWithTag:2000];
    lblTime.textColor = RGBMAIN;
    lblContent.textColor = RGBMAIN;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectTime:timeType:)]) {
        [self.delegate didSelectTime:dicSel timeType:self.timeType];
    }
}

//重置选中状态
-(void)reloadBtnSelectedStatus{
    for (int i=0; i<self.arrData.count; i++) {
        NSDictionary *dicSel = self.arrData[i];
        if ([dicSel[@"yuyueFlag"] isEqualToString:@"F"]) {
            continue;
        }
        UIButton *btn = (UIButton *)[self.mainScrollView viewWithTag:100+i];
        btn.layer.borderColor = RGBSUBTITLE.CGColor;
        btn.backgroundColor = [UIColor whiteColor];
        UILabel *lblTime = (UILabel *)[btn viewWithTag:1000];
        UILabel *lblContent = (UILabel *)[btn viewWithTag:2000];
        lblTime.textColor = RGBTEXT;
        lblContent.textColor = RGBTEXT;
    }
}

// 确定
-(void)btnComfirnAction{
    
}

//获取取消原因列表
-(void)getTimeList{
    if (!self.storeID) {
        return;
    }
    [MHNetworkManager postReqeustWithURL:URL_YuyueStoreTimeList params:@{@"storeId":self.storeID,@"timeType":self.timeType} successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.arrData removeAllObjects];
            [self.arrData addObjectsFromArray:returnData[@"data"][@"voList"]];
            [self.view addSubview:self.mainScrollView];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark ================== 加载控件 =====================

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-57*SCALE)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        UIView *viewBtns = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 300)];
        [_mainScrollView addSubview:viewBtns];
        viewBtns.backgroundColor = [UIColor whiteColor];
        self.viewBtns = viewBtns;
        
        // 添加按钮
        for (int i = 0; i<self.arrData.count; i++) {
            NSDictionary *dic = self.arrData[i];
            NSString *btnTimeStr = [NSString stringWithFormat:@"%@-%@",dic[@"startTime"],dic[@"endTime"]];
            UIButton *button = [[UIButton alloc] initCustomWithFrame:CGRectMake(24*SCALE, i*(64*SCALE+16*SCALE), (kSCREEN_WIDTH-48*SCALE-31*SCALE)/2, 64*SCALE) btnTitle:@"" btnImage:@"" btnType:RIGHT_DOWN bgColor:[UIColor whiteColor] titleColor:RGBTEXT titleFont:0];
            button.tag = 100+i;
            
            UILabel *lblTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 16*SCALE, button.width, 14*SCALE) title:btnTimeStr bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
            lblTime.tag = 1000;
            [button addSubview:lblTime];
            UILabel *lblTimeContent = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTime.bottom+12*SCALE, button.width, 10*SCALE) title:dic[@"timeContent"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:10*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
            lblTimeContent.tag = 2000;
            [button addSubview:lblTimeContent];
            
            if ([dic[@"yuyueFlag"] isEqualToString:@"F"]) {
                button.backgroundColor = RGBCOLOR(239, 239, 239);
                lblTime.textColor = RGBCOLOR(153, 153, 153);
                lblTimeContent.textColor = RGBCOLOR(153, 153, 153);
            }else{
                button.backgroundColor = [UIColor whiteColor];
                button.layer.borderWidth = 1;
                button.layer.borderColor = RGBSUBTITLE.CGColor;
            }
            button.layer.cornerRadius = 4;
            
            UIButton *btnLast = (UIButton *)[viewBtns viewWithTag:100+i-1];
            if(i%2 == 1){
                button.x = kSCREEN_WIDTH/2+31/2;
                button.y = btnLast.y;
            }else{
                if (i==0) {
                    button.x = 16*SCALE;
                    button.y = 25*SCALE;
                }else{
                    button.x = 16*SCALE;
                    button.y = btnLast.y+64*SCALE+16*SCALE;
                }
            }
            [button addTarget:self action:@selector(btnChooseTypeAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [viewBtns addSubview:button];
            viewBtns.height = button.bottom+40*SCALE;
        }
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewBtns.bottom+32);
        
    }
    return _mainScrollView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

@end
