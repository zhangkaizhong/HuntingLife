//
//  HDTaoGoodsModel.h
//  HairDress
//
//  Created by Apple on 2020/1/13.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoGoodsModel : NSObject

@property (nonatomic,copy) NSString *couponInfoMoney;
@property (nonatomic,copy) NSString *couponRemainCount;
@property (nonatomic,copy) NSString *itemUrl;
@property (nonatomic,copy) NSString *nick;
@property (nonatomic,copy) NSString *pictUrl;
@property (nonatomic,copy) NSString *profit;//预估收益
@property (nonatomic,copy) NSString *quanhoujiage;//券后价，现价
@property (nonatomic,copy) NSString *shopTitle;
@property (nonatomic,copy) NSString *size;//原价
@property (nonatomic,copy) NSString *taoId;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *tkrate3;//佣金比例：40->40%
@property (nonatomic,copy) NSString *userType;
@property (nonatomic,copy) NSString *volume;//销量
@property (nonatomic,copy) NSString *clickStatus;//是否可点击进入详情

@end

@interface HDTaoUserGoodsModel : NSObject

@property (nonatomic,copy) NSString *couponInfoMoney;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *memberType;
@property (nonatomic,copy) NSString *nick;
@property (nonatomic,copy) NSString *pictUrl;
@property (nonatomic,copy) NSString *profit;//预估收益
@property (nonatomic,copy) NSString *quanhoujiage;//券后价，现价
@property (nonatomic,copy) NSString *shopTitle;
@property (nonatomic,copy) NSString *size;//原价
@property (nonatomic,copy) NSString *taoId;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userType;
@property (nonatomic,copy) NSString *volume;//销量

@end

NS_ASSUME_NONNULL_END
