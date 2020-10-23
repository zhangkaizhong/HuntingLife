//
//  GGCalendarSubView.m
//  GoGo
//
//  Created by 张凯中 on 2020/4/28.
//  Copyright © 2020 张凯中. All rights reserved.
//

#import "GGCalendarSubView.h"

#import "CalenderModel.h"
#import "GGCalendarDateView.h"

@interface GGCalendarSubView ()

@property (nonatomic,strong) UILabel *lblTitle;
@property (nonatomic,strong) NSArray *arrDates;

@end

@implementation GGCalendarSubView

-(instancetype)initWithFrame:(CGRect)frame withDateArr:(NSArray *)dates{
    if (self = [super initWithFrame:frame]) {
        self.arrDates = dates;
        
        [self addSubview:self.lblTitle];
        CalenderModel *firstModel = dates[0];
        _lblTitle.text = [NSString stringWithFormat:@"%ld月",(long)firstModel.month];
        for (int i=0; i<dates.count; i++) {
            GGCalendarDateView *viewDate = [[GGCalendarDateView alloc] initWithFrame:CGRectMake(0, 0, 16*SCALE, 16*SCALE)];
            viewDate.tag = 10000+i;
            GGCalendarDateView *viewLast = (GGCalendarDateView *)[self viewWithTag:10000+i-1];
            viewDate.model = dates[i];
            if (i == 0) {
                viewDate.x = 0;
                viewDate.y = _lblTitle.bottom+4*SCALE;
            }else{
                viewDate.x = CGRectGetMaxX(viewLast.frame);
                if (CGRectGetMaxX(viewDate.frame) > self.width) {
                    viewDate.x = 0;
                    viewDate.y = CGRectGetMaxY(viewLast.frame);
                }else{
                    viewDate.y = viewLast.y;
                }
            }
            
            [self addSubview:viewDate];
            self.height = viewDate.bottom;
        }
    }
    return self;
}

-(UILabel *)lblTitle{
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(4*SCALE, 20*SCALE, 100, 18*SCALE) title:@"1月" bgColor:[UIColor clearColor] titleColor:[UIColor blackColor] titleFont:18*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
    }
    return _lblTitle;
}

@end
