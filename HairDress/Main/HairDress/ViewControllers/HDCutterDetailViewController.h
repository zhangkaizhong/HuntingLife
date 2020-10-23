//
//  HDCutterDetailViewController.h
//  HairDress
//
//  Created by Apple on 2019/12/23.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//  发型师详情

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDCutterDetailViewDelegate <NSObject>

-(void)clickCollectActionRefreshList;

@end

@interface HDCutterDetailViewController : HDBaseViewController

@property (nonatomic, readonly, assign) BOOL isBacking;

@property (nonatomic,assign) id<HDCutterDetailViewDelegate>delegate;
//发型师ID
@property (nonatomic,copy) NSString *cutter_id;

@end

NS_ASSUME_NONNULL_END
