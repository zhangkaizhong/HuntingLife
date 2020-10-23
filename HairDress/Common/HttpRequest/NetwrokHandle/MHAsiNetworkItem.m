//
//  MHAsiNetworkItem.m
//  MHProject
//
//  Created by MengHuan on 15/4/23.
//  Copyright (c) 2015年 MengHuan. All rights reserved.
//

#import "MHAsiNetworkItem.h"
#import "AFNetworking.h"
#import "MHAsiNetworkDefine.h"
@interface MHAsiNetworkItem ()

@end

@implementation MHAsiNetworkItem


#pragma mark - 创建一个网络请求项，开始请求网络
/**
 *  创建一个网络请求项，开始请求网络
 *
 *  @param networkType  网络请求方式
 *  @param url          网络请求URL
 *  @param params       网络请求参数
 *  @param delegate     网络请求的委托，如果没有取消网络请求的需求，可传nil
 *  @param hashValue    网络请求的委托delegate的唯一标示
 *  @param showHUD      是否显示HUD
 *  @param successBlock 请求成功后的block
 *  @param failureBlock 请求失败后的block
 *
 *  @return MHAsiNetworkItem对象
 */
- (MHAsiNetworkItem *)initWithtype:(MHAsiNetWorkType)networkType
                               url:(NSString *)url
                            params:(NSDictionary *)params
                          delegate:(id)delegate
                            target:(id)target
                            action:(SEL)action
                         hashValue:(NSUInteger)hashValue
                           showHUD:(BOOL)showHUD
                      successBlock:(MHAsiSuccessBlock)successBlock
                      failureBlock:(MHAsiFailureBlock)failureBlock
{
    if (self = [super init])
    {
        self.networkType    = networkType;
        self.url            = url;
        self.params         = params;
        self.delegate       = delegate;
        self.showHUD        = showHUD;
        self.tagrget        = target;
        self.select         = action;
        
        if (showHUD==YES) {
            [SVHUDHelper showLoadingHUD];
        }
        
        __weak typeof(self)weakSelf = self;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", nil];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        // 设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 10.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        // 请求头添加userToken
        NSString *userToken = [HDUserDefaultMethods getData:@"userToken"];
        if (![HDToolHelper StringIsNullOrEmpty:userToken]) {
            [manager.requestSerializer setValue:userToken forHTTPHeaderField:@"token"];
        }
        [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"requestSource"];
        
        if (networkType==MHAsiNetWorkGET)
        {
            [manager GET:url parameters:params headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [SVProgressHUD dismiss];
                DTLog(@"\n\n----请求的返回结果 %@\n",responseObject);
                if (successBlock) {
                    successBlock(responseObject);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
                    [weakSelf.delegate requestDidFinishLoading:responseObject];
                }
                [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:responseObject withObject:nil];
                [weakSelf removewItem];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [SVProgressHUD dismiss];
                DTLog(@"get---error==%@\n",error.localizedDescription);
                if (failureBlock) {
                    failureBlock(error);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(requestdidFailWithError:)]) {
                    [weakSelf.delegate requestdidFailWithError:error];
                }
                [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:nil withObject:error];
                [weakSelf removewItem];
            }];
            
        }else{
            [manager POST:url parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [SVProgressHUD dismiss];
                DTLog(@"请求头信息%@",task.originalRequest.allHTTPHeaderFields);
                DTLog(@"\n\n----请求的返回结果 %@\n",responseObject);
                responseObject = [HDToolHelper nullDicToDic:responseObject];
                if ([responseObject[@"respCode"] integerValue] == 402 && ![url isEqualToString:URL_UserQueryMoneyInfo]) {
                    //请先登录
                    [[WMZAlert shareInstance] showAlertWithType:AlertTypeNornal headTitle:@"提示" textTitle:@"您长时间未登录，是否重新登录？" viewController:[HDToolHelper getCurrentVC] leftHandle:^(id anyID) {
                        //取消
                    }rightHandle:^(id any) {
                        //确定
                        [weakSelf preToLoginView];
                    }];
                }else{
                    if (successBlock) {
                        successBlock(responseObject);
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
                        [weakSelf.delegate requestDidFinishLoading:responseObject];
                    }
                    [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:responseObject withObject:nil];
                    [weakSelf removewItem];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [SVProgressHUD dismiss];
                [SVHUDHelper showWorningMsg:@"服务器异常" timeInt:1];
                DTLog(@"post---error==%@\n",error.localizedDescription);
                if (failureBlock) {
                    failureBlock(error);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(requestdidFailWithError:)]) {
                    [weakSelf.delegate requestdidFailWithError:error];
                }
                [weakSelf performSelector:@selector(finishedRequest: didFaild:) withObject:nil withObject:error];
                [weakSelf removewItem];
            }];
        }
    }
    return self;
}
/**
 *   移除网络请求项
 */
- (void)removewItem
{
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(netWorkWillDealloc:)]) {
            [weakSelf.delegate netWorkWillDealloc:weakSelf];
        }
    });
}

- (void)finishedRequest:(id)data didFaild:(NSError*)error
{
    if ([self.tagrget respondsToSelector:self.select]) {
        [self.tagrget performSelector:@selector(finishedRequest:didFaild:) withObject:data withObject:error];
    }
}

- (void)dealloc
{
    
    
}

//跳转登录页
-(void)preToLoginView{
    [HDUserDefaultMethods logout];
    
    [HDToolHelper preToLoginView];
}

@end
