//
//  HDTaoFloorView.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoFloorView.h"

#import "HDTaoGoodsModel.h"

@interface HDTaoFloorView ()

@property (nonatomic,strong) NSMutableArray *arrList;

@property (nonatomic,weak) UILabel *timeLbl;
//楼层商品详情
@property (nonatomic,strong) NSDictionary *dicFloor;
@property (nonatomic,strong) NSDictionary *dicTimes;//当前时段商品信息
@property (nonatomic,strong) NSArray *activityListArr;//时间段数组

@property (nonatomic,assign) CGFloat offsetX;

@end

@implementation HDTaoFloorView

-(void)setArrData:(NSMutableArray *)arrData{
    _arrData = arrData;
    
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    
    self.arrList = [NSMutableArray new];
    
    for (NSDictionary *dic in arrData) {
        if (![dic[@"floorType"] isEqualToString:@"goodsType"]) {
            [self.arrList addObject:dic];
        }
    }
    
    for (int i=0;i<self.arrList.count;i++) {
        NSDictionary *dic = self.arrList[i];
        UIView *subView = [[UIView alloc] init];
        
        //横向有优惠券视图
        if ([dic[@"floorType"] isEqualToString:@"horizontalMulti"]) {
            subView = [self createHorizonView:[HDToolHelper nullDicToDic:dic]];
        }
        
        //横向无优惠券
        if ([dic[@"floorType"] isEqualToString:@"singleActivityType"]) {
            subView = [self createSingeActivityView:[HDToolHelper nullDicToDic:dic]];
        }
        
        //多活动
        if ([dic[@"floorType"] isEqualToString:@"multiActivityType"]) {
            subView = [self createMultiActivityView:[HDToolHelper nullDicToDic:dic]];
        }
        
        [self addSubview:subView];
        
        subView.tag = 100+i;
        
        if (i>0) {
            UIView *subViewLast = (UIView *)[self viewWithTag:100+i-1];
            
            subView.y = subViewLast.bottom;
        }else{
            subView.y = 0;
        }
        
        self.height = subView.bottom;
    }
}

