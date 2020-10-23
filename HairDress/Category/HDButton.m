//
//  HDButton.m
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDButton.h"

@implementation HDButton

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    CGFloat spacing = 0;
    if (self.btnType == TOP || self.btnType == BOTTOM) {
        spacing = (self.frame.size.height - titleFrame.size.height - imageFrame.size.height - 5) / 2;
    } else {
        spacing = (self.frame.size.width - titleFrame.size.width - imageFrame.size.width -10)/2;
    }
    
    switch (self.btnType) {
        case TOP:
        {
            self.imageView.center = CGPointMake(self.frame.size.width / 2, spacing + imageFrame.size.height / 2);
            self.titleLabel.center = CGPointMake(self.frame.size.width / 2, CGRectGetMaxY(self.imageView.frame) + titleFrame.size.height / 2 + 5);
        }
            break;
        case BOTTOM:
        {
            self.titleLabel.center = CGPointMake(self.frame.size.width / 2, spacing + titleFrame.size.height / 2);
            self.imageView.center = CGPointMake(self.frame.size.width / 2, CGRectGetMaxY(self.titleLabel.frame) + imageFrame.size.height / 2 + 5);
        }
            break;
        case LEFT:
        {
            self.imageView.center = CGPointMake(spacing + imageFrame.size.width / 2, self.frame.size.height / 2);
            self.titleLabel.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) + 10 + titleFrame.size.width / 2, self.frame.size.height / 2);
        }
            break;
        case RIGHT:
        {
            self.titleLabel.center = CGPointMake(spacing + titleFrame.size.width / 2 + 10, self.frame.size.height / 2);
            self.imageView.center = CGPointMake(CGRectGetMaxX(self.titleLabel.frame) + 5 + imageFrame.size.width / 2, self.frame.size.height / 2);
        }
            break;
        case LeftEast:
        {
            self.titleLabel.x = 16;
        }
            break;
        case LeftCostom:
        {
            self.imageView.center = CGPointMake(imageFrame.size.width / 2, self.frame.size.height / 2);
            self.titleLabel.center = CGPointMake(CGRectGetMaxX(self.imageView.frame)+5 + titleFrame.size.width / 2, self.frame.size.height / 2);
        }
            break;
        case RIGHT_DOWN:
        {
            self.titleLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
            self.imageView.frame = CGRectMake(self.frame.size.width - 6 - self.imageView.frame.size.width, self.frame.size.height - 6 - self.imageView.frame.size.height, 14, 14);
        }
            break;
        case LeftWallet:
        {
            self.imageView.x = 6;
            self.titleLabel.x = CGRectGetMaxX(self.imageView.frame)+5;
        }
            break;
        case RIGHTMore:
        {
            self.titleLabel.x = 12;
            self.imageView.x = self.width-self.imageView.width-12;
        }
            break;
        case Top_Msg:
        {
            self.imageView.center = CGPointMake(self.frame.size.width / 2, imageFrame.size.height / 2);
            self.titleLabel.center = CGPointMake(self.frame.size.width / 2, CGRectGetMaxY(self.imageView.frame) + titleFrame.size.height / 2 + 2);
        }
            break;
        case Top_24:
        {
            self.imageView.centerX = self.width/2;
            self.imageView.y = 24*SCALE;
            self.titleLabel.centerX = self.width/2;
            self.titleLabel.y = self.imageView.bottom+16*SCALE;
        }
            break;
        default:
            break;
    }
}

@end
