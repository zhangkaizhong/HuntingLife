//
//  HDWebContentModel.m
//  HairDress
//
//  Created by 张凯中 on 2020/6/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDWebContentModel.h"
#import <WebKit/WebKit.h>

@interface HDWebContentModel ()<WKUIDelegate,WKNavigationDelegate>

@end

@implementation HDWebContentModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"content_id":@"id"};
}

-(CGFloat)cellHeight{
    //title高度
    CGRect titleFrame = [self.title boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-56*SCALE, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TEXT_SC_TFONT(TEXT_SC_Regular, 16*SCALE)} context:nil];
    if (titleFrame.size.height <= 16*SCALE) {
        titleFrame.size.height = 16*SCALE;
    }
    self.titleFrame = CGRectMake(16*SCALE, 20*SCALE, kSCREEN_WIDTH-56*SCALE, titleFrame.size.height);
    _cellHeight = CGRectGetMaxY(self.titleFrame)+20*SCALE;
    
    return _cellHeight;
}

-(NSString *)content{
    NSString *result = [NSString stringWithFormat:@"<%@ %@",@"img",@"style='display: block; max-width: 100%;'"];
    _content = [_content stringByReplacingOccurrencesOfString:@"<img" withString:result];
    
       _content = [NSString stringWithFormat:@"<html><head><meta http-equiv=\'Content-Type\' content=\'text/html; charset=utf-8\'/><meta content=\'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;\' name=\'viewport\' /><meta name=\'apple-mobile-web-app-capable\' content=\'yes\'><meta name=\'apple-mobile-web-app-status-bar-style\' content=\'black\'><link rel=\'stylesheet\' type=\'text/css\' /><style type=\'text/css\'> .color{color:#576b95;}</style></head><body><div id=\'content\'>%@</div>", _content];

    
    return _content;
}

@end