#pragma mark ================== horizontalMulti(有优惠券横向滚动列表) =====================
-(UIView *)createHorizonView:(NSDictionary *)dic{
    
    CGFloat scroll_height = (246+10);
     
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, scroll_height)];
    view.backgroundColor = RGBBG;
    
    //title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 20, kSCREEN_WIDTH-24, 22)];
    label.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:dic[@"floorTitle"] attributes: @{NSFontAttributeName: TEXT_SC_TFONT(TEXT_SC_Medium, 21),NSForegroundColorAttributeName: RGBTEXT}];
    label.attributedText = string;
    [view addSubview:label];
    
    UIImageView *floorImageV = [[UIImageView alloc] initWithFrame:CGRectMake(12, label.bottom+14, kSCREEN_WIDTH-24, 139)];
    [view addSubview:floorImageV];
    
    if (![dic[@"floorPic"] isEqualToString:@""]) {
        [floorImageV sd_setImageWithURL:[NSURL URLWithString:dic[@"floorPic"]]];
    }else{
        floorImageV.height = 0;
    }
    
    NSArray *arrGoods = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:dic[@"goodsList"]];
    if (arrGoods.count == 0) {
        view.height = 0;
        return view;
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, label.bottom+19, kSCREEN_WIDTH, scroll_height)];
    if (![dic[@"floorPic"] isEqualToString:@""]) {
        scrollView.y = floorImageV.bottom+8;
    }else{
        scrollView.y = label.bottom + 19;
    }
    
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    [view addSubview:scrollView];
    view.height = scrollView.bottom;
    
    //创建商品
    for (int i=0; i<arrGoods.count; i++) {
        
        HDTaoGoodsModel *model = arrGoods[i];
        
        UIView *goodsView = [[UIView alloc] initWithFrame:CGRectMake(12+168*i, 0, 160, scroll_height)];
        [scrollView addSubview:goodsView];
        [self setShadowRadiusView:goodsView shadowRadius:3 offset:CGSizeMake(0,3)];
        
        goodsView.tag = [model.taoId integerValue];
        
        //点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGoodsAction:)];
        goodsView.userInteractionEnabled = YES;
        [goodsView addGestureRecognizer:tap];
        
        // 商品图片
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, goodsView.width, goodsView.width)];
        [imageV sd_setImageWithURL:[NSURL URLWithString:model.pictUrl]];
        [goodsView addSubview:imageV];
        
        //商品名称
        UILabel *lblGoodsName = [[UILabel alloc] initCommonWithFrame:CGRectMake(7, imageV.bottom+8, imageV.width-17, 20) title:model.title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [goodsView addSubview:lblGoodsName];
        
        //现价
        UILabel *lblCurrentPrice = [[UILabel alloc] initWithFrame:CGRectMake(lblGoodsName.x, lblGoodsName.bottom+8, 100, 18)];
        lblCurrentPrice.numberOfLines = 0;
        lblCurrentPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[model.quanhoujiage floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
        [lblCurrentPrice sizeToFit];
        [goodsView addSubview:lblCurrentPrice];
        
        //原价
        UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblCurrentPrice.frame)+8, 0, 100, 10) title:model.size bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblOldPrice sizeToFit];
        lblOldPrice.bottom = lblCurrentPrice.bottom-3;
        [goodsView addSubview:lblOldPrice];
        
        UIView *linePrice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 0.5)];
        linePrice.centerY = lblOldPrice.height/2;
        linePrice.backgroundColor = RGBTEXTINFO;
        [lblOldPrice addSubview:linePrice];
        
        //销量
        UILabel *lblVolume = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblGoodsName.x, lblCurrentPrice.bottom+10, 100, 12) title:[NSString stringWithFormat:@"%@人付款",model.volume] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblVolume sizeToFit];
        [goodsView addSubview:lblVolume];
        
        //优惠券
        UIImageView *imageCouponView = [[UIImageView alloc] initWithFrame:CGRectMake(goodsView.width-8-32, lblGoodsName.bottom+12, 32, 14)];
        [goodsView addSubview:imageCouponView];
        
        UILabel *lblQuan = [[UILabel alloc] initCommonWithFrame:CGRectMake(imageCouponView.width-18, 0, 16, 14) title:@"券" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        [imageCouponView addSubview:lblQuan];
        
        UILabel *lblCouponPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(7, 0, 80, 14) title:[NSString stringWithFormat:@"¥%@",model.couponInfoMoney] bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        [lblCouponPrice sizeToFit];
        lblCouponPrice.height = 14;
        [imageCouponView addSubview:lblCouponPrice];
        imageCouponView.width = 7+lblCouponPrice.width+16;
        imageCouponView.x = goodsView.width-8-imageCouponView.width;
        lblQuan.x = imageCouponView.width-16;
        
        //调整优惠券图片的大小
        UIImage *imgCoupon = [UIImage imageNamed:@"coupon_bg"];
        CGFloat imageWidth = imgCoupon.size.width;
        CGFloat imageHeight = imgCoupon.size.height;
        CGPoint centerPoint = CGPointMake(imageWidth*0.5, imageHeight*0.5);
        UIEdgeInsets insets = UIEdgeInsetsMake(centerPoint.y, centerPoint.x, imageHeight - centerPoint.y - 1, imageWidth - centerPoint.y - 1);
        imgCoupon = [imgCoupon resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        imageCouponView.image = imgCoupon;
        
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(goodsView.frame)+12*SCALE, scroll_height);
    }
    
    return view;
}

