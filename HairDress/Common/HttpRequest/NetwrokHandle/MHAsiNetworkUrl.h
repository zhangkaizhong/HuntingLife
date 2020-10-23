//
//  MHAsiNetworkUrl.h
//  MHProject
//
//  Created by MengHuan on 15/4/23.
//  Copyright (c) 2015年 MengHuan. All rights reserved.
//

#ifndef MHProject_MHAsiNetworkUrl_h
#define MHProject_MHAsiNetworkUrl_h
///**
// *  正式环境
// */
//#define API_HOST @"http://123.59.61.167/api/JNWTV"

///**
// *   测试环境
// */
#define API_HOST @"https://cl.chaoliuapp.com"

//      接口路径全拼
#define PATH(_path)             [NSString stringWithFormat:_path, API_HOST]

/**
 *      上传图片
 */
#define URL_UploadFile       PATH(@"%@/api/oss/uploadFile")

#pragma mark ================== 通用接口 =====================

//获取短信验证码
#define URL_SendPhoneCode         PATH(@"%@/api/memberApi/sendCode")
//查询地区数据
#define URL_AreasQueryAll         PATH(@"%@/api/area/queryAll")
//查询地区数据
#define URL_AreasQueryList         PATH(@"%@/api/area/queryList")
//获取所有地区数据（未分组）
#define URL_AreasFindAll        PATH(@"%@/api/area/findAll")
//获取所有地区数据列表（按省市区分组）
#define URL_AreasList        PATH(@"%@/api/area/list")
//根据市级id查询商圈列表
#define URL_TradeAreaList        PATH(@"%@/api/area/queryTradeArea")
//轮播列表
#define URL_GetBannarList         PATH(@"%@/api/appIndex/bannerList")

#pragma mark ================== 登录注册相关接口 =====================
//手机注册
#define URL_RegisterPhone         PATH(@"%@/api/memberApi/phoneRegister")
//手机登录
#define URL_LoginPhone         PATH(@"%@/api/memberApi/phoneLogin")
//设置密码
#define URL_MemberSetPassword         PATH(@"%@/api/memberApi/setPassword")
//修改密码
#define URL_MemberUpdatePassword         PATH(@"%@/api/memberApi/updatePassword")
//忘记密码
#define URL_ResetPhonePwd         PATH(@"%@/api/memberApi/passwordPhone")
//（绑定）微信
#define URL_MemberBindWx         PATH(@"%@/api/memberApi/bindWx")
//微信（登录）
#define URL_MemberWXLogin         PATH(@"%@/api/memberApi/wxLogin")
//退出登录
#define URL_MemberLogout         PATH(@"%@/api/memberApi/logout")
//注销账号
#define URL_MemberLogoutMember         PATH(@"%@/api/memberApi/logoutMember")


#pragma mark ================== 门店注册接口 =====================

//门店注册(编辑)
#define URL_ShopRegister         PATH(@"%@/api/storeApi/register")
//门店注册(详情)
#define URL_ShopRegisterDetail        PATH(@"%@/api/storeApi/registerDetail")
//门店岗位列表
#define URL_StorePostList        PATH(@"%@/api/storeApi/storePostList")
//编辑门店详情
#define URL_EditStoreDetail       PATH(@"%@/api/storeApi/editStoreDetail")
//邀请店员(店主二维码)
#define URL_StoreInviteQRcode       PATH(@"%@/api/storeApi/inviteClerk")
//编辑门店
#define URL_EditStore       PATH(@"%@/api/storeApi/editStore")
//下拉类型(配置项类型)
#define URL_ConfigTypeList      PATH(@"%@/api/manageConfigApi/getConfigList")
//配置列表（客户端使用）
#define URL_ConfigList      PATH(@"%@/api/manageConfigApi/configList")

#pragma mark ================== 门店首页相关接口 =====================

