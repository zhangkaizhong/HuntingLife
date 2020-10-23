//
//  HDQuestionModel.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDQuestionModel.h"

@implementation HDQuestionModel
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"question_id":@"id"};
}


-(CGFloat)cellHeight{
    
    self.btnArrowFrame = CGRectMake((111/2-12)*SCALE, 90*SCALE, 24*SCALE, 24*SCALE);
    
    if (self.list.count == 0) {
        self.questionListFrame = CGRectMake(111*SCALE, 0, kSCREEN_WIDTH-111*SCALE, 1);
        self.lineFrame = CGRectMake(16*SCALE, CGRectGetMaxY(self.btnArrowFrame)+41*SCALE, kSCREEN_WIDTH-32*SCALE, 1);
        _cellHeight = CGRectGetMaxY(self.lineFrame);
        return _cellHeight;
    }
    
    self.questionListFrame = CGRectMake(111*SCALE, 0, kSCREEN_WIDTH-111*SCALE, 10);
    UIView *view = [UIView new];
    
    NSMutableArray *arrList = [NSMutableArray new];
    if ([self.isSelect isEqualToString:@"1"]) {
        [arrList addObjectsFromArray:self.list];
    }else{
        if (self.list.count > 2) {
            [arrList addObjectsFromArray:[self.list subarrayWithRange:NSMakeRange(0, 2)]];
        }else{
            [arrList addObjectsFromArray:self.list];
        }
    }
    
    for (int i=0; i<arrList.count; i++) {
        if (i<30) {
            NSDictionary *dic = arrList[i];
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, i*10, self.questionListFrame.size.width, 50*SCALE)];
            subView.tag = 100+i;
            [view addSubview:subView];
            
            UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 20*SCALE, self.questionListFrame.size.width-23*SCALE, 10) title:dic[@"title"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
            lblTitle.numberOfLines = 0;
            [lblTitle sizeToFit];
            [subView addSubview:lblTitle];
            
            UIView *viewlast = (UIView *)[view viewWithTag:100+i-1];
            if (i==0) {
                subView.y = 0;
            }else{
                subView.y = CGRectGetMaxY(viewlast.frame);
            }
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, lblTitle.bottom+20*SCALE, self.questionListFrame.size.width, 1)];
            line.backgroundColor = HexRGBAlpha(0xEEEEEE,1);
            [subView addSubview:line];
            if (i == 29) {
                line.hidden = YES;
            }
            subView.height = CGRectGetMaxY(line.frame);
            
            view.height = CGRectGetMaxY(subView.frame);
        }
    }
    
    self.questionListFrame = CGRectMake(111*SCALE, 0, kSCREEN_WIDTH-111*SCALE, view.height);
    
    if (CGRectGetMaxY(self.questionListFrame) > CGRectGetMaxY(self.btnArrowFrame)) {
        self.lineFrame = CGRectMake(16*SCALE, CGRectGetMaxY(self.questionListFrame), kSCREEN_WIDTH-32*SCALE, 1);
    }
    else{
        self.lineFrame = CGRectMake(16*SCALE, CGRectGetMaxY(self.btnArrowFrame)+25*SCALE, kSCREEN_WIDTH-32*SCALE, 1);
    }
    _cellHeight = CGRectGetMaxY(self.lineFrame);
    return _cellHeight;
}

@end
