//
//  HDBaseViewController.h
//  HairDress
//
//  Created by Apple on 2019/12/18.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDBaseViewController : UIViewController

@property (nonatomic,strong) UIView *viewEmpty;
@property (nonatomic,copy) NSString *emptyStr;

//重新加载数据
- (void)getLoadDataBase:(NSNotification *)text;

@end

NS_ASSUME_NONNULL_END
