//
//  YDConnection.m
// IMango
//
//  Created by 李白 on 2020/4/21.
//  Copyright © 2020 isec. All rights reserved.
//


#import "YDConnection.h"
#import "AESCrypt.h"
#import "Potatso.h"
#import "YDConnection_.h"
#import "JSONUtils.h"

@interface YDNode ()

@end

@implementation YDNode

-(void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues{
    [super setValuesForKeysWithDictionary:keyedValues];
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {

    } else {
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%@", key);
}

@end

@interface YDConnection()

@end

@implementation YDConnection

-(void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues{
    [super setValuesForKeysWithDictionary:keyedValues];
    [self setupSSLocalConfig];
    [self setupAppInfo];
}

-(void)setGfwlistPath:(NSString *)gfwlistPath{
    _gfwlistPath = gfwlistPath;
    //拷贝配置文件到app group中
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:_gfwlistPath]) {
        NSError *err;
        if ([manager fileExistsAtPath:[Potatso sharedGFWFile]]) {
            [manager removeItemAtPath:[Potatso sharedGFWFile] error:nil];
        }
        [manager copyItemAtPath:_gfwlistPath toPath:[Potatso sharedGFWFile] error:&err];
        if (err) {
            NSLog(@"copy gfwlist to app group failed: %@",err);
        }
    }
}

- (void)setGlobalPath:(NSString *)globalPath
{
    _globalPath = globalPath;
    //拷贝配置文件到app group中
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:_globalPath]) {
        NSError *err;
        if ([manager fileExistsAtPath:[Potatso sharedGlobalFile]]) {
            [manager removeItemAtPath:[Potatso sharedGlobalFile] error:nil];
        }
        [manager copyItemAtPath:_globalPath toPath:[Potatso sharedGlobalFile] error:&err];
        if (err) {
            NSLog(@"copy gfwlist to app group failed: %@",err);
        }
    }
}

-(void)setupSSLocalConfig {
    NSDictionary *info = [self getSSlocalConf];
    NSString *infoContent = [info jsonString];
    NSString *path = [Potatso sharedSSLocalConfigFile];
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    [infoContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

-(void)setupAppInfo {
    NSDictionary *info = @{@"info": self.appInfo,
                           @"token": self.token,
                           @"proxySessionToken": self.proxySessionToken
    };
    NSString *infoContent = [info jsonString];
    NSString *path = [Potatso sharedAppInfoFile];
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    [infoContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

-(NSDictionary *)getSSlocalConf {
    NSString *token = [NSString stringWithFormat:@"%@|%@|%@", self.userId, self.sessionId, self.proxy_session_token];
    NSString *acl;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (self.isGlobal) {
        if ([manager fileExistsAtPath:[Potatso sharedGlobalFile]]) {
            acl = [Potatso sharedGlobalFile];
        }
    }else{
        if ([manager fileExistsAtPath:[Potatso sharedGFWFile]]) {
            acl = [Potatso sharedGFWFile];
        }
    }
    NSString *localDns = @"8.8.8.8";
    NSDictionary *setting = [self.cdn_setting jsonDictionary];
    if (self.local_dns) {
        localDns = self.local_dns;
    }
    NSString *remoteDns = @"8.8.8.8";
    if (self.remote_dns) {
        remoteDns = self.remote_dns;
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary: @{
        @"token": token,
        @"fake_ip": @(YES),
        @"locals": @[
            @{
                @"mode": @"tcp_and_udp",
                @"acl": acl,
                // Listen address
                @"local_address": @"127.0.0.1",
                @"local_port": @9999
            },
            @{
                @"mode": @"tcp_and_udp",
                @"acl": acl,
                @"protocol": @"dns",
                // Listen address
                @"local_address": @"127.0.0.1",
                @"local_port": @5450,
                // Local DNS address, DNS queries will be sent directly to this address
                @"local_dns_address": localDns,
                // OPTIONAL. Local DNS's port, 53 by default
                @"local_dns_port": @53,
                // Remote DNS address, DNS queries will be sent through ssserver to this address
                @"remote_dns_address": remoteDns,
                // OPTIONAL. Remote DNS's port, 53 by default
                @"remote_dns_port": @53,
            }
        ],
        @"balancer": @{
            // MAX Round-Trip-Time (RTT) of servers
            // The timeout seconds of each individual checks
            @"max_server_rtt": @10,
            // Interval seconds between each check
            @"check_interval": @20,
            // Interval seconds between each check for the best server
            // Optional. Specify to enable shorter checking interval for the best server only.
            @"check_best_interval": @10
         },
        @"runtime": @{
            // single_thread or multi_thread
            @"mode": @"multi_thread",
            // Worker threads that are used in multi-thread runtime
            @"worker_count": @10
        },
        @"over_dns": setting != nil ? setting : @{}
    }];
    NSMutableArray *servers = [NSMutableArray array];
    for (YDNode *node in self.node_list) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if ([node.plugin_status isEqualToString:@"1"]) {
            continue;
//            if (node.plugin_domain) {
//                dict[@"address"] = node.plugin_domain;
//                NSString *tls = @"";
//                if ([node.plugin_protocol isEqualToString:@"https"]) {
//                    tls = @"tls;";
//                }
//                dict[@"plugin_opts"] = [NSString stringWithFormat:@"%@host=%@",tls,node.plugin_domain];
//            } else {
//                dict[@"address"] = node.url;
//            }
//            dict[@"plugin"] = @"v2ray-plugin";
//            dict[@"port"] = @([node.plugin_port intValue]);
        } else {
            dict[@"address"] = node.url;
            dict[@"port"] = @([node.port intValue]);
        }
        dict[@"method"] = node.encrypt_method;
        dict[@"password"] = node.password;
        [servers addObject:dict];
    }
    info[@"servers"] = servers;
    return [info copy];
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"node_list"]) {
        for (NSDictionary *dict in value) {
            YDNode *node = [[YDNode alloc] init];
            [node setValuesForKeysWithDictionary:dict];
            [self.node_list addObject:node];
        }
    } else {
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"forUndefinedKey -- %@", key);
}

-(NSMutableArray *)node_list {
    if (!_node_list) {
        _node_list = [[NSMutableArray alloc] init];
    }
    return _node_list;
}

@end

