//
//  HDWaiterInfoEditViewController.m
//  HairDress
//
//  Created by 张凯中 on 2020/2/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDWaiterInfoEditViewController.h"

#import "MHActionSheet.h"
#import "HDChooseStorePostViewController.h"
#import "HDNewPersonalViewController.h"

@interface HDWaiterInfoEditViewController ()<navViewDelegate,HDChooseStorePostDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic,strong) UIView *viewNo;//名字
@property (nonatomic,weak) UILabel *lblNo;//工号

@property (nonatomic,strong) UIView *viewName;//名字
@property (nonatomic,weak) HDTextFeild *txtName;

@property (nonatomic,strong) UIView *viewSex;//性别
@property (nonatomic,weak) UILabel *lblSex;

@property (nonatomic,strong) UIView *viewStorePost;//岗位
@property (nonatomic,weak) UILabel *lblStorePost;

@property (nonatomic,strong) UIView *viewPhone;//手机号
@property (nonatomic,weak) HDTextFeild *txtPhone;

@property (nonatomic,strong) UIView *viewTalentContent;//服务宗旨
@property (nonatomic,weak) UITextView *textTalentContent;
@property (nonatomic,weak) UILabel *lblPlaceholder;

@property (nonatomic,strong) UIButton *buttonComfirn;

@end

@implementation HDWaiterInfoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainScrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:nil];
}

#pragma mark -- delegate action

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//输入监听
-(void)textFieldDidChange:(UITextField *)textField{
    if (self.txtName.text.length > 15) {
        self.txtName.text = [self.txtName.text substringToIndex:15];
    }
}

// 评论内容
- (void)textDidChange{
    // 有文字就隐藏
    if (self.textTalentContent.text.length == 0) {
        self.lblPlaceholder.hidden = NO;
    }else{
        self.lblPlaceholder.hidden = YES;
    }
    
}

// 修改性别
-(void)tapSexAction:(UIGestureRecognizer *)sender{
    WeakSelf;
    MHActionSheet *actionSheet = [[MHActionSheet alloc] initSheetWithTitle:nil style:MHSheetStyleWeiChat itemTitles:@[@"男",@"女"]];
        [actionSheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
            NSLog(@"%@",title);
            weakSelf.lblSex.text = title;
            
            if ([weakSelf.txtName.text isEqualToString:@""] || [weakSelf.lblSex.text isEqualToString:@"请选择"]) {
                [weakSelf.buttonComfirn setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
                weakSelf.buttonComfirn.userInteractionEnabled = NO;
                weakSelf.buttonComfirn.backgroundColor = RGBCOLOR(230, 230, 230);
            }else{
                [weakSelf.buttonComfirn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                weakSelf.buttonComfirn.userInteractionEnabled = YES;
                weakSelf.buttonComfirn.backgroundColor = RGBMAIN;
            }
    }];
}

// 选择岗位
-(void)tapStorePostAction:(UIGestureRecognizer *)sender{
    HDChooseStorePostViewController *postVC = [HDChooseStorePostViewController new];
    postVC.delegate = self;
    [self.navigationController pushViewController:postVC animated:YES];
}

//选择岗位代理
-(void)chooseStorePostAction:(NSDictionary *)storePostDic{
    self.lblStorePost.text = storePostDic[@"desc"];
    
    if ([self.txtName.text isEqualToString:@""] || [self.lblSex.text isEqualToString:@"请选择"]) {
        [self.buttonComfirn setTitleColor:RGBTEXTINFO forState:UIControlStateNormal];
        self.buttonComfirn.userInteractionEnabled = NO;
        self.buttonComfirn.backgroundColor = RGBCOLOR(230, 230, 230);
    }else{
        [self.buttonComfirn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buttonComfirn.userInteractionEnabled = YES;
        self.buttonComfirn.backgroundColor = RGBMAIN;
    }
}

//确定
-(void)btnComfirnAction{
    if (![self.txtPhone.text isPhoneNo] ) {
        [SVHUDHelper showWorningMsg:@"手机号码有误" timeInt:1];
        return;
    }
    [self updateInfoReqeust];
}

#pragma mark -- 数据请求
//修改资料
-(void)updateInfoReqeust{
    WeakSelf;
    if ([self.txtName.text isEqualToString:@""]) {
        [SVHUDHelper showWorningMsg:@"请输入名字" timeInt:1];
        return;
    }
    if ([self.textTalentContent.text isEqualToString:@""]) {
        [SVHUDHelper showWorningMsg:@"请输入服务宗旨" timeInt:1];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[HDUserDefaultMethods getData:@"userId"] forKey:@"tonyId"];
    [params setValue:self.txtName.text forKey:@"userName"];
    [params setValue:self.textTalentContent.text forKey:@"serviceTenet"];
    [MHNetworkManager postReqeustWithURL:URL_StoreEditTony params:params successBlock:^(NSDictionary *returnData) {
        returnData = [HDToolHelper nullDicToDic:returnData];
        if ([returnData[@"respCode"] integerValue] == 200) {
            [HDUserDefaultMethods saveData:self.txtName.text andKey:@"userName"];
            [HDUserDefaultMethods saveData:self.textTalentContent.text andKey:@"serviceTenet"];
            [SVHUDHelper showWorningMsg:@"保存成功" timeInt:1];
            [HDToolHelper delayMethodFourGCD:1 method:^{
                for (UIViewController *viewCon in self.navigationController.viewControllers) {
                    if ([viewCon isKindOfClass:[HDNewPersonalViewController class]]) {
                        HDNewPersonalViewController *personVC = (HDNewPersonalViewController *)viewCon;
                        [weakSelf.navigationController popToViewController:personVC animated:YES];
                    }
                }
            }];
        }else{
            [SVHUDHelper showWorningMsg:returnData[@"respMsg"] timeInt:1];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- UI

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = RGBBG;
        
        [_mainScrollView addSubview:self.viewNo];
        [_mainScrollView addSubview:self.viewName];
        [_mainScrollView addSubview:self.viewSex];
//        [_mainScrollView addSubview:self.viewStorePost];
        [_mainScrollView addSubview:self.viewPhone];
        [_mainScrollView addSubview:self.viewTalentContent];
        [_mainScrollView addSubview:self.buttonComfirn];
        
        _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, self.buttonComfirn.bottom);
    }
    return _mainScrollView;
}

//工号
-(UIView *)viewNo{
    if (!_viewNo) {
        _viewNo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 37)];
        _viewNo.backgroundColor = RGBBG;
        
        UILabel *lblNo = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 37) title:[NSString stringWithFormat:@"工号：%@",[HDUserDefaultMethods getData:@"userId"]] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewNo addSubview:lblNo];
        self.lblNo = lblNo;
    }
    return _viewNo;
}

