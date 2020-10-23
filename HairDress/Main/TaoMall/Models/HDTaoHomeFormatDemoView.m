//
//  HDTaoHomeFormatDemoView.m
//  HairDress
//
//  Created by 张凯中 on 2020/1/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDTaoHomeFormatDemoView.h"

@interface HDTaoHomeFormatDemoView ()


@end

/**
 200005    https://cdn.idouyao.com/taoke/img/format/1.png    1
 200006    https://cdn.idouyao.com/taoke/img/format/2.png    2
 200007    https://cdn.idouyao.com/taoke/img/format/3.png    2
 200008    https://cdn.idouyao.com/taoke/img/format/9.png    2
 200009    https://cdn.idouyao.com/taoke/img/format/4.png    3
 2000010    https://cdn.idouyao.com/taoke/img/format/5.png    3
 2000011    https://cdn.idouyao.com/taoke/img/format/6.png    3
 2000012    https://cdn.idouyao.com/taoke/img/format/7.png    3
 2000013    https://cdn.idouyao.com/taoke/img/format/8.png    4
 2000014    https://cdn.idouyao.com/taoke/img/format/11.png    1
 2000015    https://cdn.idouyao.com/taoke/img/format/10.png    1
 2000016    https://cdn.idouyao.com/taoke/img/format/12.png    2
 */

@implementation HDTaoHomeFormatDemoView

-(void)setArrList:(NSArray *)arrList{
    _arrList = arrList;
    
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 8, kSCREEN_WIDTH, 8)];
    line.backgroundColor = RGBBG;
    [self addSubview:line];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16,line.bottom+12,kSCREEN_WIDTH-32,22)];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"精选活动"attributes: @{NSFontAttributeName: TEXT_SC_TFONT(TEXT_SC_Medium, 21),NSForegroundColorAttributeName:RGBTEXT}];
    label.attributedText = string;
    [self addSubview:label];
    
    for (int i=0;i<arrList.count;i++) {
        
        NSDictionary *dic = arrList[i];
        UIView *subView = [self createSubView:[HDToolHelper nullDicToDic:dic]];
        [self addSubview:subView];
        
        subView.tag = 100+i;
        
        if (i>0) {
            UIView *subViewLast = (UIView *)[self viewWithTag:100+i-1];
            
            subView.y = subViewLast.bottom;
        }else{
            subView.y = label.bottom+14;
        }
        
        self.height = subView.bottom;
    }
}

