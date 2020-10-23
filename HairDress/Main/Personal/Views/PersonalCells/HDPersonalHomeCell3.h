//
//  HDPersonalHomeCell3.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HDPersonalHomeCellThreeClickTypeCollect,//我的收藏
    HDPersonalHomeCellThreeClickTypeVIPCard,//会员卡
} HDPersonalHomeCellThreeClickType;
NS_ASSUME_NONNULL_BEGIN

@protocol HDPersonalHomeCellThreeDelegate <NSObject>

-(void)clickCellThreeViews:(HDPersonalHomeCellThreeClickType)type;

@end

@interface HDPersonalHomeCell3 : UITableViewCell

@property (nonatomic,assign)id<HDPersonalHomeCellThreeDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
