//
//  YHWorkGroup.h
//  github:  https://github.com/samuelandkevin
//
//  Created by samuelandkevin on 16/5/5.
//  Copyright © 2016年 HKP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDCutterDetailModel : NSObject

@property (nonatomic, copy)   NSString *amount;
@property (nonatomic, copy)   NSString *headImg;
@property (nonatomic, copy)   NSString *serviceTenet;
@property (nonatomic, copy)   NSString *storeId;
@property (nonatomic, copy)   NSString *storeName;
@property (nonatomic, copy)   NSString *tonyId;
@property (nonatomic, copy)   NSString *userName;
@property (nonatomic, copy)   NSString *queueNumber;
@property (nonatomic, copy)   NSString *waitTime;
@property (nonatomic, copy)   NSString *workingLife;

@property (nonatomic, copy)   NSString *workingLifeText;

@property (nonatomic, copy)   NSArray *labels;

@property (nonatomic, strong) NSArray <NSURL *>*originalPicUrls; //原图像Url
@property (nonatomic, strong) NSArray <NSURL *>*thumbnailPicUrls;//缩略图Url


@end

