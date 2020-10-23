//
//  TiRefreshDefault.h
//  RefreshTest
//
//  Created by CtreeOne on 15/11/18.
//  Copyright © 2015年 tion126. All rights reserved.
//

#ifndef TiRefreshDefault_h
#define TiRefreshDefault_h

typedef void(^RefreshHandler)(void);

typedef NS_ENUM(NSInteger, RefreshState) {
    State_normal = 1,
    State_trigger,
    State_Loading
};


#define DEFAULT_TITLE      @"下拉刷新"
#define HOLDING_TITLE    @"松开立即刷新"
#define LOADING_TITLE      @"正在刷新..."
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define TITLE_HEIGHT 100


#endif /* TiRefreshDefault_h */
