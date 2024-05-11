//
//  YDVPNManager.h
//  VPNExtension
//
//  Created by 杨雨东 on 2023/1/15.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ENABLE_SYSTEM_CONFIGURATION 1
#import <NetworkExtension/NetworkExtension.h>
#import "YDConnection.h"
#import "YDVPNStatus.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ErrorCode) {
    noError = 0,
    undefined = 1,
    vpnPermissionNotGranted = 2,
    invalidServerCredentials = 3,
    udpRelayNotEnabled = 4,
    serverUnreachable = 5,
    vpnStartFailure = 6,
    illegalServerConfiguration = 7,
    shadowsocksStartFailure = 8,
    configureSystemProxyFailure = 9,
    noAdminPermissions = 10,
    unsupportedRoutingTable = 11,
    systemMisconfigured = 12
};

//FIXME: swift中字符穿需要做对应
typedef NS_ENUM(NSInteger, Action) {
    start = 0,
    restart,
    stop ,
    getConnectionId,
    isReachable
};

typedef NS_ENUM(NSInteger, ManagerError){
    invalidProvider,
    vpnStartFail
};

typedef void(^YDProviderManagerCompletion)(NETunnelProviderManager *_Nullable manager);

@interface YDVPNManager : NSObject

@property (nonatomic)BOOL isVPNActive;

@property (nonatomic, copy)NSString *vpn;

+ (instancetype)sharedManager;

- (void)startWithVpnConfigDir:(NSDictionary * _Nonnull)vpnConfig
              completion:(void(^)(NETunnelProviderManager *manager, ErrorCode error))completion;

- (void)startWithOptions:(YDConnection * _Nonnull)connection
              completion:(void(^)(NETunnelProviderManager *manager, ErrorCode error))completion;

- (void)startWithOptions:(YDConnection * _Nonnull)connection
                 appInfo:(NSString *)info
               userToken:(NSString *)token
              completion:(void(^)(NETunnelProviderManager *manager, ErrorCode error))completion;
//- (void)loadProviderManagerWithCompletion: (void(^)(NETunnelProviderManager *manager))completion;
+ (void)loadProviderManagerWithCompletion: (void(^)(NETunnelProviderManager * _Nullable manager))completion;
- (void)start;
- (void)stop;

- (void)applyConfiguration:(NSString *)mode;

- (NSDictionary *)ping:(NSString *)x;

- (void)stopTunnelWithReason;
+ (void)setLogLevel:(int)l;
+ (void)setGlobalProxyEnable:(BOOL)enable;
+ (void)setSocks5Enable:(BOOL)enable;
+ (NSDictionary *)parseURI:(NSString *)uri;
- (void)startTunnelWithOptions:(NSDictionary *)op configuration:(NSDictionary *)x;

@end

NS_ASSUME_NONNULL_END
