//
//  HDCutterShowsCollectionViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2020/3/13.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDCutterWorkShowsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDCutterShowsCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) UIImageView *imageShow;
@property (nonatomic,strong) HDCutterWorkShowsModel *model;

@end

NS_ASSUME_NONNULL_END
