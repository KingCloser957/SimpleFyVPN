//
//  YDVPNManager.m
//  VPNExtension
//
//  Created by 杨雨东 on 2023/1/15.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "YDVPNManager.h"
#import "YDFutureManager.h"

#if ENABLE_SYSTEM_CONFIGURATION
#import <SystemConfiguration/SystemConfiguration.h>
#endif

NSString *const kApplicationVPNServerAddress = @"dpjdbsym35488455.xyz";
NSString *const kApplicationVPNLocalizedDescription = @"Yo Wish VPN Packet Tunnel";

@interface YDVPNManager ()

@property(nonatomic, assign)VPNStatus vpnStatus;
@property(nonatomic, assign)BOOL observerAdded;
@property(nonatomic, strong)YDConnection *connection;
@property(nonatomic, strong)NSDictionary *vpnConfig;

@end

@implementation YDVPNManager

+ (instancetype)sharedManager{
    static YDVPNManager *__manager__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager__ = [[self alloc] init];
    });
    return __manager__;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addVPNStatusObserver];
    }
    return self;
}

- (NSDictionary *)vpnConfig
{
    if (!_vpnConfig) {
        _vpnConfig = [NSDictionary new];
    }
    return  _vpnConfig;
}

- (void)setVpnStatus:(VPNStatus)vpnStatus{
    if (vpnStatus == _vpnStatus || !_observerAdded) {
        _observerAdded = YES;
        return;
    }
    _vpnStatus = vpnStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VPNStatusChangeNotification"
                                                        object:nil
                                                      userInfo:@{@"vpnStatus": @(vpnStatus)}];
}

- (void)loadProviderManagerWithCompletion: (void(^)(NETunnelProviderManager *manager))completion {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (managers.count > 0) {
            completion(managers[0]);
            return ;
        }
        completion(nil);
    }];
}

+ (void)loadProviderManagerWithCompletion: (void(^)(NETunnelProviderManager  * _Nullable manager))completion {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (managers.count > 0) {
            completion(managers[0]);
            return ;
        }
        completion(nil);
    }];
}

- (NETunnelProviderManager *)createProviderManager {
    NETunnelProviderManager *manager = [[NETunnelProviderManager alloc] init];
    manager.protocolConfiguration = [[NETunnelProviderProtocol alloc] init];
    return manager;
}

- (void)loadAndCreateProviderManagerWithCompletion: (void(^)(NETunnelProviderManager *manager, NSError *error)) completion {
    __weak typeof(self) weakSelf = self;
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (error) {
             completion(nil, error);
            return;
        }
        NETunnelProviderManager *manager;
        if (managers.count > 0) {
            manager = managers[0];
        }else{
            manager = [self createProviderManager];
        }
        [manager setEnabled:true];
        manager.localizedDescription = kApplicationVPNLocalizedDescription;
        manager.protocolConfiguration.serverAddress = kApplicationVPNServerAddress;
        NEOnDemandRuleEvaluateConnection *quickStartRule = [[NEOnDemandRuleEvaluateConnection alloc] init];
        NEEvaluateConnectionRule *rule = [[NEEvaluateConnectionRule alloc] initWithMatchDomains:@[@""] andAction:NEEvaluateConnectionRuleActionNeverConnect];
        quickStartRule.connectionRules = @[rule];

        [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                completion(nil,error);
                return ;
            }
            [manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    completion(nil,error);
                    return ;
                }
                completion(manager, nil);
            }];
        }];
    }];
}

- (NETunnelProviderManager *)handlePreferences:(NSArray<NETunnelProviderManager *> * _Nullable)managers {
    NETunnelProviderManager *manager;
    for (NETunnelProviderManager *item in managers) {
        if ([item.localizedDescription isEqualToString:kApplicationVPNLocalizedDescription]) {
            manager = item;
            break;
        }
    }
    return  manager;
    NSLog(@"Found a vpn configuration");
}

