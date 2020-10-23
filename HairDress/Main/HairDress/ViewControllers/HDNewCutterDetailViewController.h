//
//  HDNewCutterDetailViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/4/1.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  新版理发师详情页

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDCutterDetailViewDelegate <NSObject>

-(void)clickCollectActionRefreshList;

@end

@interface HDNewCutterDetailViewController : HDBaseViewController


@property (nonatomic,assign) id<HDCutterDetailViewDelegate>delegate;
//发型师ID
@property (nonatomic,copy) NSString *cutter_id;

@end

NS_ASSUME_NONNULL_END
