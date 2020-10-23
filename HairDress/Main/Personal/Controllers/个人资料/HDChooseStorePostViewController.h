//
//  HDChooseStorePostViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/2.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  店员编辑信息选择岗位

#import <UIKit/UIKit.h>

@protocol HDChooseStorePostDelegate <NSObject>

-(void)chooseStorePostAction:(NSDictionary *)storePostDic;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDChooseStorePostViewController : HDBaseViewController

@property (nonatomic,assign) id <HDChooseStorePostDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