- (void)postMessageWithCompletion: (void(^)(BOOL succeed))completion {
    [self loadProviderManagerWithCompletion:^(NETunnelProviderManager *manager) {
        NSDictionary *action = @{@"action":@"vpnStatus"};
        NETunnelProviderSession *session = (NETunnelProviderSession *)manager.connection;
        NSData *data = [NSJSONSerialization dataWithJSONObject:action options:NSJSONWritingPrettyPrinted error:nil];
        if (session!= nil && (data != nil) && (manager.connection.status != NEVPNStatusInvalid)) {
            NSError *error;
            [session sendProviderMessage:data returnError:&error responseHandler:^(NSData * _Nullable responseData) {
                if (responseData != nil) {
                    NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                    BOOL status = resDic[@"vpnStatus"];
                    completion(status);
                }
            }];
            if (error) {
                completion(NO);
            }
        }else{
            completion(NO);
        }
        
    }];
}

- (void)startWithVpnConfigDir:(NSDictionary * _Nonnull)vpnConfig
                   completion:(void(^)(NETunnelProviderManager *manager, ErrorCode error))completion {
    self.vpnConfig = vpnConfig;
    [self loadAndCreateProviderManagerWithCompletion:^(NETunnelProviderManager *manager, NSError *error) {
        if (error || (!manager)) {
            completion(nil,error.code);
            return;
        }
        NSError *newError;
        BOOL result = [manager.connection startVPNTunnelWithOptions:vpnConfig andReturnError:&newError];
        if (!error) {
            completion(manager, 0);
        } else{
            completion(nil, newError.code);
        }
    }];
}

- (void)startWithOptions:(YDConnection * _Nonnull)connection
              completion:(void(^)(NETunnelProviderManager *manager, ErrorCode error))completion {
    self.connection = connection;
    [self loadAndCreateProviderManagerWithCompletion:^(NETunnelProviderManager *manager, NSError *error) {
        if (error || (!manager)) {
            completion(nil,error.code);
            return;
        }
//        if (manager.connection.status == NEVPNStatusDisconnected || manager.connection.status == NEVPNStatusInvalid) {
            NSError *newError;
            BOOL result = [manager.connection startVPNTunnelWithOptions:@{} andReturnError:&newError];
            if (!error) {
                completion(manager, 0);
            }else{
                completion(nil, newError.code);
            }
//        } else {
//            completion(manager, nil);
//        }
    }];
}

- (void)stop {
    [self loadProviderManagerWithCompletion:^(NETunnelProviderManager *manager) {
        if (!manager) {
            return ;
        }
        [manager.connection stopVPNTunnel];
    }];
}

- (void)startWithOptions:(YDConnection * _Nonnull)connection
                 appInfo:(NSString * _Nonnull)info
               userToken:(NSString * _Nonnull)token
              completion:(void(^)(NETunnelProviderManager *manager, ErrorCode error))completion {
    [self startWithOptions:connection completion:completion];
}

- (void)addVPNStatusObserver {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:NEVPNStatusDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        NEVPNConnection *objc = note.object;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateVPNStatus:objc.status];
    }];
}

- (NETunnelProviderManager *)createVPNManager {
    NETunnelProviderManager *manager = [NETunnelProviderManager new];
    NETunnelProviderProtocol *protocolConfiguration = [NETunnelProviderProtocol new];
    manager.protocolConfiguration = protocolConfiguration;
    return manager;
}