// 名字
-(UIView *)viewName{
    if (!_viewName) {
        _viewName = [[UIView alloc] initWithFrame:CGRectMake(0, _viewNo.bottom, kSCREEN_WIDTH, 55)];
        _viewName.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"名字" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewName addSubview:lblText];
        
        // 名字
        HDTextFeild *txtName = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10, 14)];
        txtName.textAlignment = NSTextAlignmentRight;
        txtName.placeholder = @"请输入名字";
        txtName.textColor = RGBTEXTINFO;
        txtName.font = [UIFont systemFontOfSize:14];
        [txtName addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        self.txtName = txtName;
        txtName.centerY = lblText.centerY;
        [_viewName addSubview:self.txtName];
        if (![[HDUserDefaultMethods getData:@"userName"] isEqualToString:@""]) {
            self.txtName.text = [HDUserDefaultMethods getData:@"userName"];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewName addSubview:line];
    }
    return _viewName;
}

// 性别
-(UIView *)viewSex{
    if (!_viewSex) {
        _viewSex = [[UIView alloc] initWithFrame:CGRectMake(0, _viewName.bottom, kSCREEN_WIDTH, 55)];
        _viewSex.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"性别" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewSex addSubview:lblText];
        
//        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
//        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
//        [_viewSex addSubview:imageGo];
//        imageGo.centerY = lblText.centerY;
        
        // 性别
        NSString *gender = @"保密";
        if ([[HDUserDefaultMethods getData:@"gender"] integerValue] == 1) {
            gender = @"男";
        }else if ([[HDUserDefaultMethods getData:@"gender"] integerValue] == 2){
            gender = @"女";
        }
        UILabel *lblSex = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10, 14) title:gender bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblSex = lblSex;
        lblSex.centerY = lblText.centerY;
        [_viewSex addSubview:self.lblSex];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSexAction:)];
//        _viewSex.userInteractionEnabled = YES;
//        [_viewSex addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewSex addSubview:line];

    }
    return _viewSex;
}

