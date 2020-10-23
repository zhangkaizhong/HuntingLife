//
//  NotificationService.m
//  VoicePushExtention
//
//  Created by 张凯中 on 2020/6/16.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "NotificationService.h"
#import "JPushNotificationExtensionService.h"

API_AVAILABLE(ios(10.0))
API_AVAILABLE(ios(10.0))
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler  API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)){
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *dicInfo = request.content.userInfo;
    /**
       request.content.userInfo:
     {
        "_j_business" = 1;
        "_j_msgid" = 9007265374329255;
        "_j_uid" = 36881794289;
        aps =     {
            alert =         {
                body = "\U63a8\U9001";
                title = "\U63a8\U9001\U4e2a\U9b3c";
            };
            badge = 1;
            "mutable-content" = 1;
            sound = default;
        };
        contentType = cpsIndex;SignInVoice
     }
     */
    
    if ([dicInfo[@"isVoice"] isEqualToString:@"T"]) {
        if ([dicInfo[@"voiceType"] isEqualToString:@"newOrder"]) {
            self.bestAttemptContent.sound = [UNNotificationSound soundNamed:@"NewOrderVoice.mp3"];
        }
        else{
            self.bestAttemptContent.sound = [UNNotificationSound soundNamed:@"SignInVoice.mp3"];
        }
    }
    
    self.contentHandler(self.bestAttemptContent);
  
}

- (void)downloadAndSave:(NSURL *)fileURL handler:(void (^)(NSString *))handler {
  
  NSURLSession * session = [NSURLSession sharedSession];
  NSURLSessionDownloadTask *task = [session downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSString *localPath = nil;
    if (!error) {
      NSString * localURL = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(),fileURL.lastPathComponent];
      if ([[NSFileManager defaultManager] moveItemAtPath:location.path toPath:localURL error:nil]) {
        localPath = localURL;
      }
    }
    handler(localPath);
  }];
  [task resume];
  
}

- (void)apnsDeliverWith:(UNNotificationRequest *)request  API_AVAILABLE(ios(10.0)){
  
  //please invoke this func on release version
  //[JPushNotificationExtensionService setLogOff];
  
  //service extension sdk
  //upload to calculate delivery rate
  [JPushNotificationExtensionService jpushSetAppkey:@"AppKey copied from JiGuang Portal application"];
  [JPushNotificationExtensionService jpushReceiveNotificationRequest:request with:^ {
    NSLog(@"apns upload success");
    self.contentHandler(self.bestAttemptContent);
  }];
}

- (void)serviceExtensionTimeWillExpire {
  self.contentHandler(self.bestAttemptContent);
}

@end