- (void)updateVPNStatus: (NEVPNStatus)status {
    switch (status) {
        case NEVPNStatusConnected:
            self.vpnStatus = 2;
            break;
        case NEVPNStatusConnecting:
            self.vpnStatus = 1;
            break;
        case NEVPNStatusDisconnecting:
            self.vpnStatus = 3;
            break;
        case NEVPNStatusInvalid:
        case NEVPNStatusDisconnected:
            self.vpnStatus = 0;
            break;
        default:
            break;

    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#if TARGET_OS_OSX
-(void)applyConfiguration:(NSString *)mode {
#if ENABLE_SYSTEM_CONFIGURATION
    AuthorizationRef authRef;
    AuthorizationFlags authFlags = kAuthorizationFlagDefaults
    | kAuthorizationFlagExtendRights
    | kAuthorizationFlagInteractionAllowed
    | kAuthorizationFlagPreAuthorize;
    OSStatus ret = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment, authFlags, &authRef);
    if (ret != noErr) {
        NSLog(@"No authorization has been granted to modify network configuration");
        return;
    }
    SCPreferencesRef prefRef = SCPreferencesCreateWithAuthorization(nil, CFSTR("Yo Wish VPN"), nil, authRef);
    NSDictionary *sets = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);
    for (NSString *key in [sets allKeys]) {
        NSMutableDictionary *dict = [sets objectForKey:key];
        NSString *hardware = [dict valueForKeyPath:@"Interface.UserDefinedName"];
        if ([hardware isEqualToString:@"Wi-Fi"] || [hardware isEqualToString:@"Ethernet"]) {
            NSMutableDictionary *proxies = [sets[key][@"Proxies"] mutableCopy];
            [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPEnable];
            [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPSEnable];
            [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesSOCKSEnable];
            if ([mode isEqualToString:@"global"]) {
                int socksPort = 1081;
                int httpPort = 1082;
                NSLog(@"in helper %d %d", socksPort, httpPort);
                if (socksPort > 0) {
                    [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesSOCKSProxy];
                    [proxies setObject:[NSNumber numberWithInt:socksPort] forKey:(NSString*)kCFNetworkProxiesSOCKSPort];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString*)kCFNetworkProxiesSOCKSEnable];
                }
                if (httpPort > 0) {
                    [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesHTTPProxy];
                    [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesHTTPSProxy];
                    [proxies setObject:[NSNumber numberWithInt:httpPort] forKey:(NSString*)kCFNetworkProxiesHTTPPort];
                    [proxies setObject:[NSNumber numberWithInt:httpPort] forKey:(NSString*)kCFNetworkProxiesHTTPSPort];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString*)kCFNetworkProxiesHTTPEnable];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString*)kCFNetworkProxiesHTTPSEnable];
                }
            }
            Boolean isOK = SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)[NSString stringWithFormat:@"/%@/%@/%@", kSCPrefNetworkServices, key, kSCEntNetProxies], (__bridge CFDictionaryRef)proxies);
            NSLog(@"System proxy apply:%d", isOK);
        }
    }
    SCPreferencesCommitChanges(prefRef);
    SCPreferencesApplyChanges(prefRef);
    SCPreferencesSynchronize(prefRef);
    AuthorizationFree(authRef, kAuthorizationFlagDefaults);
    self.isVPNActive = [mode isEqualToString:@"global"];
#endif
}
#endif

-(NSDictionary *)ping:(NSString *)ip {
    NSString *pings = [YDFutureManager ping:[NSString stringWithFormat:@"[\"%@\"]", ip]];
    NSDictionary *r = @{@"action":@"response", @"type":@"ping", @"pings":pings};
    return r;
}

-(void)stopTunnelWithReason{
    [[YDFutureManager sharedManager] stopTunnelWithReason];
}

+(void)setLogLevel:(int)l {
    [YDFutureManager setLogLevel:l];
}

+(void)setGlobalProxyEnable:(BOOL)enable {
    [YDFutureManager setGlobalProxyEnable:enable];
}

+(void)setSocks5Enable:(BOOL)enable {
    [YDFutureManager setSocks5Enable:enable];
}

+(NSDictionary *)parseURI:(NSString *)uri {
    return [YDFutureManager parseURI:uri];
}

-(void)startTunnelWithOptions:(NSDictionary *)op configuration:(NSDictionary *)x {
    [[YDFutureManager sharedManager] startTunnelWithOptions:op configuration:x];
}

- (void)applyConfiguration:(nonnull NSString *)mode {
}

- (void)start {
}

@end
