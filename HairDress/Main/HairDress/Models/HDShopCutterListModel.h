//
//  HDShopCutterListModel.h
//  HairDress
//
//  Created by Apple on 2020/1/7.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDShopCutterListModel : NSObject

@property (nonatomic, copy)   NSString  *headImg;//头像
@property (nonatomic, copy)   NSString  *tonyId;//tony老师id
@property (nonatomic, copy)   NSString  *storeId;//门店id
@property (nonatomic, copy)   NSString  *distance;//距离
@property (nonatomic, copy)   NSString  *userName;//tony老师名称
@property (nonatomic, copy)   NSArray  *labels;//标签集合
@property (nonatomic, copy)   NSString  *latitude;//纬度
@property (nonatomic, copy)   NSString  *longitude;//经度
@property (nonatomic, copy)   NSString  *queueNumber;//排队人数
@property (nonatomic, copy)   NSString  *serverAmount;//金额
@property (nonatomic, copy)   NSString  *serviceTenet;//服务宗旨
@property (nonatomic, copy)   NSString  *storeAddress;//门店地址
@property (nonatomic, copy)   NSString  *workingLife;//工作经验年限

@property (nonatomic, copy)   NSString  *isDetail;//是否是详情

//部分控件frame
@property (nonatomic, assign) CGRect cutterImgFrame;
@property (nonatomic, assign) CGRect viewTagsFrame;
@property (nonatomic, assign) CGRect tenetFrame;
@property (nonatomic, assign) CGRect viewAddressFrame;
@property (nonatomic, assign) CGRect viewBlockFrame;//底部分割线

@property (nonatomic, assign) CGFloat cellHeight;//行高

@end

NS_ASSUME_NONNULL_END
