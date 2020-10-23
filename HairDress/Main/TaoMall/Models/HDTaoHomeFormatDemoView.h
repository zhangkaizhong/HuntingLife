//
//  HDTaoHomeFormatDemoView.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  精选板式视图

#import <UIKit/UIKit.h>

@protocol HDTaoHomeFormatDemoViewDelegate <NSObject>

-(void)clickFormatGoodIndex:(NSDictionary *_Nullable)dic;
    
@end

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoHomeFormatDemoView : UIView

@property (nonatomic,assign)id<HDTaoHomeFormatDemoViewDelegate>delegate;

@property (nonatomic,strong) NSArray *arrList;

@end

NS_ASSUME_NONNULL_END
