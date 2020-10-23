//
//  HDMyHairListsViewController.m
//  HairDress
//
//  Created by Apple on 2019/12/26.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDMyHairListsViewController.h"

#import "HDMyHairListCollectionCell.h"
#import "HDCreateHairProViewController.h"

@interface HDMyHairListsViewController ()<navViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) HDBaseNavView * navView;  // 导航栏
@property (nonatomic,strong) UICollectionView *mainCollectView;
@property (nonatomic,strong) UIButton *buttonCreate; // 创建发型

@end

@implementation HDMyHairListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBBG;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mainCollectView];
    [self.view addSubview:self.buttonCreate];
}

#pragma mark ================== delegate /action =====================

-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

// 新建发型
-(void)createAction{
    HDCreateHairProViewController *createVC = [HDCreateHairProViewController new];
    [self.navigationController pushViewController:createVC animated:YES];
}

#pragma mark ================== collectView delegate / datasource =====================

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HDMyHairListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"haircell" forIndexPath:indexPath];
    
    return cell;
}

// item 大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = ((kSCREEN_WIDTH-32-15)/2);
    CGSize size = CGSizeMake(width, 250);
    return size;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 16, 16, 16);
}

#pragma mark ================== 加载控件 =====================

-(UICollectionView *)mainCollectView{
    if (!_mainCollectView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT) collectionViewLayout:layout];
        _mainCollectView.delegate = self;
        _mainCollectView.dataSource = self;
        _mainCollectView.backgroundColor = [UIColor clearColor];
        [_mainCollectView registerClass:[HDMyHairListCollectionCell class] forCellWithReuseIdentifier:@"haircell"];
        
        // 底部视图
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT+32+32+48,kSCREEN_WIDTH,32+32+48)];
        [_mainCollectView addSubview:footer];
        _mainCollectView.contentInset = UIEdgeInsetsMake(0, 0, 32+32+48, 0);
    }
    return _mainCollectView;
}

-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"我的发型" bgColor:RGBMAIN backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

// 新建发型
-(UIButton *)buttonCreate{
    if (!_buttonCreate) {
        _buttonCreate = [[UIButton alloc] initSystemWithFrame:CGRectMake(16, kSCREEN_HEIGHT-48-32, kSCREEN_WIDTH-32, 48) btnTitle:@"新建发型" btnImage:@"" titleColor:[UIColor whiteColor] titleFont:14];
        _buttonCreate.layer.cornerRadius = 24;
        _buttonCreate.backgroundColor = RGBMAIN;
        
        [_buttonCreate addTarget:self action:@selector(createAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCreate;
}

@end
