//
//  HDQuestionModel.h
//  HairDress
//
//  Created by 张凯中 on 2020/6/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDQuestionModel : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *question_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *isSelect;

@property (nonatomic,strong) NSArray *list;

@property (nonatomic,assign) CGFloat cellHeight;

@property (nonatomic, assign) CGRect btnArrowFrame;
@property (nonatomic, assign) CGRect lineFrame;
@property (nonatomic, assign) CGRect questionListFrame;


@end

NS_ASSUME_NONNULL_END
