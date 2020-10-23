//
//  TiRefreshControl.m
//  RefreshTest
//
//  Created by CtreeOne on 15/11/18.
//  Copyright © 2015年 tion126. All rights reserved.
//

#import "TiRefreshControl.h"

@implementation TiRefreshControl

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, -TITLE_HEIGHT, SCREEN_WIDTH, TITLE_HEIGHT);
        self.backgroundColor = [UIColor clearColor];
        [self setup];
    }
    return self;
}


//-(void)addRefreshEvent:(RefreshHandler)handler{
//     [self initWithHandle:handler];
//}


- (instancetype)initWithHandler:(RefreshHandler)handler {
    self = [self init];
    if (self) {
        self.refreshedHandler = handler;
    }
    return self;
}

- (void)setup {
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
    if (newSuperview) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.superEdgeInsets = self.scrollView.contentInset;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)pullRefresh {
    self.refreshState = State_Loading;
}

- (void)stopRefresh {
    self.refreshState = State_normal;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.refreshState == State_Loading) {
        return;
    }
    
    CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
    CGFloat newOffsetThreshold = -TITLE_HEIGHT - self.scrollView.contentInset.top;
    if (!self.scrollView.isDragging && self.refreshState == State_trigger) {
        self.refreshState = State_Loading;
    } else if (point.y < newOffsetThreshold && self.scrollView.isDragging) {
        self.refreshState = State_trigger;
    } else if (point.y >= newOffsetThreshold ) {
        self.refreshState = State_normal;
    }
    
}

@end
