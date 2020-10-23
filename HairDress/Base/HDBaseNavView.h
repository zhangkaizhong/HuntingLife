//
//  NavView.h
//  XgShop
//
//  Created by XIAO on 2018/8/20.
//  Copyright © 2018年 Cocav. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WHITE_NAV_HEGHT (NAVHIGHT-24)

@protocol navViewDelegate<NSObject>
@optional
/**
 *导航的返回
 */
- (void)navBackClicked;
/**
 *导航的返回
 */
- (void)navCloseClicked;

/**
 *导航右边备用按钮
 */
- (void)navRightClicked;

// 搜索
-(void)navClickSearchView;

// 城市选择
-(void)navClickCitySearch;

//输入搜索
-(void)navTxtEndEditing:(NSString *)textSearch;

@end

@interface HDBaseNavView : UIView
@property (nonatomic,weak)id<navViewDelegate>delegate;


// 首页搜索框导航栏
-(id)initSearchBarViewWithFrame:(CGRect)frame
                        bgColor:(UIColor *)backColor
                      textColor:(UIColor *)textColor
                searchViewColor:(UIColor *)searchViewColor
                        isWhite:(NSString *)isWhite
                    theDelegate:(id<navViewDelegate>)delegate;

-(id)initSearchBarWithButtonsFrame:(CGRect)frame
                        bgColor:(UIColor *)backColor
                      textColor:(UIColor *)textColor
                searchViewColor:(UIColor *)searchViewColor
                            btnTitle:(NSString *)btnTitle
                       placeHolder:(NSString *)place
                    theDelegate:(id<navViewDelegate>)delegate;

// 普通导航栏
-(id)initWithFrame:(CGRect)frame
             title:(NSString *)title
           bgColor:(UIColor *)backColor
           backBtn:(BOOL)isBackBtn
          rightBtn:(NSString *)rightTitle
     rightBtnImage:(NSString *)rightImage
       theDelegate:(id<navViewDelegate>)delegate;

@property (nonatomic,strong)UIView *searchView;

@property (nonatomic,strong)UIColor *titleColor;

@property (nonatomic,copy) NSString *cityName;
//设置右边按钮图片
@property (nonatomic,copy) NSString *rightImage;

@property (nonatomic,strong) HDTextFeild *txtSearch;

@end
