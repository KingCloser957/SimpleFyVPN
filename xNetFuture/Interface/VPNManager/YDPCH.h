//
//  HLLPCH.h
//  HLLPCH
//
//  Created by isec on 2019/10/16.
//  Copyright © 2019 isec. All rights reserved.
//

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif


#ifndef route_configuration_pch
#define route_configuration_pch

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

#endif /* route_configuration_pch */

//ss是否启动无加密通信方式
#define  kEnableSSNoneEncryFlag                  0


#pragma mark MMWormhole message key 定义
//需要代理的域名和ip列表
#define  kVPNServerIPAddress                   @"vpnServerIPAddress"
#define  kMMWormDirectoryName                  @"IMangoewormholedirectory"
#define  kProxyDomainList              "ProxyDomainList"
#define kDirectDomainList "kDirectDomainList"
#define kDirectIpList "kDirectIpList"
#define  kMMWStartACCModelInfo                 @"MMWVPNServiceModelInfo"
#define  kMMWVPNExitPromptMessage              @"MMWVPNExitPromptMessage"



//中国名单
#define kChinaIPContent                     @"ChinaIPContent"
//白
#define kWhiteIPContent                     @"WhiteIPContent"
//代理
#define kProxyDomainContent                 @"ProxyDomainContent"




//指针的安全转换
#define ConvertToClassPointer(className,instance) \
[(NSObject *)instance isKindOfClass:[className class]] ? (className *)instance : nil


//定义是否开启httpproxy和socks5 server, 为0代表不开启, 不开启的情况下所有的流量都会经过虚拟网卡, 如果做加速器可以开启, 方便筛选浏览器的流量
#define  RH_HTTPPROXY_ENABLED                           0
//add by heron 清除本地dns缓存的时机
#define kDNSCleanTimeInterval                   60 * 60

/* 一下宏定义暂时没有启用
 //debug
 #define kDEBUG          0
 //预发布
 #define kPREPRODUCT      0
 //是否生产环境
 #define kPRODUCT       1
 */

//是否开启选择网络环境的按钮, 生产环境关闭
#if DEBUG
#define kIsChoseNetEnvOpen 1
#else
#define kIsChoseNetEnvOpen 0
#endif
//轮询超时时长
#define kRequestDomainTimeout  4

//全局和智能本地化key
#define kGlobalKey "kGlobalKey"


// MARK: - UI
//闪电和警用ui一样, 所以在此做区分 shandian ...
#define kProductName "police"


//是否支持独占模式
#define kEnableParticular false


//vpn类型 d2o, o2d,d2d,o2o
#define kRouterType "kRouterType"

#define kADSLPushInterval "kADSLPushInterval"

// MARK: - 通知名称
#define kVPNStatusChangeNotification "kVPNStatusChangeNotification"//vpn变化的通知

#define kDeviceToken "kDeviceToken"

//是否开启特殊流量的过滤 开启之后只让 http/https,以及DNS(其他UDP流量不能通过)的流量通过
#define kFilterSpecificDataFlow "kFilterSpecificDataFlow"

//去bundle资源
#define BundlePathfor(name)  [[NSBundle mainBundle] pathForResource:name ofType:nil]

//是否开启n2n
#define kSurpportN2N 0
//n2n socket监听端口
#define kN2NSocketPort 9990
#ifdef DEBUG
//手否开启tcp流量转发日志
#define TCP_DATA_LOG_ENABLE 1
#else
//手否开启tcp流量转发日志
#define TCP_DATA_LOG_ENABLE 0
#endif

//log保存时间7天 60 * 06 * 24 * 7
#define kLogTimeOut 604800.0

//tun2socks的流量是否直接发送到tun中
#define kWriteToTunByT2S 1
//是否使用新版本的local
#define kUSENew 1

#import "YDConnection.h"

// MARK: - LOG
#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);


//为什么下面定义的不能用


#define Warn(fmtt, ...) NSLog((@"******WARNING******[文件名:%s]\n[函数名:%s]\n[行号:%d] \n" fmtt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

#define Error(fmttt, ...) NSLog((@"......ERROR...... [文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmtttt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define NSLog(...);

#define Warn(...);

#define Error(...);
#endif




