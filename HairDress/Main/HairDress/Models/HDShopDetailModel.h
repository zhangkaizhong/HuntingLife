//
//  HDShopDetailModel.h
//  HairDress
//
//  Created by Apple on 2020/1/7.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDShopDetailModel : NSObject

@property (nonatomic, strong)   NSArray  *configList;
@property (nonatomic, strong)   NSArray  *imgList;
@property (nonatomic, copy)   NSString  *endTime;
@property (nonatomic, copy)   NSString  *environmentScore;
@property (nonatomic, copy)   NSString  *storeId;
@property (nonatomic, copy)   NSString  *serviceScore;
@property (nonatomic, copy)   NSString  *startTime;
@property (nonatomic, copy)   NSString  *storeAddress;
@property (nonatomic, copy)   NSString  *storeName;
@property (nonatomic, copy)   NSString  *logoImg;

@property (nonatomic, copy)   NSString  *latitude;
@property (nonatomic, copy)   NSString  *longitude;

@end

NS_ASSUME_NONNULL_END
