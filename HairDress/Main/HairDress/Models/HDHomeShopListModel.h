//
//  HDHomeShopListModel.h
//  HairDress
//
//  Created by Apple on 2020/1/7.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDHomeShopListModel : NSObject

@property (nonatomic, copy)   NSString  *distance;
@property (nonatomic, copy)   NSString  *storeId;
@property (nonatomic, copy)   NSString  *latitude;
@property (nonatomic, copy)   NSString  *longitude;
@property (nonatomic, copy)   NSString  *logoImg;
@property (nonatomic, copy)   NSString  *queueNumber;
@property (nonatomic, copy)   NSString  *serverAmount;
@property (nonatomic, copy)   NSString  *serverName;
@property (nonatomic, copy)   NSString  *storeAddress;
@property (nonatomic, copy)   NSString  *storeName;

@property (nonatomic, copy)   NSString  *distanceDesc;
@property (nonatomic,strong) NSArray *serviceList;


/**** frame数据 ****/
/** logoImg的frame */
@property (nonatomic, assign) CGRect logoImgFrame;
/** storeAddress的frame */
@property (nonatomic, assign) CGRect storeAddressFrame;
/** distance的frame */
@property (nonatomic, assign) CGRect distanceFrame;
/** 今日营业的frame */
@property (nonatomic, assign) CGRect openFrame;
/** line的frame */
@property (nonatomic, assign) CGRect lineFrame;
/** serviceList的frame */
@property (nonatomic, assign) CGRect serviceListFrame;

@property (nonatomic,assign) CGFloat cellHeight;

/** storeAddress的frame */
@property (nonatomic, assign) CGRect searchAddressFrame;
@property (nonatomic, assign) CGRect searchLineFrame;
@property (nonatomic,assign) CGFloat searchCellHeight;

@end

NS_ASSUME_NONNULL_END
