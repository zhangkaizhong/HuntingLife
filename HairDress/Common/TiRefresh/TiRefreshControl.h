//
//  TiRefreshControl.h
//  RefreshTest
//
//  Created by CtreeOne on 15/11/18.
//  Copyright © 2015年 tion126. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TiRefreshDefault.h"

@interface TiRefreshControl : UIView

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets superEdgeInsets;
@property (nonatomic, assign) RefreshState refreshState;
@property (nonatomic, copy) RefreshHandler refreshedHandler;

//-(void)addRefreshEvent:(RefreshHandler)handler;

- (instancetype)initWithHandler:(RefreshHandler)handler;
- (void)pullRefresh;
- (void)stopRefresh;
- (void)setup;


@end
