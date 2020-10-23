//
//  HDTaoDetailInfoModel.h
//  HairDress
//
//  Created by Apple on 2020/1/16.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoDetailInfoModel : NSObject

@property (nonatomic,copy) NSString *couponEndTime;
@property (nonatomic,copy) NSString *couponInfoMoney;
@property (nonatomic,copy) NSString *couponStartTime;
@property (nonatomic,copy) NSString *couponStatus;
@property (nonatomic,copy) NSString *jianjie;//简介
@property (nonatomic,copy) NSString *linkUrl;
@property (nonatomic,copy) NSString *pictUrl;
@property (nonatomic,copy) NSString *profit;
@property (nonatomic,copy) NSString *quanhouJiage;
@property (nonatomic,copy) NSString *score1;
@property (nonatomic,copy) NSString *score2;
@property (nonatomic,copy) NSString *score3;
@property (nonatomic,copy) NSString *shopIcon;
@property (nonatomic,copy) NSString *shopTitle;
@property (nonatomic,copy) NSString *size;
@property (nonatomic,copy) NSString *smallImages;
@property (nonatomic,copy) NSString *taoId;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *tkrate3;
@property (nonatomic,copy) NSString *typeOneId;
@property (nonatomic,copy) NSString *userType;
@property (nonatomic,copy) NSString *videoPic;
@property (nonatomic,copy) NSString *volume;
@property (nonatomic,copy) NSString *whiteImage;
@property (nonatomic,copy) NSString *zhiboUrl;
@property (nonatomic,copy) NSString *pcDescContent;

@property (nonatomic,strong) NSArray *contentImages;
@property (nonatomic,strong) NSArray *smallImagesArr;

@end

NS_ASSUME_NONNULL_END
