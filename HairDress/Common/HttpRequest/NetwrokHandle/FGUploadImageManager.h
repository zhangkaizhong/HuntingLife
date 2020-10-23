//
//  FGUploadImageManager.h
//  FGUploadImageManager
//
//  Created by FengLe on 2018/4/2.
//  Copyright © 2018年 FengLe. All rights reserved.
//  多张图片逐张上传

#import <Foundation/Foundation.h>

@interface FGUploadImageManager : NSObject


- (void)upLoadImageWithImageArray:(NSArray *)imageArray Completion:(void(^)(NSArray *imageUrls,BOOL isSuccess))completeUploadBlock;


@end