-(UIView *)createSubView:(NSDictionary *)dic{
    NSMutableArray *arrImages = [NSMutableArray new];
    if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
        [arrImages addObjectsFromArray:dic[@"specialVoList"]];
    }
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.width = kSCREEN_WIDTH;
    //一张图：宽高比3:1
    if ([dic[@"demoId"] integerValue] == 200005) {
        view.height = kSCREEN_WIDTH/3;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.width, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 10000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //2张图：宽高比：1:1
    if ([dic[@"demoId"] integerValue] == 200006) {
        view.height = kSCREEN_WIDTH/2;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 20000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //2张图：宽高比：2:1
    if ([dic[@"demoId"] integerValue] == 200007) {
        view.height = kSCREEN_WIDTH/4;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2, kSCREEN_WIDTH/4)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 30000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //2张图：宽高比：3:2
    if ([dic[@"demoId"] integerValue] == 200008) {
        view.height = 2*(kSCREEN_WIDTH/2)/3;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2, 2*(kSCREEN_WIDTH/2)/3)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 40000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //3张图：宽高比：2:3
    if ([dic[@"demoId"] integerValue] == 200009) {
        view.height = 3*(kSCREEN_WIDTH/3)/2;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/3, 0, kSCREEN_WIDTH/3, 3*(kSCREEN_WIDTH/3)/2)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 50000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //3张图：宽高比：1:1
    if ([dic[@"demoId"] integerValue] == 2000010) {
        view.height = kSCREEN_WIDTH/3;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/3, 0, kSCREEN_WIDTH/3, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 60000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //3张图：宽高比：第一张1:1，剩下：2:1
    if ([dic[@"demoId"] integerValue] == 2000011) {
        view.height = kSCREEN_WIDTH/2;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            
            image.tag = 70000+i;
            
            if (i==1 || i==2) {
                image.height = view.height/2;
            }
            if (i==2) {
                image.y = view.height/2;
                image.x = kSCREEN_WIDTH/2;
            }
            
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //3张图：宽高比：第一张3:4，剩下：2:1
    if ([dic[@"demoId"] integerValue] == 2000012) {
        view.height = 4*(kSCREEN_WIDTH/2)/3;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/2, 0, kSCREEN_WIDTH/2, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            
            image.tag = 80000+i;
            
            if (i==1 || i==2) {
                image.height = view.height/2;
            }
            if (i==2) {
                image.y = view.height/2;
                image.x = kSCREEN_WIDTH/2;
            }
            
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //4张图：宽高比：第一张1:2
    if ([dic[@"demoId"] integerValue] == 2000013) {
        view.height = 2*(kSCREEN_WIDTH/3);
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSCREEN_WIDTH/3, 0, kSCREEN_WIDTH/3, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            
            image.tag = 90000+i;
            
            if (i==1) {
                image.x = kSCREEN_WIDTH/3;
                image.width = (kSCREEN_WIDTH/3) *2;
                image.height = view.height/2;
            }
            if (i==2) {
                image.y = view.height/2;
                image.x = kSCREEN_WIDTH/3;
                image.width = kSCREEN_WIDTH/3;
                image.height = view.height/2;
            }
            if (i==3) {
                image.y = view.height/2;
                image.x = (kSCREEN_WIDTH/3)*2;
                image.width = kSCREEN_WIDTH/3;
                image.height = view.height/2;
            }
            
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //1张图：宽高比：4:1
    if ([dic[@"demoId"] integerValue] == 2000014) {
        view.height = kSCREEN_WIDTH/4;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.width, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 100000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //1张图：宽高比：3:2
    if ([dic[@"demoId"] integerValue] == 2000015) {
        view.height = 2*kSCREEN_WIDTH/3;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.width, view.height)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 110000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    //2张图：高：146
    if ([dic[@"demoId"] integerValue] == 2000016) {
        CGFloat h1 = 146;
        CGFloat w1 = 375;
        CGFloat height1 = (h1/w1) * (view.width/2);
        view.height = height1;
        if (arrImages.count == 0) {
            view.height = 0;
            return view;
        }
        for (int i =0; i<arrImages.count;i++) {
            NSDictionary *dic = arrImages[i];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*view.width/2, 0, view.width/2, height1)];
            [image sd_setImageWithURL:[NSURL URLWithString:dic[@"showImg"]]];
            image.tag = 120000+i;
            [view addSubview:image];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
            image.userInteractionEnabled = YES;
            [image addGestureRecognizer:tap];
        }
    }
    
    return view;
}

-(void)tapImageAction:(UIGestureRecognizer *)sender{
    NSLog(@"%ld",(long)sender.view.tag);
    
    NSDictionary *indexDic = nil;
    
    if (sender.view.tag - 10000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 200005) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 10000) {
                    indexDic = arrImages[sender.view.tag - 10000];
                }
            }
        }
    }
    if (sender.view.tag - 20000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 200006) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 20000) {
                    indexDic = arrImages[sender.view.tag - 20000];
                }
            }
        }
    }
    if (sender.view.tag - 30000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 200007) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 30000) {
                    indexDic = arrImages[sender.view.tag - 30000];
                }
            }
        }
    }
    if (sender.view.tag - 40000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 200008) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 40000) {
                    indexDic = arrImages[sender.view.tag - 40000];
                }
            }
        }
    }
    if (sender.view.tag - 50000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 200009) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 50000) {
                    indexDic = arrImages[sender.view.tag - 50000];
                }
            }
        }
    }
    if (sender.view.tag - 60000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 2000010) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 60000) {
                    indexDic = arrImages[sender.view.tag - 60000];
                }
            }
        }
    }
    if (sender.view.tag - 70000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 2000011) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 70000) {
                    indexDic = arrImages[sender.view.tag - 70000];
                }
            }
        }
    }
    if (sender.view.tag - 80000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 2000012) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 80000) {
                    indexDic = arrImages[sender.view.tag - 80000];
                }
            }
        }
    }
    if (sender.view.tag - 90000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 2000013) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 90000) {
                    indexDic = arrImages[sender.view.tag - 90000];
                }
            }
        }
    }
    if (sender.view.tag - 100000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 2000014) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 100000) {
                    indexDic = arrImages[sender.view.tag - 100000];
                }
            }
        }
    }
    if (sender.view.tag - 110000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 2000015) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 110000) {
                    indexDic = arrImages[sender.view.tag - 110000];
                }
            }
        }
    }
    if (sender.view.tag - 120000 < 10) {
        for (NSDictionary *dic in self.arrList) {
            if ([dic[@"demoId"] integerValue] == 2000016) {
                NSMutableArray *arrImages = [NSMutableArray new];
                if ([dic[@"specialVoList"] isKindOfClass:[NSArray class]]) {
                    [arrImages addObjectsFromArray:dic[@"specialVoList"]];
                }
                if (arrImages.count > sender.view.tag - 120000) {
                    indexDic = arrImages[sender.view.tag - 120000];
                }
            }
        }
    }
    
    if (indexDic) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickFormatGoodIndex:)]) {
            [self.delegate clickFormatGoodIndex:indexDic];
        }
    }
}

@end
