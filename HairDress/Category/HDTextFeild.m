//
//  HDTextFeild.m
//  HairDress
//
//  Created by 张凯中 on 2020/9/24.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTextFeild.h"

@implementation HDTextFeild

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, kSCREEN_WIDTH,44)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH - 60, 7,50, 30)];
    [button setTitle:@"完成"forState:UIControlStateNormal];
    [button setTitleColor:RGBMAIN forState:UIControlStateNormal];
    [bar addSubview:button];
    self.inputAccessoryView = bar;
    
    [button addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
}

-(void)done{
    [self resignFirstResponder];
}

@end
