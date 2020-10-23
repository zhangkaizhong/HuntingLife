//
//  HDMyShopWaiterSubViewController.h
//  HairDress
//
//  Created by Apple on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDMyShopWaiterSubViewConDelegate <NSObject>

-(void)refreshDataList:(NSString *)storePost;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDMyShopWaiterSubViewController : HDBaseViewController

@property (nonatomic,copy) NSString *storePost;
@property (nonatomic,copy) NSString *searchName;
@property (nonatomic,assign)id<HDMyShopWaiterSubViewConDelegate>delegate;

-(void)loadNewData;

@end

NS_ASSUME_NONNULL_END
