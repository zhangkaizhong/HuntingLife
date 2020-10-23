//
//  HDCancelCutQueneViewController.h
//  HairDress
//
//  Created by Apple on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  取消排号

#import <UIKit/UIKit.h>

@protocol HDCancelCutQueneDelegate <NSObject>

//取消排队
-(void)cancelQueue;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDCancelCutQueneViewController : UIViewController

@property (nonatomic,copy) NSString *order_id;
@property (nonatomic,copy) NSString *queue_num;
@property (nonatomic,copy) NSString *cancel_type;

@property (nonatomic,assign) id<HDCancelCutQueneDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
