//
//  ZKZCleanCaches.h
//  HairDress
//
//  Created by 张凯中 on 2020/2/19.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKZCleanCaches : NSObject

+ (float)fileSizeAtPath:(NSString *)path;

+ (float)folderSizeAtPath:(NSString *)path;

+ (void)clearCache:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
