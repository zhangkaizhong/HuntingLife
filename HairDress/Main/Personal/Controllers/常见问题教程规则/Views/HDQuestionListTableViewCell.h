//
//  HDQuestionListTableViewCell.h
//  HairDress
//
//  Created by 张凯中 on 2020/6/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HDQuestionModel.h"

@protocol HDQuestionListDelegate <NSObject>

-(void)clickCheckMoreQuestionWithModel:(HDQuestionModel *_Nullable)model;
-(void)clickCheckQuestionDetailWithDic:(NSDictionary *_Nullable)dicQuest;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HDQuestionListTableViewCell : UITableViewCell

@property (nonatomic,strong) HDQuestionModel *model;

@property (nonatomic,assign) id<HDQuestionListDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
