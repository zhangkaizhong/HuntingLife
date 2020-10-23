//
//  HDChooseCutTimeSubViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/31.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  选择理发预约时段

#import <UIKit/UIKit.h>

@protocol HDChooseCutTimeSubViewDelegate <NSObject>

-(void)didSelectTime:(NSDictionary *_Nullable)dic timeType:(NSString *_Nullable)timeType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDChooseCutTimeSubViewController : HDBaseViewController

@property (nonatomic,copy) NSString *storeID;
@property (nonatomic,copy) NSString *timeType;
@property (nonatomic,assign) id<HDChooseCutTimeSubViewDelegate>delegate;

-(void)reloadBtnSelectedStatus;

@end

NS_ASSUME_NONNULL_END
