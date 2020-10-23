//
//  HDSearchShopsViewController.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/21.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDShopMsgInfoViewController.h"
#import "SDPhotoBrowser.h"

@interface HDShopMsgInfoViewController ()<SDPhotoBrowserDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *arrInfo;
@property (nonatomic,strong) NSMutableArray *arrImages;

@property (nonatomic,strong) UIView *viewHuangjingHeader;
@property (nonatomic,strong) UIView *viewImage;

@end

@implementation HDShopMsgInfoViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.arrInfo = [NSMutableArray new];
    self.arrImages = [NSMutableArray new];
    [self.arrInfo addObjectsFromArray:_shopDetailModel.configList];
    [self.arrImages addObjectsFromArray:_shopDetailModel.imgList];
    
    [self initUI];
}

- (void)initUI{

    [self.view addSubview:self.mainTableView];
}

#pragma mark -- 查看图片
-(void)tapImageAction:(UIGestureRecognizer *)sender{
    UIView *imageView = sender.view;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = imageView.tag-100;
    browser.sourceImagesContainerView = self.viewImage;
    browser.imageCount = self.arrImages.count;
    browser.delegate = self;
    [browser show];
}

#pragma mark - SDPhotoBrowserDelegate
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSURL *url = [NSURL new];
    if (index < self.arrImages.count) {
        url = self.arrImages[index];
    }
    return url;
}
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    
    UIImageView *imageView = self.viewImage.subviews[index];
    return imageView.image;
}


#pragma mark -- tableDelegate datesource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    return cell;
}

#pragma mark -- UI
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-48) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.backgroundColor = [UIColor clearColor];
        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 0)];
        [viewHeader addSubview:self.viewHuangjingHeader];
        [viewHeader addSubview:self.viewImage];
        viewHeader.height = self.viewImage.bottom;
        _mainTableView.tableHeaderView = viewHeader;
        
    }
    return _mainTableView;
}

-(UIView *)viewHuangjingHeader{
    if (!_viewHuangjingHeader) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
        headView.backgroundColor = [UIColor whiteColor];
        
        //服务标准
        UIView *viewBiaozhun = [self createTitleView:@"服务标准" frame:CGRectMake(0, 0, kSCREEN_WIDTH, 38) withView:headView];
        
        for (int i =0 ; i<self.arrInfo.count; i++) {
            
            UIView *viewInfo = [[UIView alloc] initWithFrame:CGRectMake(16, viewBiaozhun.bottom+24+i*(34+16), kSCREEN_WIDTH/2-16, 34)];
            
            //添加子控件
            NSDictionary *dic = [HDToolHelper nullDicToDic:self.arrInfo[i]];
            UIImageView *imageInfo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
            [imageInfo sd_setImageWithURL:[NSURL URLWithString:dic[@"iconUrl"]] placeholderImage:[UIImage imageNamed:@"standards_ic_01"]];
            [viewInfo addSubview:imageInfo];
            
            UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageInfo.frame)+12, 0, viewInfo.width-CGRectGetMaxX(imageInfo.frame)-12, 34) title:dic[@"configName"] bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
            lblText.numberOfLines = 0;
            [lblText sizeToFit];
            lblText.centerY = viewInfo.height/2;
            [viewInfo addSubview:lblText];
            
            viewInfo.tag = 100 + i;
            
            UIView *viewLast = (UIView *)[headView viewWithTag:100+i-1];
            if(i%2 == 1){
                viewInfo.x = kSCREEN_WIDTH/2+8;
                viewInfo.y = viewLast.y;
            }else{
                if (i==0) {
                    viewInfo.x = 16;
                    viewInfo.y = viewBiaozhun.bottom +24;
                }else{
                    viewInfo.x = 16;
                    viewInfo.y = viewLast.y+34+16;
                }
            }
            
            [headView addSubview:viewInfo];
            headView.height = viewInfo.bottom+16;
        }
        
        // 门店环境
        UIView *viewHuanjing = [self createTitleView:@"门店环境" frame:CGRectMake(0,headView.bottom, kSCREEN_WIDTH, 38) withView:headView];
        
        headView.height = viewHuanjing.bottom;
        
        _viewHuangjingHeader = headView;
    }
    return _viewHuangjingHeader;
}

//创建环境图片视图
-(UIView *)viewImage{
    if (!_viewImage) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, _viewHuangjingHeader.bottom, kSCREEN_WIDTH, 100)];
        headView.backgroundColor = [UIColor whiteColor];
        
        for (int i =0 ; i<self.arrImages.count; i++) {
            CGFloat width_img = (kSCREEN_WIDTH-32-43)/3;
            
            UIImageView *imageInfo = [[UIImageView alloc] initWithFrame:CGRectMake(16, 24+i*(100+16), width_img, width_img)];
            [imageInfo sd_setImageWithURL:[NSURL URLWithString:self.arrImages[i]]];
            
            UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            imageInfo.userInteractionEnabled = YES;
            [imageInfo addGestureRecognizer:tapImageView];
            
            imageInfo.tag = 100 + i;
            
            UIImageView *imageLast = (UIImageView *)[headView viewWithTag:100+i-1];
            
            if (i == 0) {
                imageInfo.x = 16;
                imageInfo.y = 24;
            }else{
                imageInfo.x = CGRectGetMaxX(imageLast.frame)+16;
                if (CGRectGetMaxX(imageInfo.frame)+16 > kSCREEN_WIDTH) {
                    imageInfo.x = 16;
                    imageInfo.y = CGRectGetMaxY(imageLast.frame)+16;
                }else{
                    imageInfo.y = imageLast.y;
                }
            }
            
            [headView addSubview:imageInfo];
            headView.height = imageInfo.bottom+16;
        }
        
        _viewImage = headView;
    }
    return _viewImage;
}


// 创建header label
-(UIView *)createTitleView:(NSString *)title frame:(CGRect)frame withView:(UIView *)view{
    UIView *viewBiaozhun = [[UIView alloc] initWithFrame:frame];
    viewBiaozhun.backgroundColor = RGBBG;
    [view addSubview:viewBiaozhun];
    
    UILabel *lblBiaozhun = [[UILabel alloc] initCommonWithFrame:CGRectMake(16, 12, kSCREEN_WIDTH-32, 14) title:title bgColor:[UIColor clearColor] titleColor:RGBLIGHT_TEXTINFO titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
    [viewBiaozhun addSubview:lblBiaozhun];
    return viewBiaozhun;
}



@end
