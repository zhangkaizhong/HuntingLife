//
//  HDCutterResumeExpModel.h
//  HairDress
//
//  Created by Apple on 2020/1/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  发型师经验列表model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDCutterResumeExpModel : NSObject

@property (nonatomic,copy) NSString *endTime;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *storeName;
@property (nonatomic,copy) NSString *expId;

@property (nonatomic,assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
