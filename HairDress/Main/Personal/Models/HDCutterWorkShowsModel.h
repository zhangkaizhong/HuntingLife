//
//  HDCutterWorkShowsModel.h
//  HairDress
//
//  Created by Apple on 2020/1/8.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//  发型师作品集model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDCutterWorkShowsModel : NSObject

@property (nonatomic,copy) NSString *imgUrl;
@property (nonatomic,copy) NSString *worksName;
@property (nonatomic,copy) NSString *workId;

@property (nonatomic,assign) CGRect imageFrame;
@property (nonatomic,assign) CGRect labelFrame;

@property (nonatomic,assign) CGFloat cellHegiht;

@end

NS_ASSUME_NONNULL_END
