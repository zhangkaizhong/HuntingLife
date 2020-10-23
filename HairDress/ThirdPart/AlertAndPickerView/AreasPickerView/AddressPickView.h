//
//  PopupView.h
//  买布易
//
//  Created by 张建 on 15/6/26.
//  Copyright (c) 2015年 张建. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^AdressBlock) (NSDictionary *province,NSDictionary *city,NSDictionary *town);

@interface AddressPickView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>

@property(nonatomic,copy)AdressBlock addressblock;


-(instancetype)initWithFrame:(CGRect)frame arrData:(NSArray *)arr;


@end
