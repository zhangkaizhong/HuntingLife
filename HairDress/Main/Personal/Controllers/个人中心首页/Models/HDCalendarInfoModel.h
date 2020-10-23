//
//  HDCalendarInfoModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/4/30.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDCalendarInfoModel : NSObject

@property (nonatomic, copy) NSString *createLongTime;
@property (nonatomic, copy) NSString *headImg;
@property (nonatomic, copy) NSString *serviceNum;
@property (nonatomic, copy) NSString *serviceTonyNum;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) NSArray *dateList;
@property (nonatomic, copy) NSString *nextDate;

@property (nonatomic, strong) NSArray *cutDateList;
@property (nonatomic, strong) NSArray *nextdateList;

@end

NS_ASSUME_NONNULL_END