//门店列表
#define URL_GetHomepage         PATH(@"%@/api/storeApi/storeList")
//根据当前定位获取区和商圈数据
#define URL_SearchQueryCityTrade         PATH(@"%@/api/area/queryCityTrade")
//门店详情
#define URL_GetsStoreDetail       PATH(@"%@/api/storeApi/storeDetail")
//我的门店发型师列表(我的店员)
#define URL_StoreTonyList       PATH(@"%@/api/tonyApi/storeTonyList")
//门店发型师列表（带搜索取号）
#define URL_TonyList       PATH(@"%@/api/tonyApi/tonyList")
//tony变更岗位
#define URL_StoreUpdateTonyPost       PATH(@"%@/api/tonyApi/updateTonyPost")
//编辑店员信息
#define URL_StoreEditTony       PATH(@"%@/api/tonyApi/editTony")
//删除店员
#define URL_StoreDeleteTony       PATH(@"%@/api/tonyApi/delTony")
//门店评价列表
#define URL_EvaluateList      PATH(@"%@/api/evaluateApi/evaluateList")
//门店评价各类型统计
#define URL_CountStoreEvaluate      PATH(@"%@/api/evaluateApi/countStoreEvaluate")
//tony评价统计
#define URL_CountTonyEvaluate      PATH(@"%@/api/evaluateApi/countTonyEvaluate")

//添加（编辑）剪发经验
#define URL_TonyAddExpManage      PATH(@"%@/api/tonyApi/addExpManage")
//剪发经验详情
#define URL_TonyExpManageDetail      PATH(@"%@/api/tonyApi/expManageDetail")
//删除剪发经验
#define URL_TonyDelResume      PATH(@"%@/api/tonyApi/delResume")
//添加作品集
#define URL_TonyAddWorkShows      PATH(@"%@/api/tonyApi/addWorks")
//删除作品集
#define URL_TonyDelWorksShow      PATH(@"%@/api/tonyApi/delWorks")
//剪发经验列表
#define URL_TonyExpManageList      PATH(@"%@/api/tonyApi/expManageList")
//作品集列表
#define URL_TonyWorkShowsManageList      PATH(@"%@/api/tonyApi/worksManageList")
//我的预约（tony）
#define URL_TonyOrderList      PATH(@"%@/api/tonyApi/tonyOrderList")
//店主-预约列表
#define URL_StoreOrderList      PATH(@"%@/api/yuyueApi/storeOrderList")
//店主发型师-预约数量
#define URL_StoreOrderNum      PATH(@"%@/api/yuyueApi/storeOrderNum")
//用户）我的订单数量
#define URL_UserOrderNum      PATH(@"%@/api/yuyueApi/userOrderNum")
//Tony详情
#define URL_TonyDetail      PATH(@"%@/api/tonyApi/tonyDetail")
//新增(门店，tony)收藏
#define URL_CollectStoreOrTony      PATH(@"%@/api/collectApi/storeOrTony")
//批量删除收藏
#define URL_CollectDelCollect      PATH(@"%@/api/collectApi/delCollect")
//查询是否收藏
#define URL_CollectCheckCollect      PATH(@"%@/api/collectApi/checkCollect")
//(门店，tony)收藏列表
#define URL_CollectList      PATH(@"%@/api/collectApi/collectList")

#pragma mark ================== 预约订单相关接口 =====================
//取号页
#define URL_StoreTakeNum      PATH(@"%@/api/storeApi/takeNum")
//理发预约
#define URL_YuyueCreateOrder      PATH(@"%@/api/yuyueApi/createOrder")
//（预约）时间段列表
#define URL_YuyueStoreTimeList         PATH(@"%@/api/storeTimeApi/timeList")
//到店签到
#define URL_YuyueStartQueue      PATH(@"%@/api/yuyueApi/startQueue")
//排队进度
#define URL_YuyueDetailOrder      PATH(@"%@/api/yuyueApi/detailOrder")
//排队进度(弹窗)
#define URL_YuyueDetailOrderPop      PATH(@"%@/api/yuyueApi/detailOrderPop")
//取号用户取消预约
#define URL_YuyueCancelOrder      PATH(@"%@/api/yuyueApi/cancelOrder")
//（用户）我的订单（待消费|服务中）
#define URL_YuyueUserOrder      PATH(@"%@/api/yuyueApi/userOrder")
//（用户）我的订单（已完成|已取消）
#define URL_YuyueUserOrderList      PATH(@"%@/api/yuyueApi/userOrderList")
// 发型师（开始服务）
#define URL_TonyStartService     PATH(@"%@/api/yuyueApi/startService")
// 发型师（完成服务）
#define URL_TonyFinishService     PATH(@"%@/api/yuyueApi/finishService")
// 新增评价
#define URL_EvaAddEvaluate     PATH(@"%@/api/evaluateApi/addEvaluate")
// (预约）支付统一下单接口
#define URL_PayToPay     PATH(@"%@/api/payApi/toPay")

