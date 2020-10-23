//
//  HDUserDefaultMethods.h
//  HairDress
//
//  Created by Apple on 2019/12/31.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDUserDefaultMethods : NSObject

@property (nonatomic, strong) NSString * accessToken;
@property (nonatomic, strong) NSString * accessTokenTime;
@property (nonatomic, strong) NSString * account;
@property (nonatomic, strong) NSString * authTime;
@property (nonatomic, strong) NSString * balance;
@property (nonatomic, strong) NSString * bankName;
@property (nonatomic, strong) NSString * bankNo;
@property (nonatomic, strong) NSString * createTime;
@property (nonatomic, strong) NSString * equipmentNo;
@property (nonatomic, strong) NSString * expireTime;
@property (nonatomic, strong) NSString * fatherPhone;
@property (nonatomic, strong) NSString * feature;
@property (nonatomic, strong) NSString * gender;
@property (nonatomic, strong) NSString * graFatherPhone;
@property (nonatomic, strong) NSString * graParentId;
@property (nonatomic, strong) NSString * headImg;
@property (nonatomic, strong) NSString * historyBalance;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * imToken;
@property (nonatomic, strong) NSString * isLimit;
@property (nonatomic, strong) NSString * isOldMember;
@property (nonatomic, strong) NSString * isPartner;
@property (nonatomic, strong) NSString * isRegister;
@property (nonatomic, strong) NSString * isSuperPartner;
@property (nonatomic, strong) NSString * jdPid;
@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) NSString * oldParentId;
@property (nonatomic, strong) NSString * openId;
@property (nonatomic, strong) NSString * parentId;
@property (nonatomic, strong) NSString * parentTree;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * pddPid;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * pid;
@property (nonatomic, strong) NSString * registerTime;
@property (nonatomic, strong) NSString * relationAuthUrl;
@property (nonatomic, strong) NSString * relationId;
@property (nonatomic, strong) NSString * sid;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * storeId;
@property (nonatomic, strong) NSString * storePost;// B:老板/T:理发师/O:其他员工
@property (nonatomic, strong) NSString * storeStartTime;
@property (nonatomic, strong) NSString * taoId;
@property (nonatomic, strong) NSString * taoNick;
@property (nonatomic, strong) NSString * teamNum;
@property (nonatomic, strong) NSString * unionId;
@property (nonatomic, strong) NSString * userGender;
@property (nonatomic, strong) NSString * userLevel;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * userTag;
@property (nonatomic, strong) NSString * userToken;
@property (nonatomic, strong) NSString * userType;
@property (nonatomic, strong) NSString * webOpenId;
@property (nonatomic, strong) NSString * wxImg;
@property (nonatomic, strong) NSString * wxNo;

#pragma mark ----- NSUserDefaults存取数据
//存和改
+ (void) saveData:(id)obj andKey:(NSString *)key;
//取
+ (id) getData:(NSString *)key;
//删
+ (void) removeData:(NSString *)key;

// 清空缓存数据
+(void)logout;
//// 保存数据
//-(void)saveToFile;
//// 读取数据
//-(void)loadFromFile;
//
//+(id)getInstance;

@end

NS_ASSUME_NONNULL_END
