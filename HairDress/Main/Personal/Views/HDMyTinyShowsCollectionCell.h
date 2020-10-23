//
//  HDMyTinyShowsCollectionCell.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/27.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDCutterWorkShowsModel.h"

@protocol HDMyTinyShowsDelegate <NSObject>

-(void)clickDeleteShows:(HDCutterWorkShowsModel*)model;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDMyTinyShowsCollectionCell : UICollectionViewCell

@property (nonatomic,strong) HDCutterWorkShowsModel *model;
@property (nonatomic,assign) id<HDMyTinyShowsDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
