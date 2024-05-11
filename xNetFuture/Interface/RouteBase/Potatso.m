//
//  PotatsoManager.m
//  Potatso
//
//  Created by LEI on 4/4/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

#import "Potatso.h"
#import "YDPCH.h"

//#if DEBUG
////源代码使用
//static NSString *groupId = @"group.com.imango.sd";//group id
//static NSString *encryptKey = @"86712786e2205b50e80721462334364d";//enctypt key
//static int enableUDPSession = 1;
//static BOOL enableLocalLog = YES;
//#else
//打包时使用
static NSString *groupId = nil;
static NSString *encryptKey = nil;
static int enableUDPSession = 0;
static BOOL enableLocalLog = YES;
//#endif

@implementation Potatso

/// 在初始化方法中的三个参数没有存储在sharedUserDefaults之前不要调用此方法, 动态库和静态库混合使用单例会多次初始化,不能用
+ (instancetype)shared{
    static Potatso *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[Potatso alloc] init];
    });
    return singleton;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isGlobal = [[Potatso sharedUserDefaults] boolForKey:@kGlobalKey];
        self.routeType = [[Potatso sharedUserDefaults] stringForKey: @kRouterType];
        //如果routeType为空默认值
        if (!self.routeType) {
            self.routeType = @"d2o";
        }
        self.shouldFilterSpecificDataFlow = [[Potatso sharedUserDefaults] boolForKey: @kFilterSpecificDataFlow];
    }
    return self;
}

+ (NSString *) sharedGroupIdentifier {
    if (!groupId) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"LocalConfig.json" ofType:nil];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil];
        groupId = dic[@"group_id"];
    }
    return groupId;
//    return dic[@"group_id"];
//    return kSharedGroupIdentifier ;
}

+ (NSString *)encyptKey{
    if (!encryptKey) {
          NSString *path = [[NSBundle mainBundle] pathForResource:@"LocalConfig.json" ofType:nil];
          NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil];
          encryptKey = dic[@"encrypt_key"];
      }
      return encryptKey;
}

+ (int)enableUDPSession {
//#if DEBUG
//    return 1;
//#endif
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LocalConfig.json" ofType:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil];
    enableUDPSession = [dic[@"enableUDPSession"] intValue];
    return enableUDPSession;
}
+ (BOOL)enableLocalLog {
//    #if DEBUG
//        return YES;
//    #endif
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LocalConfig.json" ofType:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil];
    enableLocalLog = [dic[@"enableLocalLog"] boolValue];
    return enableLocalLog;
}
+ (NSURL *)sharedUrl {
    NSLog(@"sharedUrl:%@",[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[self sharedGroupIdentifier]]);
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[self sharedGroupIdentifier]];
}

+ (NSURL *)sharedDatabaseUrl {
    return [[self sharedUrl] URLByAppendingPathComponent:@"potatso.realm"];
}

+ (NSUserDefaults *)sharedUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:[self sharedGroupIdentifier]];
}

+ (NSURL * _Nonnull)sharedGeneralConfUrl {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"general.config"];
}

+ (NSURL *)sharedSocksConfUrl {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"socks.config"];
}

+ (NSURL *)sharedProxyConfUrl {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"proxy.config"];
}

//+ (NSURL *)sharedHttpProxyConfUrl {
//    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"http.config"];
//}

+ (NSURL * _Nonnull)sharedLogUrl {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"tunnel.log"];
}

//智能代理表
+ (NSString *_Nullable)sharedGFWFile {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"gfwlist.acl"].path;
}

//全局代理表
+ (NSString *_Nullable)sharedGlobalFile {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"global.acl"].path;
}

//
+ (NSString *_Nullable)sharedSSLocalConfigFile {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"sslocal.conf"].path;
}

+ (NSString *_Nullable)sharedAppInfoFile {
    return [[Potatso sharedUrl] URLByAppendingPathComponent:@"appInfo"].path;
}

+ (NSString* _Nonnull)sharedAutoLogFile
{
    static NSDateFormatter * dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    NSURL *urlFile = [[Potatso sharedUrl] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.log",[dateFormatter stringFromDate:[NSDate date]]]] ;
    
    return urlFile.path ;
}

+ (NSString* _Nonnull)sharedAutoTunnelLogFile
{
    static NSDateFormatter * dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        dateFormatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
    }
    
    NSURL *urlFile = [[Potatso sharedUrl] URLByAppendingPathComponent:[NSString stringWithFormat:@"log/%@tunnel.log",[dateFormatter stringFromDate:[NSDate date]]]] ;
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtPath:[[Potatso sharedUrl] URLByAppendingPathComponent:@"log/"].path withIntermediateDirectories:true attributes:nil error:&err];
    if (err) {
        NSLog(@"%@",err);
    }
    return urlFile.path ;
}

@end

