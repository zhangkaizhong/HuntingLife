//
//  HDPublishEvaluateViewController.h
//  HairDress
//
//  Created by Apple on 2019/12/31.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  发布理发评价

#import <UIKit/UIKit.h>

@protocol HDPublishEvaluateDelegate <NSObject>

-(void)publishEvaDelegate;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDPublishEvaluateViewController : HDBaseViewController

@property (nonatomic,copy) NSString *order_id;

@property (nonatomic,assign)id<HDPublishEvaluateDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
