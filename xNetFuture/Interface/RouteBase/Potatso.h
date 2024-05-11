//
//  PotatsoManager.h
//  Potatso
//
//  Created by LEI on 4/4/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//
//
//#ifndef DebugModel_h
//#define DebugModel_h
//
//#include <stdio.h>
//int enable_upd_session(void);
//#endif

#import <Foundation/Foundation.h>

@interface Potatso : NSObject
+ (NSString * _Nonnull)sharedGroupIdentifier;

+ (NSString * _Nonnull)encyptKey;
+ (NSURL * _Nonnull)sharedUrl;
//是否支持upd session
+ (int)enableUDPSession;
//是否支持local写日志
+ (BOOL)enableLocalLog;
+ (NSURL * _Nonnull)sharedDatabaseUrl;
+ (NSUserDefaults * _Nonnull)sharedUserDefaults;

+ (NSURL * _Nonnull)sharedGeneralConfUrl;
+ (NSURL * _Nonnull)sharedSocksConfUrl;
+ (NSURL * _Nonnull)sharedProxyConfUrl;
//+ (NSURL * _Nonnull)sharedHttpProxyConfUrl;
+ (NSURL * _Nonnull)sharedLogUrl;
+ (NSString* _Nonnull)sharedAutoLogFile;

//智能代理表
+ (NSString *_Nullable)sharedGFWFile;
//全局代理表
+ (NSString *_Nullable)sharedGlobalFile;

+ (NSString *_Nullable)sharedSSLocalConfigFile;

+ (NSString *_Nullable)sharedAppInfoFile;

//是否国内翻国外
//+ (BOOL)isD2O;
//ss tunnel used
+ (NSString* _Nonnull)sharedAutoTunnelLogFile ;

+ (instancetype _Nullable)shared;
//是否全局模式
@property(nonatomic, assign)BOOL isGlobal;
@property(nonatomic, copy)NSString * _Nullable routeType;
//是否执行流量过滤, 开启之后只让 http/https/dns流量代理
@property(nonatomic, assign)BOOL shouldFilterSpecificDataFlow;




//@property(nonatomic, copy)NSString *sharedGroupIdentifier;
@end



