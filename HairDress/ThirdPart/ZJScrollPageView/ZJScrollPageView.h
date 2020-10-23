//
//  ZJScrollPageView.h
//  ZJScrollPageView
//
//  Created by jasnig on 16/5/6.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJScrollSegmentView.h"
#import "ZJContentView.h"

@protocol ZJScrollPageViewDelegate <NSObject>

-(void)ZJSrollViewDidScrollToIndex:(NSInteger)currentIndex;

@end

@interface ZJScrollPageView : UIView
typedef void(^ExtraBtnOnClick)(UIButton *extraBtn);

@property (strong, nonatomic) ZJScrollSegmentView *segmentView;
@property (copy, nonatomic) ExtraBtnOnClick extraBtnOnClick;

- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(ZJSegmentStyle *)segmentStyle childVcs:(NSArray *)childVcs parentViewController:(UIViewController *)parentViewController;

/** 给外界设置选中的下标的方法 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
/**  给外界重新设置视图内容的标题的方法 */
- (void)reloadChildVcsWithNewChildVcs:(NSArray *)newChildVcs;

@property (weak, nonatomic) ZJContentView *contentView;

@property(nonatomic,assign)id<ZJScrollPageViewDelegate>zjdelegate;

@end
