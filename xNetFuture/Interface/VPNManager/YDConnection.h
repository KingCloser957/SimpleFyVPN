//
//  YDConnection.h
// IMango
//
//  Created by 李白 on 2020/4/21.
//  Copyright © 2020 isec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDNode: NSObject
@property(nonatomic, copy)NSString *port;
@property(nonatomic, copy)NSString *password;
@property(nonatomic, copy)NSString *url;
@property(nonatomic, copy)NSString *nodeId;
@property(nonatomic, copy)NSString *plugin_status;
@property(nonatomic, copy)NSString *plugin_port;
@property(nonatomic, copy)NSString *plugin_domain;
@property(nonatomic, copy)NSString *encrypt_method;
@property(nonatomic, copy)NSString *region_name;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *node_region_id;
@property(nonatomic, copy)NSString *plugin_protocol;
@end

@interface YDConnection : NSObject

/// vpn名称
@property(nonatomic, copy)NSString *vpnName;

/// vpn服务器地址
@property(nonatomic, copy)NSString *vpnServerAddress;

/// 是否全局代理
@property(nonatomic, assign)bool isGlobal;

@property(nonatomic, assign)NSInteger type;

///指定dns解析服务器.（基本没用，为windows开发所做。默认国内：114.114.114.114，国外：8.8.8.8）
@property(nonatomic, copy)NSString *local_dns;
@property(nonatomic, copy)NSString *remote_dns;

///是否开启local的log功能
@property(nonatomic, assign)BOOL enableLocalLog;

///acl路径
@property(nonatomic, copy)NSString *gfwlistPath;

///全局配置表的存放路径
@property(nonatomic, copy)NSString *globalPath;

///sslocal 配置文件路径
@property(nonatomic, retain)NSDictionary *appInfo;

@property(nonatomic, strong)NSNumber *node_method;
@property(nonatomic, copy)NSString *in_region_code;
@property(nonatomic, copy)NSString *in_region_name;
@property(nonatomic, copy)NSString *out_region_code;
@property(nonatomic, copy)NSString *userId;
@property(nonatomic, copy)NSString *sessionId;
@property(nonatomic, copy)NSString *token;
@property(nonatomic, copy)NSString *proxySessionToken;

@property(nonatomic, assign)BOOL is_enabled;
@property(nonatomic, retain)NSMutableArray<YDNode *> *node_list;
@property(nonatomic, copy)NSString *app_type;
@property(nonatomic, copy)NSString *proxy_session_token;
@property(nonatomic, copy)NSString *cdn_setting;

@end

NS_ASSUME_NONNULL_END