#pragma mark ================== 淘客相关接口 =====================
// 淘客首页bar
#define URL_TaoBarList     PATH(@"%@/api/appIndex/barList")
// 首页结构
#define URL_TaoBarIndex     PATH(@"%@/api/appIndex/index")
// 楼层商品数据，淘首页加载更多
#define URL_TaoFloorGoodsList     PATH(@"%@/api/appIndex/floorGoodsList")
// 分类页（cpsBar）商品获取列表（普通楼层商品列表）
#define URL_TaoOtherGoodsList     PATH(@"%@/api/appIndex/otherGoodsList")
// icon商品列表
#define URL_TaoIconGoodsList     PATH(@"%@/api/appIndex/iconGoodsList")
// 商品详情
#define URL_TaoGoodsDetail     PATH(@"%@/api/goodsApi/goodsDetail")
// 生成淘口令--创建分享
#define URL_TaoGoodsCreateForShare     PATH(@"%@/api/goodsApi/tpwdCreateForShare")
// 商品高佣转链
#define URL_TaoFormatGoods   PATH(@"%@/api/goodsApi/formatGoods")
// 二维码发单图API
#define URL_TaoGoodsOpenQrpic     PATH(@"%@/api/goodsApi/openQrpic")
// 楼层(仅活动)详情
#define URL_TaoFloorActivityDetail     PATH(@"%@/api/floorActivityApp/floorActivityDetail")
// 楼层活动商品列表
#define URL_TaoFloorActivityGoodsList     PATH(@"%@/api/floorActivityApp/floorActivityGoodsList")
// 热门搜索标签列表
#define URL_TaoHotSearchList1     PATH(@"%@/api/appIndex/hotSearchList1")
// 商品搜索
#define URL_TaoGoodsSearch     PATH(@"%@/api/appIndex/searchGoodsList")
// 查询是否收藏
#define URL_TaoCheckUserGoods     PATH(@"%@/api/memberGoodsApi/checkUserGoods")
// 新增商品足迹，收藏
#define URL_TaoAddUserGoods     PATH(@"%@/api/memberGoodsApi/addUserGoods")
// 批量删除收藏
#define URL_TaoDelUserGoods     PATH(@"%@/api/memberGoodsApi/delUserGoods")
// 足迹，收藏列表
#define URL_TaoUserGoodsList     PATH(@"%@/api/memberGoodsApi/userGoodsList")

#pragma mark ================== 任务相关接口 =====================
// 查询APP任务首页数据
#define URL_TaskQueryAppTaskIndexNum     PATH(@"%@/api/taskAppApi/queryAppTaskIndexNum")
// 查询任务信息列表
#define URL_TaskQueryAppTaskList     PATH(@"%@/api/taskAppApi/queryAppTaskList")
// 查询我的任务统计信息
#define URL_TaskQueryUserTaskCountInfo     PATH(@"%@/api/taskAppApi/queryUserTaskCountInfo")
// 查询我的任务信息列表
#define URL_TaskQueryUserTaskList     PATH(@"%@/api/taskAppApi/queryUserTaskList")
// 查询我的任务信息详情
#define URL_TaskQueryUserTaskDetail     PATH(@"%@/api/taskAppApi/queryUserTaskDetail")
// 任务提交审核
#define URL_TaskSendCheck     PATH(@"%@/api/taskAppApi/taskSendCheck")
// 领取任务
#define URL_TaskAcceptTask     PATH(@"%@/api/taskAppApi/acceptTask")
// 查询任务信息详情
#define URL_TaskQueryAppTaskDetail     PATH(@"%@/api/taskAppApi/queryAppTaskDetail")
// 查询任务信息详情(完成用户滚动数据)
#define URL_TaskQueryAppTaskFinishData     PATH(@"%@/api/taskAppApi/queryAppTaskFinishData")

