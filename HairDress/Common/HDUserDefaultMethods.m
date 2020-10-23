//
//  HDUserDefaultMethods.m
//  HairDress
//
//  Created by Apple on 2019/12/31.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDUserDefaultMethods.h"

//static HDUserDefaultMethods * gUserInfo = nil;

@implementation HDUserDefaultMethods


#pragma mark ----- 存取数据
// 存和改
+ (void)saveData:(id)obj andKey:(NSString *)key
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:obj forKey:key];
    [def synchronize];
    
}
// 取
+ (id)getData:(NSString *)key
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    id data = [def objectForKey:key];
    return data ? data : @"";
}
// 删
+ (void)removeData:(NSString *)key
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:key];
    [def synchronize];
}

//清空缓存
+(void)logout{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [def dictionaryRepresentation];
    for(NSString* key in [dictionary allKeys]){
        if (![key isEqualToString:JPUSH_REGID]) {
            [def removeObjectForKey:key];
        }
    }
    [def synchronize];
}

//-(void)logout{
//
//    self.accessToken = @"";
//    self.accessTokenTime = @"";
//    self.account = @"";
//    self.authTime = @"";
//    self.balance = @"";
//    self.bankName = @"";
//    self.bankNo = @"";
//    self.createTime = @"";
//    self.equipmentNo = @"";
//    self.expireTime = @"";
//    self.fatherPhone = @"";
//    self.feature = @"";
//    self.gender = @"";
//    self.graFatherPhone = @"";
//    self.graParentId = @"";
//    self.headImg = @"";
//    self.historyBalance = @"";
//    self.userId = @"";
//    self.imToken = @"";
//    self.isLimit = @"";
//    self.isOldMember = @"";
//    self.isPartner = @"";
//    self.isRegister = @"";
//    self.isSuperPartner = @"";
//    self.jdPid = @"";
//    self.nickName = @"";
//    self.oldParentId = @"";
//    self.openId = @"";
//    self.parentId = @"";
//    self.parentTree = @"";
//    self.password = @"";
//    self.pddPid = @"";
//    self.phone = @"";
//    self.pid = @"";
//    self.registerTime = @"";
//    self.relationAuthUrl = @"";
//    self.relationId = @"";
//    self.sid = @"";
//    self.status = @"";
//    self.storeId = @"";
//    self.storePost = @"";
//    self.storeStartTime = @"";
//    self.taoId = @"";
//    self.taoNick = @"";
//    self.teamNum = @"";
//    self.unionId = @"";
//    self.userGender = @"";
//    self.userLevel = @"";
//    self.userName = @"";
//    self.userTag = @"";
//    self.userToken = @"";
//    self.userType = @"";
//    self.webOpenId = @"";
//    self.wxImg = @"";
//    self.wxNo = @"";
//
//    [self saveToFile];
//}
//
//-(void)saveToFile{
//    NSMutableDictionary * _dictUserInfo = [[NSMutableDictionary alloc] init];
//
//    [_dictUserInfo setValue:self.accessToken forKey:@"accessToken"];
//    [_dictUserInfo setValue:self.accessTokenTime forKey:@"accessTokenTime"];
//    [_dictUserInfo setValue:self.account forKey:@"account"];
//    [_dictUserInfo setValue:self.authTime forKey:@"authTime"];
//    [_dictUserInfo setValue:self.balance forKey:@"balance"];
//    [_dictUserInfo setValue:self.bankName forKey:@"bankName"];
//    [_dictUserInfo setValue:self.bankNo forKey:@"bankNo"];
//    [_dictUserInfo setValue:self.createTime forKey:@"createTime"];
//    [_dictUserInfo setValue:self.equipmentNo forKey:@"equipmentNo"];
//    [_dictUserInfo setValue:self.expireTime forKey:@"expireTime"];
//    [_dictUserInfo setValue:self.fatherPhone forKey:@"fatherPhone"];
//    [_dictUserInfo setValue:self.feature forKey:@"feature"];
//    [_dictUserInfo setValue:self.gender forKey:@"gender"];
//    [_dictUserInfo setValue:self.graFatherPhone forKey:@"graFatherPhone"];
//    [_dictUserInfo setValue:self.graParentId forKey:@"graParentId"];
//    [_dictUserInfo setValue:self.headImg forKey:@"headImg"];
//    [_dictUserInfo setValue:self.userId forKey:@"userId"];
//    [_dictUserInfo setValue:self.imToken forKey:@"imToken"];
//    [_dictUserInfo setValue:self.isLimit forKey:@"isLimit"];
//    [_dictUserInfo setValue:self.isOldMember forKey:@"isOldMember"];
//    [_dictUserInfo setValue:self.isPartner forKey:@"isPartner"];
//    [_dictUserInfo setValue:self.isRegister forKey:@"isRegister"];
//    [_dictUserInfo setValue:self.isSuperPartner forKey:@"isSuperPartner"];
//    [_dictUserInfo setValue:self.jdPid forKey:@"jdPid"];
//    [_dictUserInfo setValue:self.nickName forKey:@"nickName"];
//    [_dictUserInfo setValue:self.oldParentId forKey:@"oldParentId"];
//    [_dictUserInfo setValue:self.openId forKey:@"openId"];
//    [_dictUserInfo setValue:self.parentId forKey:@"parentId"];
//    [_dictUserInfo setValue:self.parentTree forKey:@"parentTree"];
//    [_dictUserInfo setValue:self.password forKey:@"password"];
//    [_dictUserInfo setValue:self.pddPid forKey:@"pddPid"];
//    [_dictUserInfo setValue:self.phone forKey:@"phone"];
//    [_dictUserInfo setValue:self.pid forKey:@"pid"];
//    [_dictUserInfo setValue:self.registerTime forKey:@"registerTime"];
//    [_dictUserInfo setValue:self.relationAuthUrl forKey:@"relationAuthUrl"];
//    [_dictUserInfo setValue:self.relationId forKey:@"relationId"];
//    [_dictUserInfo setValue:self.sid forKey:@"sid"];
//    [_dictUserInfo setValue:self.status forKey:@"status"];
//    [_dictUserInfo setValue:self.storeId forKey:@"storeId"];
//    [_dictUserInfo setValue:self.storePost forKey:@"storePost"];
//    [_dictUserInfo setValue:self.storeStartTime forKey:@"storeStartTime"];
//    [_dictUserInfo setValue:self.taoId forKey:@"taoId"];
//    [_dictUserInfo setValue:self.taoNick forKey:@"taoNick"];
//    [_dictUserInfo setValue:self.teamNum forKey:@"teamNum"];
//    [_dictUserInfo setValue:self.unionId forKey:@"unionId"];
//    [_dictUserInfo setValue:self.userGender forKey:@"userGender"];
//    [_dictUserInfo setValue:self.userLevel forKey:@"userLevel"];
//    [_dictUserInfo setValue:self.userName forKey:@"userName"];
//    [_dictUserInfo setValue:self.userTag forKey:@"userTag"];
//    [_dictUserInfo setValue:self.userToken forKey:@"userToken"];
//    [_dictUserInfo setValue:self.userType forKey:@"userType"];
//    [_dictUserInfo setValue:self.webOpenId forKey:@"webOpenId"];
//    [_dictUserInfo setValue:self.wxImg forKey:@"wxImg"];
//    [_dictUserInfo setValue:self.wxNo forKey:@"wxNo"];
//
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//    NSString * filePath = [NSString stringWithFormat:@"%@/%@",docDir,@"user.plist"];
//    [_dictUserInfo writeToFile:filePath atomically:YES];
//}
//
//-(void)loadFromFile{
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//    NSString * filePath = [NSString stringWithFormat:@"%@/%@",docDir,@"user.plist"];
//    NSDictionary * _dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
//
//    self.accessToken = [_dict objectForKey:@"accessToken"];
//    self.accessTokenTime = [_dict objectForKey:@"accessTokenTime"];
//    self.account = [_dict objectForKey:@"account"];
//    self.userId =  [_dict objectForKey:@"userId"];
//    self.authTime = [_dict objectForKey:@"authTime"];
//    self.balance = [_dict objectForKey:@"balance"];
//    self.bankName = [_dict objectForKey:@"bankName"];
//    self.bankNo = [_dict objectForKey:@"bankNo"];
//    self.createTime = [_dict objectForKey:@"createTime"];
//    self.equipmentNo = [_dict objectForKey:@"equipmentNo"];
//    self.expireTime = [_dict objectForKey:@"expireTime"];
//    self.fatherPhone = [_dict objectForKey:@"fatherPhone"];
//    self.feature = [_dict objectForKey:@"feature"];
//    self.gender = [_dict objectForKey:@"gender"];
//    self.graFatherPhone = [_dict objectForKey:@"graFatherPhone"];
//    self.graParentId = [_dict objectForKey:@"graParentId"];
//    self.headImg = [_dict objectForKey:@"headImg"];
//    self.historyBalance = [_dict objectForKey:@"historyBalance"];
//    self.userId = [_dict objectForKey:@"userId"];
//    self.imToken = [_dict objectForKey:@"imToken"];
//    self.isLimit = [_dict objectForKey:@"isLimit"];
//    self.isOldMember = [_dict objectForKey:@"isOldMember"];
//    self.isPartner = [_dict objectForKey:@"isPartner"];
//    self.isRegister = [_dict objectForKey:@"isRegister"];
//    self.isSuperPartner = [_dict objectForKey:@"isSuperPartner"];
//    self.jdPid = [_dict objectForKey:@"jdPid"];
//    self.nickName = [_dict objectForKey:@"nickName"];
//    self.oldParentId = [_dict objectForKey:@"oldParentId"];
//    self.openId = [_dict objectForKey:@"openId"];
//    self.parentId = [_dict objectForKey:@"parentId"];
//    self.parentTree = [_dict objectForKey:@"parentTree"];
//    self.password = [_dict objectForKey:@"password"];
//    self.pddPid = [_dict objectForKey:@"pddPid"];
//    self.phone = [_dict objectForKey:@"phone"];
//    self.pid = [_dict objectForKey:@"pid"];
//    self.registerTime = [_dict objectForKey:@"registerTime"];
//    self.relationAuthUrl = [_dict objectForKey:@"relationAuthUrl"];
//    self.relationId = [_dict objectForKey:@"relationId"];
//    self.sid = [_dict objectForKey:@"sid"];
//    self.status = [_dict objectForKey:@"status"];
//    self.storeId = [_dict objectForKey:@"storeId"];
//    self.storePost = [_dict objectForKey:@"storePost"];
//    self.storeStartTime = [_dict objectForKey:@"storeStartTime"];
//    self.taoId = [_dict objectForKey:@"taoId"];
//    self.taoNick = [_dict objectForKey:@"taoNick"];
//    self.teamNum = [_dict objectForKey:@"teamNum"];
//    self.unionId = [_dict objectForKey:@"unionId"];
//    self.userGender = [_dict objectForKey:@"userGender"];
//    self.userLevel = [_dict objectForKey:@"userLevel"];
//    self.userName = [_dict objectForKey:@"userName"];
//    self.userTag = [_dict objectForKey:@"userTag"];
//    self.userToken = [_dict objectForKey:@"userToken"];
//    self.userType = [_dict objectForKey:@"userType"];
//    self.webOpenId = [_dict objectForKey:@"webOpenId"];
//    self.wxImg = [_dict objectForKey:@"wxImg"];
//    self.wxNo = [_dict objectForKey:@"wxNo"];
//}
//
//
//+(id)getInstance{
//    if (gUserInfo == nil) {
//        gUserInfo = [[HDUserDefaultMethods alloc] init];
//        [gUserInfo loadFromFile];
//    }
//    return gUserInfo;
//}

@end
