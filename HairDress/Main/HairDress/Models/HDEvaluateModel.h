//
//  HDEvaluateModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/11.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  评论模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDEvaluateModel : NSObject

@property (nonatomic, copy)   NSString  *content;
@property (nonatomic, copy)   NSString  *createTime;
@property (nonatomic, copy)   NSString  *headImg;
@property (nonatomic, copy)   NSString  *user_id;
@property (nonatomic, copy)   NSString  *phone;
@property (nonatomic, copy)   NSString  *tonyName;
@property (nonatomic, copy)   NSString  *userName;
@property (nonatomic, copy)   NSString  *totalStars;
@property (nonatomic, copy)   NSArray  *imgList;

@end

NS_ASSUME_NONNULL_END
