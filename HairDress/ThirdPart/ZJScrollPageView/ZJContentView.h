//
//  ZJContentView.h
//  ZJScrollPageView
//
//  Created by jasnig on 16/5/6.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZJScrollSegmentView;

@protocol ZJContentViewDelegate <NSObject>

-(void)ZJScrollViewContentViewDidScrollToIndex:(NSInteger)currentIndex;

@end

@interface ZJContentView : UIView

- (instancetype)initWithFrame:(CGRect)frame childVcs:(NSArray *)childVcs segmentView:(ZJScrollSegmentView *)segmentView parentViewController:(UIViewController *)parentViewController;

/** 给外界可以设置ContentOffSet的方法 */
- (void)setContentOffSet:(CGPoint)offset animated:(BOOL)animated;
/** 给外界刷新视图的方法 */
- (void)reloadAllViewsWithNewChildVcs:(NSArray *)newChileVcs;
// 用于处理重用和内容的显示
@property (weak, nonatomic) UICollectionView *collectionView;

@property (nonatomic,assign)id<ZJContentViewDelegate>delegate;

@end
