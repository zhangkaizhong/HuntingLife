//
//  FGUploadImageManager.m
//  FGUploadImageManager
//
//  Created by FengLe on 2018/4/2.
//  Copyright © 2018年 FengLe. All rights reserved.
//

#import "FGUploadImageManager.h"

@interface FGUploadImageManager ()

/**
 *  上传失败的数组
 */
@property (nonatomic, strong) NSMutableArray *failedIndexs;
/**
 *  上传图片数据
 */
@property (nonatomic, strong) NSArray *upLoadArray;
/**
 *  上传成功后图片URL
 */
@property (nonatomic, strong) NSMutableArray *imagesUrlArray;
/**
 *  标识的下标
 */
@property (nonatomic, assign) NSUInteger currentIndex;
/**
 某一张图片失败次数
 */
@property (nonatomic, assign) NSInteger onceFailedCount;

@end

//单张图片上传失败最大次数
const static NSInteger kMaxUploadCount = 3;

@implementation FGUploadImageManager

/**
 上传多张图片入口
 */
- (void)upLoadImageWithImageArray:(NSArray *)imageArray Completion:(void (^)(NSArray *, BOOL))completeUploadBlock
{
    [self cleanData];
    //初始化数据
    self.failedIndexs = [NSMutableArray array];
    self.imagesUrlArray = [NSMutableArray array];
    self.upLoadArray = [NSArray arrayWithArray:imageArray];
    
    [self upLoadPhotosOnceCompletion:^(NSUInteger index, BOOL isSuccess) {
        if (isSuccess) {
            //添加上传成功后的动作...(刷新UI等)
            DTLog(@"上传第%zd照片",index);
        }
        else {
            [self.failedIndexs addObject:@(index)];
        }
    } completeBlock:^{
        if (self.failedIndexs.count != 0) {
            NSMutableString *mutableString = [NSMutableString string];
            for (NSNumber *index in self.failedIndexs) {
                [mutableString appendFormat:@"第%@张",index];
            }
            DTLog(@"%@上传失败",mutableString);
        }else{
            DTLog(@"图片全部上传成功");
            if (self.imagesUrlArray.count > 0){
                if (completeUploadBlock) {
                    completeUploadBlock(self.imagesUrlArray,1);
                }
            }
        }
        [self cleanData];
    }];
}


/**
 *  递归上传照片
 */
- (void)upLoadPhotosOnceCompletion:(void(^)(NSUInteger index,BOOL isSuccess))onceCompletion completeBlock:(void(^)(void))completeBlock{
    
    //发起网络请求
    [MHNetworkManager uploadFileWithURL:URL_UploadFile params:nil imageFile:self.upLoadArray[self.currentIndex] successBlock:^(NSDictionary *returnData) {
        if ([returnData[@"respCode"] integerValue] == 200) {
            [self.imagesUrlArray addObject:returnData[@"data"]];
            //清空失败次数
            self.onceFailedCount = 0;
            //记录新的下标index++
            self.currentIndex++;
            //回调一次的结果
            if (onceCompletion) onceCompletion(self.currentIndex,1);
            //判断是否上传完毕
            if (self.currentIndex == self.upLoadArray.count) {
                //如果是已经上传完了,结束
                self.currentIndex = 0 ;
                if (completeBlock) completeBlock();
            }
            else{
                //如果还没上传完成,继续下一次上传
                [self upLoadPhotosOnceCompletion:onceCompletion completeBlock:completeBlock];
            }
        }
        else{
            self.onceFailedCount++;
            if (self.onceFailedCount < kMaxUploadCount) {
                [self upLoadPhotosOnceCompletion:onceCompletion completeBlock:completeBlock];
                return;
            }
        }
        
        
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

/**
 清空数据
 */
- (void)cleanData
{
    self.onceFailedCount = 0;
    self.currentIndex = 0;
    
    if (self.upLoadArray) {
        self.upLoadArray = nil;
    }
    if (self.failedIndexs) {
        [self.failedIndexs removeAllObjects];
        self.failedIndexs = nil;
    }
}

@end