#pragma mark ================== singleActivityType(单活动无优惠券列表) =====================
-(UIView *)createSingeActivityView:(NSDictionary *)dic{
    
    CGFloat scroll_height = (109+16+20+8+18+10+12+17 +5);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, scroll_height)];
    view.backgroundColor = RGBBG;
    
    //title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 20, kSCREEN_WIDTH-24, 22)];
    label.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:dic[@"floorTitle"] attributes: @{NSFontAttributeName: TEXT_SC_TFONT(TEXT_SC_Medium, 21),NSForegroundColorAttributeName: RGBTEXT}];
    label.attributedText = string;
    [view addSubview:label];
    
    UIImageView *floorImageV = [[UIImageView alloc] initWithFrame:CGRectMake(12, label.bottom+14, kSCREEN_WIDTH-24, 139)];
    [view addSubview:floorImageV];
    
    if (![dic[@"floorPic"] isEqualToString:@""]) {
        [floorImageV sd_setImageWithURL:[NSURL URLWithString:dic[@"floorPic"]]];
    }else{
        floorImageV.height = 0;
    }
    
    NSArray *arrGoods = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:dic[@"goodsList"]];
    if (arrGoods.count == 0) {
        view.height = 0;
        return view;
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, scroll_height)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    
    if (![dic[@"floorPic"] isEqualToString:@""]) {
        scrollView.y = floorImageV.bottom+8;
    }else{
        scrollView.y = label.bottom + 19;
    }
    
    [view addSubview:scrollView];
    view.height = scrollView.bottom;
    
    //创建商品
    for (int i=0; i<arrGoods.count; i++) {
        
        HDTaoGoodsModel *model = arrGoods[i];
        
        UIView *goodsView = [[UIView alloc] initWithFrame:CGRectMake(12+117*i, 0, 117, scroll_height)];
        [scrollView addSubview:goodsView];
        goodsView.backgroundColor = [UIColor whiteColor];
        
        goodsView.tag = [model.taoId integerValue];
        
        //点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGoodsAction:)];
        goodsView.userInteractionEnabled = YES;
        [goodsView addGestureRecognizer:tap];
        
        // 商品图片
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, goodsView.width-8, goodsView.width-8)];
        [imageV sd_setImageWithURL:[NSURL URLWithString:model.pictUrl]];
        [goodsView addSubview:imageV];
        
        //商品名称
        UILabel *lblGoodsName = [[UILabel alloc] initCommonWithFrame:CGRectMake(imageV.x, imageV.bottom+16, imageV.width, 20) title:model.title bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14 textAlignment:NSTextAlignmentLeft isFit:NO];
        [goodsView addSubview:lblGoodsName];
        
        //现价
        UILabel *lblCurrentPrice = [[UILabel alloc] initWithFrame:CGRectMake(imageV.x, lblGoodsName.bottom+8, 100, 18)];
        lblCurrentPrice.numberOfLines = 0;
        lblCurrentPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥%.2f",[model.quanhoujiage floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
        [lblCurrentPrice sizeToFit];
        [goodsView addSubview:lblCurrentPrice];
        
        //原价
        UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblCurrentPrice.frame)+8, 0, 100, 10) title:model.size bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblOldPrice sizeToFit];
        lblOldPrice.bottom = lblCurrentPrice.bottom-3;
        [goodsView addSubview:lblOldPrice];
        
        UIView *linePrice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 0.5)];
        linePrice.centerY = lblOldPrice.height/2;
        linePrice.backgroundColor = RGBTEXTINFO;
        [lblOldPrice addSubview:linePrice];
        
        //销量
        UILabel *lblVolume = [[UILabel alloc] initCommonWithFrame:CGRectMake(imageV.x, lblCurrentPrice.bottom+10, 100, 12) title:[NSString stringWithFormat:@"%@人付款",model.volume] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblVolume sizeToFit];
        [goodsView addSubview:lblVolume];
        
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(goodsView.frame)+12*SCALE, scroll_height);
    }
    
    return view;
}

