//
//  HDTaskListModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/5.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTaskListModel : NSObject

@property (nonatomic,copy) NSString *finishDate;
@property (nonatomic,copy) NSString *finishNum;
@property (nonatomic,copy) NSString *isCount;
@property (nonatomic,copy) NSString *page;
@property (nonatomic,copy) NSString *taskId;
@property (nonatomic,copy) NSString *taskMoney;
@property (nonatomic,copy) NSString *taskName;
@property (nonatomic,copy) NSString *taskTags;
@property (nonatomic,copy) NSString *taskType;
@property (nonatomic,copy) NSString *taskDesc;
@property (nonatomic,copy) NSString *taskImg;
@property (nonatomic,copy) NSString *topFlag;

//frame
@property (nonatomic,assign) CGRect taskImgFrame;
@property (nonatomic,assign) CGRect taskMoneyImgFrame;
@property (nonatomic,assign) CGRect taskTypeFrame;
@property (nonatomic,assign) CGRect taskDescFrame;
@property (nonatomic,assign) CGRect lineFrame;

@property (nonatomic,assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
