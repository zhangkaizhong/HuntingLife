//
//  HDTaoMallSubViewController.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/6.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol HDTaoMallSubHomeDidScrollDelegate <NSObject>
//
//-(void)didScrollViewChangeImageHeight:(CGFloat)offset;
//
//@end

NS_ASSUME_NONNULL_BEGIN

@interface HDTaoMallSubHomeViewController : HDBaseViewController

@property (nonatomic,copy) NSString *index_id;
@property (nonatomic,copy) NSString *position_code;

//@property (nonatomic,assign)id<HDTaoMallSubHomeDidScrollDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