#pragma mark ================== multiActivityView(多活动，限时抢购) =====================
-(UIView *)createMultiActivityView:(NSDictionary *)dic{
    self.dicFloor = dic;
    
    CGFloat scroll_height = (109+16+20+8+18+10+12+17);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, scroll_height)];
    view.backgroundColor = RGBBG;
    
    //title
    UIView *viewTitle = [self createHeaderTitleView:dic[@"floorTitle"] withFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 56)];
    [view addSubview:viewTitle];
    
    //倒计时（多时段）视图
    UIView *imageViewBack = [[UIView alloc] initWithFrame:CGRectMake(0, viewTitle.bottom, kSCREEN_WIDTH, 160)];
    [view addSubview:imageViewBack];
    imageViewBack.backgroundColor = RGBMAIN;
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 160)];
    imageV.image = [UIImage imageNamed:@"bg_sale"];
    imageV.layer.masksToBounds = YES;
    [imageViewBack addSubview:imageV];
    
    //多时段scrollView
    UIScrollView *scrollTimes = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 24, kSCREEN_WIDTH, 50)];
    scrollTimes.showsHorizontalScrollIndicator = NO;
    [imageViewBack addSubview:scrollTimes];
    
    self.activityListArr = dic[@"activityList"];
    for (int i=0;i<self.activityListArr.count;i++) {
        NSDictionary *timeDic = self.activityListArr[i];
        UIView *viewTime = [[UIView alloc] initWithFrame:CGRectMake(12+i*100, 0, 88, scrollTimes.height)];
        viewTime.backgroundColor = [UIColor whiteColor];
        viewTime.layer.cornerRadius = 4;
        
        viewTime.tag = 100+i;
        
        UITapGestureRecognizer *tapTo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToTimeInfo:)];
        viewTime.userInteractionEnabled = YES;
        [viewTime addGestureRecognizer:tapTo];
        
        //开抢时间
        UILabel *lblBegainTime = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 6, viewTime.width, 20) title:timeDic[@"showTime"] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:20 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewTime addSubview:lblBegainTime];
        [lblBegainTime sizeToFit];
        lblBegainTime.width = lblBegainTime.width + 12;
        lblBegainTime.height = 20;
        viewTime.width = lblBegainTime.width;
        
        UILabel *lblIsShowText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblBegainTime.bottom+6, viewTime.width, 10) title:timeDic[@"saleStatus"] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
        [viewTime addSubview:lblIsShowText];
        //是否正在抢购
        if ([timeDic[@"isShow"] isEqualToString:@"T"]) {
            self.dicTimes = timeDic;
            viewTime.backgroundColor = [UIColor whiteColor];
            lblBegainTime.textColor = RGBMAIN;
            lblIsShowText.textColor = RGBMAIN;
            
            self.offsetX = CGRectGetMaxX(viewTime.frame)-kSCREEN_WIDTH;
            if (self.offsetX < 0) {
                self.offsetX = 0;
            }
            
        }else{
            viewTime.backgroundColor = [UIColor clearColor];
            lblBegainTime.textColor = [UIColor whiteColor];
            lblIsShowText.textColor = [UIColor whiteColor];
        }
        [scrollTimes addSubview:viewTime];
        scrollTimes.contentSize = CGSizeMake(CGRectGetMaxX(viewTime.frame)+12, scrollTimes.height);
    }
    
    //设置滚动视图偏移量
    if (scrollTimes.contentSize.width>=kSCREEN_WIDTH) {
        CGFloat maxRight = scrollTimes.contentSize.width-kSCREEN_WIDTH;
        if (self.offsetX > maxRight) {
            self.offsetX = maxRight;
        }
    }
    [scrollTimes setContentOffset:CGPointMake(self.offsetX, 0) animated:YES];
    
    //商品视图
    UIView *viewGoods = [[UIView alloc] initWithFrame:CGRectMake(12, 156, kSCREEN_WIDTH-24, 1)];
    [self setShadowRadiusView:viewGoods shadowRadius:6 offset:CGSizeMake(0,6)];
    
    [view addSubview:viewGoods];
    
    NSArray *arrGoods = [HDTaoGoodsModel mj_objectArrayWithKeyValuesArray:dic[@"goodsList"]];
    if (self.activityListArr.count == 0 && arrGoods.count == 0) {
        view.height = 0;
        return view;
    }
    if (arrGoods.count > 5) {
        arrGoods = [arrGoods subarrayWithRange:NSMakeRange(0, 5)];
    }
    //创建商品列表
    for (int i=0; i<arrGoods.count; i++) {
        HDTaoGoodsModel *model = arrGoods[i];
        
        CGFloat v_height = 12+96+14+10;
        UIView *subViewGood = [[UIView alloc] initWithFrame:CGRectMake(0, i*v_height, viewGoods.width, v_height)];
        [viewGoods addSubview:subViewGood];
        
        viewGoods.tag = [model.taoId integerValue];
        
        //点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGoodsAction:)];
        viewGoods.userInteractionEnabled = YES;
        [viewGoods addGestureRecognizer:tap];
        
        //商品图
        UIImageView *imageGood = [[UIImageView alloc] initWithFrame:CGRectMake(24, 12, 96, 96)];
        [imageGood sd_setImageWithURL:[NSURL URLWithString:model.pictUrl]];
        [subViewGood addSubview:imageGood];
        
        if (i==0) {
            subViewGood.height = 136+10;
            imageGood.y = 24;
        }
        
        //商品标题
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+12, imageGood.y, subViewGood.width-CGRectGetMaxX(imageGood.frame)-24, 20)];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.title attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: RGBTEXT}];
        lblTitle.attributedText = string;
        [subViewGood addSubview:lblTitle];
        
        //店铺图标
        UIImageView *imageShopItem = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+12, lblTitle.bottom+4, 12, 12)];
        [imageShopItem sd_setImageWithURL:[NSURL URLWithString:model.itemUrl] placeholderImage:[UIImage imageNamed:@"mall_ic_tmall"]];
        [subViewGood addSubview:imageShopItem];
        
        //店铺名称
        UILabel *lblShopName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageShopItem.frame)+4, 0, subViewGood.width-CGRectGetMaxX(imageShopItem.frame)-4-12, 12) title:model.nick bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        lblShopName.centerY = imageShopItem.centerY;
        [subViewGood addSubview:lblShopName];
        
        if (i!=0) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, 0, subViewGood.width-24, 1)];
            line.backgroundColor = RGBCOLOR(245, 245, 245);
            [subViewGood addSubview:line];
        }
        
        //现价
        UILabel *lblCurrentPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+9, imageShopItem.bottom+20, 100, 18)];
        lblCurrentPrice.numberOfLines = 0;
        lblCurrentPrice.attributedText = [[NSString alloc] setAttrText:[NSString stringWithFormat:@"¥ %.2f",[model.quanhoujiage floatValue]]  textColor:RGBMAIN setRange:NSMakeRange(0, 1) setColor:RGBMAIN];
        [lblCurrentPrice sizeToFit];
        [subViewGood addSubview:lblCurrentPrice];
        
        //原价
        UILabel *lblOldPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(lblCurrentPrice.frame)+8, 0, 100, 10) title:model.size bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:10 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblOldPrice sizeToFit];
        lblOldPrice.bottom = lblCurrentPrice.bottom-3;
        [subViewGood addSubview:lblOldPrice];
        
        UIView *linePrice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lblOldPrice.width, 0.5)];
        linePrice.centerY = lblOldPrice.height/2;
        linePrice.backgroundColor = RGBTEXTINFO;
        [lblOldPrice addSubview:linePrice];
        
        //销量
        UILabel *lblVolume = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageGood.frame)+10, lblCurrentPrice.bottom+1, 100, 12) title:[NSString stringWithFormat:@"%@人付款",model.volume] bgColor:[UIColor clearColor] titleColor:RGBTEXTINFO titleFont:12 textAlignment:NSTextAlignmentLeft isFit:NO];
        [lblVolume sizeToFit];
        lblVolume.bottom = imageGood.bottom;
        [subViewGood addSubview:lblVolume];
        
        //优惠券
        UIImageView *imageCouponView = [[UIImageView alloc] initWithFrame:CGRectMake(subViewGood.width-20-32, subViewGood.height-26-14, 32, 14)];
        [subViewGood addSubview:imageCouponView];
        
        UILabel *lblQuan = [[UILabel alloc] initCommonWithFrame:CGRectMake(imageCouponView.width-18, 0, 16, 14) title:@"券" bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        [imageCouponView addSubview:lblQuan];
        
        UILabel *lblCouponPrice = [[UILabel alloc] initCommonWithFrame:CGRectMake(7, 0, 80, 14) title:[NSString stringWithFormat:@"¥%@",model.couponInfoMoney] bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:8 textAlignment:NSTextAlignmentCenter isFit:NO];
        [lblCouponPrice sizeToFit];
        lblCouponPrice.height = 14;
        [imageCouponView addSubview:lblCouponPrice];
        imageCouponView.width = 7+lblCouponPrice.width+5+16;
        imageCouponView.x = subViewGood.width-20-imageCouponView.width;
        lblQuan.x = imageCouponView.width-16;
        
        //调整优惠券图片的大小
        UIImage *imgCoupon = [UIImage imageNamed:@"coupon_bg"];
        CGFloat imageWidth = imgCoupon.size.width;
        CGFloat imageHeight = imgCoupon.size.height;
        CGPoint centerPoint = CGPointMake(imageWidth*0.5, imageHeight*0.5);
        UIEdgeInsets insets = UIEdgeInsetsMake(centerPoint.y, centerPoint.x, imageHeight - centerPoint.y - 1, imageWidth - centerPoint.y - 1);
        imgCoupon = [imgCoupon resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        imageCouponView.image = imgCoupon;
        
        if (i==arrGoods.count-1) {
            //创建查看更多按钮
            UIButton *buttonMore = [[UIButton alloc] initCustomWithFrame:CGRectMake(12, subViewGood.bottom+8, viewGoods.width-24, 48) btnTitle:@"查看更多" btnImage:@"common_ic_arrow_right_w" btnType:RIGHTMore bgColor:[UIColor clearColor] titleColor:[UIColor whiteColor] titleFont:14];
            [buttonMore setBackgroundImage:[UIImage imageNamed:@"btn_seemore"] forState:UIControlStateNormal];
            [viewGoods addSubview:buttonMore];
            viewGoods.height = buttonMore.bottom+54;
            [buttonMore addTarget:self action:@selector(btnMoreAction) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    view.height = viewGoods.bottom;
    
    return view;
}

#pragma mark ================== 设置标题 =====================
-(UIView *)createHeaderTitleView:(NSString *)title withFrame:(CGRect)frame{
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = RGBBG;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 20, view.width-24, 22)];
    label.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title attributes: @{NSFontAttributeName: TEXT_SC_TFONT(TEXT_SC_Medium, 21),NSForegroundColorAttributeName: RGBTEXT}];
    label.attributedText = string;
    [view addSubview:label];
    
    return view;
}

