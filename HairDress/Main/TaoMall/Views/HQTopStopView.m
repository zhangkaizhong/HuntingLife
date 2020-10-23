//
//  HQTopStopView.m
//  HQCollectionViewDemo
//
//  Created by Mr_Han on 2018/10/10.
//  Copyright © 2018年 Mr_Han. All rights reserved.
//  CSDN <https://blog.csdn.net/u010960265>
//  GitHub <https://github.com/HanQiGod>
// 

#import "HQTopStopView.h"

@interface HQTopStopView ()



@end

@implementation HQTopStopView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self= [super initWithFrame:frame]) {
        
        NSArray *arr = @[@"综合",@"价格",@"销量"];
        for (int i = 0; i<arr.count; i++) {
            UIButton *btn = [[UIButton alloc] initCustomWithFrame:CGRectMake(i*kSCREEN_WIDTH/3, 0, kSCREEN_WIDTH/3, 48) btnTitle:arr[i] btnImage:@"" btnType:RIGHT bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14];
            
            if (i==0) {
                [btn setTitleColor:RGBMAIN forState:UIControlStateSelected];
                btn.selected = YES;
            }else{
                [btn setImage:[UIImage imageNamed:@"paixujiantouxia"] forState:UIControlStateNormal];
            }
            
            [btn addTarget:self action:@selector(btnSelSortAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            btn.tag = 100+i;
        }
    }
    return self;
}

-(void)btnSelSortAction:(UIButton *)sender{
    for (int i=0; i<3; i++) {
        if (100+i == sender.tag) {
            sender.selected = !sender.selected;
            NSString *sortStr = @"asc";
            if (sender.selected) {
                sortStr = @"desc";
                if (i>0) {
                    [sender setImage:[UIImage imageNamed:@"paixujiantou_down"] forState:UIControlStateNormal];
                }
            }else{
                if (i>0) {
                    [sender setImage:[UIImage imageNamed:@"paixujiantou_up"] forState:UIControlStateNormal];
                }
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickSortAction:sort:)]) {
                [self.delegate clickSortAction:sender.titleLabel.text sort:sortStr];
            }
        }else{
            UIButton *btn = (UIButton *)[self viewWithTag:100+i];
            btn.selected = NO;
            if (i>0) {
                [btn setImage:[UIImage imageNamed:@"paixujiantouxia"] forState:UIControlStateNormal];
            }
        }
    }
}

@end
