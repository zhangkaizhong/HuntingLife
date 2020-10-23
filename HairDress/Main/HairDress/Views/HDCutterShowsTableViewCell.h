//
//  HDCutterShowsTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2019/12/24.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDCutterShowsImageDelegate <NSObject>

-(void)clickShowBigImage:(NSInteger)indexCount currentView:(UIImageView *_Nullable)img;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDCutterShowsTableViewCell : UITableViewCell

@property (nonatomic,strong)UICollectionView *collectView;
@property(nonatomic,strong) NSArray *arrData;
@property (nonatomic,assign) id<HDCutterShowsImageDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
