//
//  HDWebContentModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/6/12.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWebContentModel : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *content_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *isSelect;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *updateTime;

@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGFloat selectedCellHeight;

@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) CGRect lineFrame;
@property (nonatomic, assign) CGRect webContentFrame;


@end

NS_ASSUME_NONNULL_END
