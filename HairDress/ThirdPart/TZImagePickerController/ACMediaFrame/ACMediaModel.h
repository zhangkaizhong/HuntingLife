//
//  ACMediaModel.h
//
//  Created by caoyq on 2018/11/26.
//  Copyright © 2018 AllenCao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ACMediaModel : NSObject

///文件名
@property (nonatomic, strong) NSString *name;
///二进制文件数据
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) PHAsset *asset;

///图片、gif以及视频的封面图
@property (nonatomic, strong) UIImage *image;

///视频URL(单选视频会有，多选的话只有data)
@property (nonatomic, strong) NSURL *videoURL;

#pragma mark - methods

///处理 UIImagePickerControllerDelegate 得到的数据
+ (instancetype)mediaInfoWithDict: (NSDictionary *)dict;

///处理 TZImagePickerControllerDelegate 中得到的图片与gif
+ (instancetype)imageInfoWithAsset: (PHAsset *)asset image: (UIImage *)image;
///处理 TZImagePickerControllerDelegate 中得到的视频
+ (void)videoInfoWithAsset: (PHAsset *)asset coverImage: (UIImage *)coverImage completion: (void(^)(ACMediaModel *model))completion;

@end

@interface ACMediaModel (Tool)

///获取图片二进制数据
+ (NSData *)imageDataWithImage: (UIImage *)image;
///获取视频二进制数据
+ (void)videoDataWithAsset: (PHAsset *)asset completion: (void(^)(NSData *data, NSURL *videoURL))completion;

///获取图片名
+ (NSString *)imageNameWithAsset: (PHAsset *)asset;
///获取视频名
+ (NSString *)videoNameWithAsset: (PHAsset *)asset;

///获取视频封面图
+ (UIImage *)coverImageWithVideoURL: (NSURL *)videoURL;

///获取修正方向后的图片
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