#pragma mark ================== 个人中心相关接口 =====================
// 获取分享信息
#define URL_UserGetAppConfigInfo     PATH(@"%@/api/appConfigApi/getAppConfigInfo")
// 查询用户数据
#define URL_UserGetMemberInfo     PATH(@"%@/api/memberApi/getMember")
// 完善用户信息
#define URL_UserSaveMemberInfo     PATH(@"%@/api/memberApi/saveMemberInfo")
// 查询个人中心收益信息接口
#define URL_UserQueryMoneyInfo     PATH(@"%@/api/settle/queryUserMoneyInfo")
// 用户收益列表数据
#define URL_UserProfitList     PATH(@"%@/api/dataMemberApi/userProfitList")
// Tony扫二维码详情
#define URL_ScanChooseStoreDetail     PATH(@"%@/api/tonyApi/chooseStoreDetail")
// Tony扫二维码选择门店
#define URL_ScanChooseJoinStore     PATH(@"%@/api/tonyApi/chooseStore")
// 银行卡类型
#define URL_WithdrawGetBankType     PATH(@"%@/api/withdrawApi/getBankType")
// 申请提现
#define URL_Withdraw     PATH(@"%@/api/withdrawApi/withdraw")
// 更新用户银行卡信息
#define URL_MemberUpdateBank     PATH(@"%@/api/memberApi/updateBank")
//提现配置详情
#define URL_MemberWithdrawConfigDetail         PATH(@"%@/api/withdrawApi/withdrawConfigDetail")
//App提现列表
#define URL_MemberWithdrawAppList         PATH(@"%@/api/withdrawApi/withdrawAppList")
//设置支付密码
#define URL_MemberSetPayPassword         PATH(@"%@/api/memberApi/setPayPassword")
//校验支付密码
#define URL_MemberCheckPassword         PATH(@"%@/api/memberApi/checkPassword")
//修改支付密码
#define URL_MemberUpdatePayPassword         PATH(@"%@/api/memberApi/updatePayPassword")
//忘记支付密码验证手机号
#define URL_MemberPayPasswordPhone         PATH(@"%@/api/memberApi/payPasswordPhone")
//查询粉丝总数和上级邀请人名称
#define URL_FansNumAndFatherName         PATH(@"%@/api/memberApi/queryFansNumAndFatherName")
//分页查询全部粉丝
#define URL_FansQueryTotalTeamFans         PATH(@"%@/api/memberApi/queryTotalTeamFans")
//查询订单接口(商品订单)
#define URL_TaoQueryOrderList         PATH(@"%@/api/orderApi/queryOrder")
//门店配置列表
#define URL_StoreConfigList         PATH(@"%@/api/storeConfigApi/list")
//新增|编辑门店配置
#define URL_StoreEditStoreConfig         PATH(@"%@/api/storeConfigApi/editStoreConfig")
//删除门店配置
#define URL_StoreDelStoreConfig         PATH(@"%@/api/storeConfigApi/delStoreConfig")
//门店|tony收益统计
#define URL_StoreCountSettle         PATH(@"%@/api/settleApi/countSettle")
//门店收益列表
#define URL_StoreSettleIncomeList         PATH(@"%@/api/settleApi/list")
//时间段列表
#define URL_StoreTimeList         PATH(@"%@/api/storeTimeApi/list")
//新增|编辑时间段
#define URL_StoreTimeEdit         PATH(@"%@/api/storeTimeApi/editStoreTime")
//删除时间段
#define URL_StoreTimeDel         PATH(@"%@/api/storeTimeApi/delStoreTime")
//日历数据
#define URL_StoreTimeCalendarData         PATH(@"%@/api/storeTimeApi/getCalendar")

//常见问题
#define URL_QuestionList         PATH(@"%@/api/memberCenter/questionList")
#define URL_QuestionDetail         PATH(@"%@/api/memberCenter/detailQuestion")
//新手教程列表
#define URL_NewUserTutorialList         PATH(@"%@/api/memberCenter/noviceTutorialList")
//平台规则列表
#define URL_PlatformRules         PATH(@"%@/api/memberCenter/platformRulesList")
//超级权益列表
#define URL_MemberSuperEquity         PATH(@"%@/api/memberCenter/superEquityList")
//新版个人中心页数据
#define URL_NewMemberCenterData         PATH(@"%@/api/memberCenter/memberData")
//查看升级团长指标及达成
#define URL_QueryPartnerAchievement         PATH(@"%@/api/patternApp/queryPartnerAchievement")
//点击升级为团长
#define URL_UpgradePartner         PATH(@"%@/api/patternApp/upgradePartner")


#endif
