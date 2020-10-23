//
//  GGCalendarDateView.m
//  GoGo
//
//  Created by 张凯中 on 2020/4/28.
//  Copyright © 2020 张凯中. All rights reserved.
//

#import "GGCalendarDateView.h"

@interface GGCalendarDateView ()

@property (nonatomic,strong) UIView *viewDot;
@property (nonatomic,strong) UIView *viewLine;
@property (nonatomic,strong) UILabel *lblDate;

@property (nonatomic,assign) CGRect viewFrame;

@end

@implementation GGCalendarDateView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.viewFrame = frame;
        
        [self addSubview:self.viewDot];
        [self addSubview:self.viewLine];
        [self addSubview:self.lblDate];
    }
    return self;
}

-(void)setModel:(CalenderModel *)model{
    _model = model;
    
    _lblDate.text = _model.day;
    if ([_model.day isEqualToString:@""]) {
        _viewDot.hidden = YES;
        _lblDate.hidden = YES;
        _viewLine.hidden = YES;
    }else{
        if (model.isCutDay) {
            _viewDot.hidden = YES;
            _lblDate.hidden = NO;
            _viewLine.hidden = NO;
            
            _lblDate.textColor = RGBCOLOR(25, 24, 29);
            _viewLine.backgroundColor = RGBCOLOR(25, 24, 29);
        }
        else{
            if (model.isTuijianDay) {
                _viewDot.hidden = YES;
                _lblDate.hidden = NO;
                _viewLine.hidden = NO;
                _lblDate.textColor = RGBMAIN;
                _viewLine.backgroundColor = RGBMAIN;
            }else{
                _viewDot.hidden = NO;
                _lblDate.hidden = YES;
                _viewLine.hidden = YES;
            }
        }
    }
}

-(UIView *)viewDot{
    if (!_viewDot) {
        _viewDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4*SCALE, 4*SCALE)];
        _viewDot.backgroundColor = RGBCOLOR(231, 231, 231);
        _viewDot.centerX = self.width/2;
        _viewDot.centerY = self.height/2;
        _viewDot.layer.cornerRadius = 4*SCALE/2;
    }
    return _viewDot;
}

-(UILabel *)lblDate{
    if (!_lblDate) {
        _lblDate = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 16*SCALE, 11*SCALE) title:@"" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:10*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
    }
    return _lblDate;
}

-(UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 16*SCALE-2, 16*SCALE, 2)];
    }
    return _viewLine;
}

@end
