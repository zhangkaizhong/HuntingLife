//
//  HDTaoFloorView.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  首页楼层view

#import <UIKit/UIKit.h>

@protocol HDTaoFloorViewDelegate <NSObject>

-(void)clickGoodsInfo:(NSString *_Nullable)taoId;

-(void)clickFloorGoodsMore:(NSDictionary *_Nullable)dicFloor dicTime:(NSDictionary *_Nullable)timeDic;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoFloorView : UIView

@property (nonatomic,strong) NSArray *arrData;

@property (nonatomic,assign)id<HDTaoFloorViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
