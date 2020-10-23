//
//  TradeAreaPickerView.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/5.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BankTypeBlock) (NSDictionary *bankType);

@interface BankTypePickView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>

@property(nonatomic,copy)BankTypeBlock bankblock;


-(instancetype)initWithFrame:(CGRect)frame arrData:(NSArray *)arr;

@end

NS_ASSUME_NONNULL_END
