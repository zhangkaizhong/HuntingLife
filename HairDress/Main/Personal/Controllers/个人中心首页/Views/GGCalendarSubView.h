//
//  GGCalendarSubView.h
//  GoGo
//
//  Created by 张凯中 on 2020/4/28.
//  Copyright © 2020 张凯中. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGCalendarSubView : UIView

-(instancetype)initWithFrame:(CGRect)frame withDateArr:(NSArray *)dates;

@property (nonatomic,strong) NSDictionary *dicMonth;

@end

NS_ASSUME_NONNULL_END
