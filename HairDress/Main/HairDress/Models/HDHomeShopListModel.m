//
//  HDHomeShopListModel.m
//  HairDress
//
//  Created by Apple on 2020/1/7.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "HDHomeShopListModel.h"

@implementation HDHomeShopListModel

-(NSString *)distanceDesc{
    if ([self.distance floatValue] >= 1000) {
        _distanceDesc = [NSString stringWithFormat:@"%.2fKm",[self.distance floatValue]/1000];
    }else{
        _distanceDesc = [NSString stringWithFormat:@"%.2fm",[self.distance floatValue]];
    }
    
    return _distanceDesc;
}

-(CGFloat)cellHeight{
    //logo
    self.logoImgFrame = CGRectMake(24*SCALE, 12*SCALE, 72*SCALE, 72*SCALE);
    
    //标签
    if (self.serviceList.count == 0) {
        self.serviceListFrame = CGRectMake(24*SCALE, CGRectGetMaxY(self.logoImgFrame)+8*SCALE, kSCREEN_WIDTH-24*SCALE-16*SCALE-90*SCALE, 1);
        _cellHeight = CGRectGetMaxY(self.serviceListFrame)+12*SCALE;
        return _cellHeight;
    }
    
    self.serviceListFrame = CGRectMake(24*SCALE, CGRectGetMaxY(self.logoImgFrame)+8*SCALE, kSCREEN_WIDTH-24*SCALE-16*SCALE-90*SCALE, 16*SCALE);
    UIView *view = [UIView new];
    for (int i = 0; i<self.serviceList.count; i++) {
        if (i<30) {
            UILabel *lblFeture = [[UILabel alloc] initWithFrame:CGRectMake(0 + i*56*SCALE, 0, self.serviceListFrame.size.width, 16*SCALE)];
            lblFeture.font = [UIFont systemFontOfSize:10*SCALE];
            lblFeture.text = self.serviceList[i];
            
            lblFeture.numberOfLines = 0;
            [lblFeture sizeToFit];
            lblFeture.width = lblFeture.width + 5*SCALE;
            if (lblFeture.height <= 16*SCALE) {
                lblFeture.height = 16*SCALE;
            }
            else{
                lblFeture.height = lblFeture.height +5*SCALE;
            }

            lblFeture.tag = 100+i;
            lblFeture.hidden = YES;

            UILabel *lblLast = (UILabel *)[view viewWithTag:100+i-1];

            if (i==0) {
                lblFeture.y = 0;
                lblFeture.x = 0;
            }else{

                lblFeture.x = CGRectGetMaxX(lblLast.frame)+6*SCALE;
                if (CGRectGetMaxX(lblFeture.frame) > self.serviceListFrame.size.width) {
                    lblFeture.x = 0;
                    lblFeture.y = CGRectGetMaxY(lblLast.frame)+6*SCALE;
                }else{
                    lblFeture.y = lblLast.y;
                }
            }

            [view addSubview:lblFeture];

            view.height = CGRectGetMaxY(lblFeture.frame);
        }
    }
    self.serviceListFrame = CGRectMake(24*SCALE, CGRectGetMaxY(self.logoImgFrame)+8*SCALE, kSCREEN_WIDTH-24*SCALE-16*SCALE-90*SCALE, view.height);
    //地址高度
    CGRect addressNewFrame = [self.storeAddress boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-44*SCALE-90*SCALE-41*SCALE, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TEXT_SC_TFONT(TEXT_SC_Regular, 10*SCALE)} context:nil];
    if (addressNewFrame.size.height <= 10*SCALE) {
        addressNewFrame.size.height = 10*SCALE;
    }
    self.storeAddressFrame = CGRectMake(44*SCALE, CGRectGetMaxY(self.serviceListFrame)+21*SCALE, kSCREEN_WIDTH-44*SCALE-90*SCALE-41*SCALE, addressNewFrame.size.height);
    
    //今日营业状态
    self.openFrame = CGRectMake(kSCREEN_WIDTH-78*SCALE-12*SCALE, self.storeAddressFrame.origin.y, 78*SCALE, 28*SCALE);
    //距离
    if ([self.distance floatValue] >= 1000) {
        _distanceDesc = [NSString stringWithFormat:@"%.2fKm",[self.distance floatValue]/1000];
    }else{
        _distanceDesc = [NSString stringWithFormat:@"%.2fm",[self.distance floatValue]];
    }
    CGSize distanceSize = [self.distanceDesc sizeWithAttributes:@{NSFontAttributeName:TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE)}];
    self.distanceFrame = CGRectMake(kSCREEN_WIDTH-distanceSize.width-12*SCALE, self.storeAddressFrame.origin.y-14*SCALE-14*SCALE, distanceSize.width, 14*SCALE);
    
    //分割线
    self.lineFrame = CGRectMake(0, CGRectGetMaxY(self.storeAddressFrame)+26*SCALE, kSCREEN_WIDTH, 1);
    if (CGRectGetMaxY(self.storeAddressFrame)<CGRectGetMaxY(self.openFrame)) {
        self.lineFrame = CGRectMake(0, CGRectGetMaxY(self.openFrame)+26*SCALE, kSCREEN_WIDTH, 1);
    }
    _cellHeight = CGRectGetMaxY(self.lineFrame);
    return _cellHeight;
}

-(CGFloat)searchCellHeight{
    
    UILabel *lblAddress = [UILabel new];
    lblAddress.frame = CGRectMake(34, 118, kSCREEN_WIDTH-34-16, 16);
    
    //地址高度
    CGRect addressNewFrame = [self.storeAddress boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-36-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    if (addressNewFrame.size.height <= 12) {
        addressNewFrame.size.height = 12;
    }
    
    lblAddress.height = addressNewFrame.size.height;
    
    self.searchAddressFrame = CGRectMake(36, 118, kSCREEN_WIDTH-36-16, lblAddress.height);
    
    self.searchLineFrame = CGRectMake(0, CGRectGetMaxY(self.searchAddressFrame)+24, kSCREEN_WIDTH, 8);
    _searchCellHeight = CGRectGetMaxY(self.searchLineFrame);
    
    return _searchCellHeight;
}

@end