#pragma mark ================== 设置视图阴影 =====================
-(void)setShadowRadiusView:(UIView *)view shadowRadius:(CGFloat)radius offset:(CGSize)size{
    view.layer.borderWidth = 1;
    view.layer.borderColor = RGBCOLOR(245, 245, 245).CGColor;

    view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    view.layer.cornerRadius = 4;
    view.layer.shadowColor = RGBAlpha(0, 0, 0, 0.06).CGColor;
    view.layer.shadowOffset = size;
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = radius;
}

#pragma mark ================== 商品点击跳转 =====================
-(void)tapGoodsAction:(UIGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickGoodsInfo:)]) {
        [self.delegate clickGoodsInfo:[NSString stringWithFormat:@"%ld",sender.view.tag]];
    }
}

//查看更多
-(void)btnMoreAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickFloorGoodsMore:dicTime:)]) {
        [self.delegate clickFloorGoodsMore:self.dicFloor dicTime:self.dicTimes];
    }
}

//点击时段活动进入活动详情
-(void)tapToTimeInfo:(UIGestureRecognizer *)sender{
    NSInteger index = sender.view.tag - 100;
    NSDictionary *dicTime = self.activityListArr[index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickFloorGoodsMore:dicTime:)]) {
        [self.delegate clickFloorGoodsMore:self.dicFloor dicTime:dicTime];
    }
}

@end
