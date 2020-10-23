//
//  HDPersonalHomeHeaderView.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PersonalHeaderClickTypeIntr, //说明
    PersonalHeaderClickTypePersonInfo, // 个人资料
} PersonalHeaderClickType;

NS_ASSUME_NONNULL_BEGIN

@protocol PersonalInfoDelegate <NSObject>

-(void)clickPersonalHeaderView:(PersonalHeaderClickType)type;

@end

@interface HDPersonalHomeHeaderView : UIView

@property (nonatomic,assign) id<PersonalInfoDelegate>delegate;

@property (nonatomic,strong) NSDictionary *userDic;
@property (nonatomic,strong) NSDictionary *profitDic;

@end

NS_ASSUME_NONNULL_END
