//
//  UIScrollView+Associated.h
//  RefreshTest
//
//  Created by CtreeOne on 15/11/18.
//  Copyright © 2015年 tion126. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TiRefreshView.h"

@interface UIScrollView (Associated)

@property (nonatomic, strong) TiRefreshView *refreshView;

@end