// 岗位
-(UIView *)viewStorePost{
    if (!_viewStorePost) {
        _viewStorePost = [[UIView alloc] initWithFrame:CGRectMake(0, _viewSex.bottom, kSCREEN_WIDTH, 55)];
        _viewStorePost.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"岗位" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewStorePost addSubview:lblText];
        
        UIImageView *imageGo = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-16-24, 0, 24, 24)];
        imageGo.image = [UIImage imageNamed:@"common_ic_arrow_right_g"];
        [_viewStorePost addSubview:imageGo];
        imageGo.centerY = lblText.centerY;
        
        // 岗位
        UILabel *lblStorePost = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-24-16-CGRectGetMaxX(lblText.frame)-10, 14) title:@"请选择" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentRight isFit:NO];
        self.lblStorePost = lblStorePost;
        lblStorePost.centerY = lblText.centerY;
        [_viewStorePost addSubview:self.lblStorePost];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStorePostAction:)];
        _viewStorePost.userInteractionEnabled = YES;
        [_viewStorePost addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewStorePost addSubview:line];

    }
    return _viewStorePost;
}

// 手机号码
-(UIView *)viewPhone{
    if (!_viewPhone) {
        _viewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, _viewSex.bottom, kSCREEN_WIDTH, 55)];
        _viewPhone.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, 100, 14) title:@"手机号码" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewPhone addSubview:lblText];
        
        // 手机号码
        HDTextFeild *txtPhone = [[HDTextFeild alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lblText.frame)+10, 0, kSCREEN_WIDTH-16-CGRectGetMaxX(lblText.frame)-10, 14)];
        txtPhone.textAlignment = NSTextAlignmentRight;
        txtPhone.placeholder = @"请输入手机号码";
        txtPhone.textColor = RGBTEXTINFO;
        txtPhone.font = [UIFont systemFontOfSize:14];
        [txtPhone addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        self.txtPhone = txtPhone;
        txtPhone.centerY = lblText.centerY;
        txtPhone.userInteractionEnabled = NO;
        [_viewPhone addSubview:self.txtPhone];
        if (![[HDUserDefaultMethods getData:@"phone"] isEqualToString:@""]) {
            self.txtPhone.text = [HDUserDefaultMethods getData:@"phone"];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 54, kSCREEN_WIDTH-32,1)];
        line.backgroundColor = RGBCOLOR(241, 241, 241);
        [_viewPhone addSubview:line];
    }
    return _viewPhone;
}

//评论内容
-(UIView *)viewTalentContent{
    if (!_viewTalentContent) {
        _viewTalentContent = [[UIView alloc] initWithFrame:CGRectMake(0, _viewPhone.bottom, kSCREEN_WIDTH, 48+54)];
        _viewTalentContent.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblTalentText = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 20, kSCREEN_WIDTH-32, 14) title:@"服务宗旨" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [_viewTalentContent addSubview:lblTalentText];

        UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(10, lblTalentText.bottom+6, _viewTalentContent.width-32, 64)];
        txt.font = [UIFont systemFontOfSize:14];
        [_viewTalentContent addSubview:txt];
        self.textTalentContent = txt;
        
        UILabel *placelbl = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, lblTalentText.bottom+16, _viewTalentContent.width-32, 14) title:@"请输入服务宗旨" bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        self.lblPlaceholder = placelbl;
        [_viewTalentContent addSubview:self.lblPlaceholder];
        
        if (![[HDUserDefaultMethods getData:@"serviceTenet"] isEqualToString:@""]) {
            self.textTalentContent.text = [HDUserDefaultMethods getData:@"serviceTenet"];
            self.lblPlaceholder.hidden = YES;
        }
        
        _viewTalentContent.height = _textTalentContent.bottom;
        
    }
    return _viewTalentContent;
}

//确认
-(UIButton *)buttonComfirn{
    if (!_buttonComfirn) {
        _buttonComfirn = [[UIButton alloc] initCommonWithFrame:CGRectMake(16, kSCREEN_HEIGHT-NAVHIGHT-32-48, kSCREEN_WIDTH-32, 48) btnTitle:@"确定" bgColor:RGBMAIN titleColor:[UIColor whiteColor] titleFont:14];
        _buttonComfirn.layer.cornerRadius = 24;
        
//        _buttonComfirn.userInteractionEnabled = NO;
//        _buttonComfirn.backgroundColor = RGBCOLOR(230, 230, 230);
        
        [_buttonComfirn addTarget:self action:@selector(btnComfirnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonComfirn;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"编辑员工信息" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DTLog(@"%s",__FUNCTION__);
}

@end
