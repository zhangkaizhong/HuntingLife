//
//  HDShopCutterListModel.m
//  HairDress
//
//  Created by Apple on 2020/1/7.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDShopCutterListModel.h"

@implementation HDShopCutterListModel

-(CGFloat)cellHeight{
    //发型师头像frame
    self.cutterImgFrame = CGRectMake(16, 20, 72, 72);
    //发型师标签frame
//    if (_labels.count == 0) {
        self.viewTagsFrame = CGRectMake(0, CGRectGetMaxY(self.cutterImgFrame)+12, kSCREEN_WIDTH, 0);
//    }else{
//        UIView *view = [UIView new];
//        view.height = 0;
//        for (int i = 0; i<_labels.count; i++) {
//            if (i<30) {
//                UILabel *lblFeture = [[UILabel alloc] initCommonWithFrame:CGRectMake(36 + i*56, 0, 48, 16) title:_labels[i] bgColor:RGBAlpha(245, 34, 45, 0.08) titleColor:RGBMAIN titleFont:10 textAlignment:NSTextAlignmentCenter isFit:NO];
//
//                lblFeture.width = kSCREEN_WIDTH - 36-26;
//                lblFeture.numberOfLines = 0;
//                [lblFeture sizeToFit];
//                lblFeture.width = lblFeture.width + 5;
//                if (lblFeture.height < 16) {
//                    lblFeture.height = 16;
//                }
//                else{
//                    lblFeture.height = lblFeture.height +5;
//                }
//
//                lblFeture.tag = 100+i;
//                lblFeture.hidden = YES;
//
//                UILabel *lblLast = (UILabel *)[view viewWithTag:100+i-1];
//
//                if (i==0) {
//                    lblFeture.y = 0;
//                    lblFeture.x = 36;
//                }else{
//
//                    lblFeture.x = CGRectGetMaxX(lblLast.frame)+8;
//                    if (CGRectGetMaxX(lblFeture.frame)+16 > (kSCREEN_WIDTH-36)) {
//                        lblFeture.x = 36;
//                        lblFeture.y = CGRectGetMaxY(lblLast.frame)+8;
//                    }else{
//                        lblFeture.y = lblLast.y;
//                    }
//                }
//
//                [view addSubview:lblFeture];
//
//                view.height = CGRectGetMaxY(lblFeture.frame);
//            }
//        }
//        NSLog(@"%.2f",view.height);
//        self.viewTagsFrame = CGRectMake(0, CGRectGetMaxY(self.cutterImgFrame)+12, kSCREEN_WIDTH, view.height);
//    }
    //服务宗旨frame
    if ([HDToolHelper StringIsNullOrEmpty:_serviceTenet]) {
        self.tenetFrame = CGRectMake(16, CGRectGetMaxY(self.viewTagsFrame)+12, kSCREEN_WIDTH-32, 0);
    }else{
        NSString *tenetStr = [NSString stringWithFormat:@"服务宗旨：%@",_serviceTenet];;
        CGRect tenetNewFrame = [tenetStr boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
        if (tenetNewFrame.size.height <= 16) {
            tenetNewFrame.size.height = 16;
        }
        self.tenetFrame = CGRectMake(16, CGRectGetMaxY(self.viewTagsFrame)+12, kSCREEN_WIDTH-32, tenetNewFrame.size.height);
    }
    //门店地址frame
    CGRect addressNewFrame = [self.storeAddress boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    if (addressNewFrame.size.height <= 16) {
        addressNewFrame.size.height = 16;
    }
    if ([self.isDetail isEqualToString:@"1"]) {
        //隐藏地址
        self.viewAddressFrame = CGRectMake(0, CGRectGetMaxY(self.tenetFrame)+16, kSCREEN_WIDTH, 0);
    }else{
        self.viewAddressFrame = CGRectMake(0, CGRectGetMaxY(self.tenetFrame)+16, kSCREEN_WIDTH, 21+addressNewFrame.size.height);
    }
    //分割线frame
    self.viewBlockFrame = CGRectMake(0, CGRectGetMaxY(self.viewAddressFrame), kSCREEN_WIDTH, 8);
    _cellHeight = CGRectGetMaxY(self.viewAddressFrame)+8;
    return _cellHeight;
}

@end
