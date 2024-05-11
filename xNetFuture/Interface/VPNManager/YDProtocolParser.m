//
//  xVPNProtocolParser.m
//  xVPN
//
//  Created by LinkV on 2022/11/1.
//

#import "YDProtocolParser.h"

static uint16_t __http_proxy_port__ = 10800;
static uint16_t __http_socks_port__ = 10807;
static NSString *__log_level__ = @"info";
static bool __global_geosite_enable__ = false;
static bool __global_geoip_enable__ = false;
static NSMutableArray *__directDomainList__ = nil;
static NSMutableArray *__proxyDomainList__ = nil;
static NSMutableArray *__blockDomainList__ = nil;

@implementation YDProtocolParser

+(void)setHttpProxyPort:(uint16_t)port {
    __http_proxy_port__ = port;
}

+(uint16_t)HttpProxyPort {
    return __http_proxy_port__;
}

+(void)setLogLevel:(NSString *)level {
    __log_level__ = level;
}

+ (void)setGlobalProxyEnable:(BOOL)enable {
    __global_geosite_enable__ = !enable;
    __global_geoip_enable__ = !enable;
}

+ (void)setDirectDomainList:(NSArray *)list {
    __directDomainList__ = list.mutableCopy;
}

+ (void)setProxyDomainList:(NSArray *)list {
    __proxyDomainList__ = list.mutableCopy;
}

+ (void)setBlockDomainList:(NSArray *)list {
    __blockDomainList__ = list.mutableCopy;
}

+(nullable NSDictionary *)parse:(NSString *)uri protocol:(xVPNProtocol)protocol {
    
    switch (protocol) {
        case xVPNProtocolVmess:
            return [self parseVmess:uri];
            
        case xVPNProtocolVless:
            return [self parseVless:uri];
            
        case xVPNProtocolSs:
            return [self parseSS:uri];
            
        case xVPNProtocolSsr:
            return [self parseSSR:uri];
        default:
            break;
    }
    return nil;
}

+(nullable NSDictionary *)parseVless:(NSString *)uri {
    NSArray <NSString *> *info = [uri componentsSeparatedByString:@"@"];
    if (info.count < 2) {
        return nil;
    }
    
    NSString *uuid = info[0];
    NSArray <NSString *>*config = [info[1] componentsSeparatedByString:@"?"];
    if (config.count < 2) {
        return nil;
    }
    
    NSArray <NSString *>*ipAddress = [config[0] componentsSeparatedByString:@":"];
    if (ipAddress.count < 2) {
        return nil;
    }
    NSString *address = ipAddress[0];
    NSNumber *port = @([ipAddress[1] integerValue]);
    
    NSArray <NSString *> *suffix = [config[1] componentsSeparatedByString:@"#"];
    
    if (suffix.count < 2) {
        return nil;
    }
    
    NSString *remark = suffix[1];
    
    NSString *tag = suffix[0];
    tag = @"proxy";
    
    NSArray <NSString *> *parameters = [suffix[0] componentsSeparatedByString:@"&"];
    
    NSString *network;
    NSString *security = @"none";
    NSString *flow = @"";
    
    NSString *kcpKey;
    
    NSString *quicSecurity;
    NSString *quicKey;
    NSString *quicHeaderType;
    
    NSString *wspath;
    NSString *wshost;
    
    NSString *sni;
    NSString *fp;
    NSString *pbk;
    NSString *sid;
    
    for (NSString *p in parameters) {
        NSArray <NSString *> *items = [p componentsSeparatedByString:@"="];
        if (items.count < 2) continue;
        
        if ([items[0] isEqualToString:@"type"]) {
            network = items[1];
        }
        else if ([items[0] isEqualToString:@"security"]) {
            security = items[1];
        }
        else if ([items[0] isEqualToString:@"flow"]) {
            flow = items[1];
        }
        else if ([items[0] isEqualToString:@"key"]) {
            quicKey = items[1];
        }
        else if ([items[0] isEqualToString:@"quicSecurity"]) {
            quicSecurity = items[1];
        }
        else if ([items[0] isEqualToString:@"headerType"]) {
            quicHeaderType = items[1];
        }
        else if ([items[0] isEqualToString:@"seed"]) {
            kcpKey = items[1];
        }
        else if ([items[0] isEqualToString:@"sni"]) {
            sni = items[1];
        }
        else if ([items[0] isEqualToString:@"fp"]) {
            fp = items[1];
        }
        else if ([items[0] isEqualToString:@"pbk"]) {
            pbk = items[1];
        }
        else if ([items[0] isEqualToString:@"sid"]) {
            sid = items[1];
        }
        else if ([items[0] isEqualToString:@"path"]) {
            wspath  = items[1];
        }
        else if ([items[0] isEqualToString:@"host"]) {
            wshost = items[1];
        }
    }
    if (!address || !port || !uuid || !tag || !network || !security) return nil;
    NSMutableDictionary *configuration = [NSMutableDictionary new];
    configuration[@"log"] = @{@"loglevel":__log_level__};
    NSMutableArray *rules = @[].mutableCopy;
    
    if (__proxyDomainList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": __proxyDomainList__,
            @"outboundTag": tag
        };
        [rules addObject:A];
    }
    
    if (__blockDomainList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": __blockDomainList__,
            @"outboundTag": @"block"
        };
        [rules addObject:A];
    }
    
    if (__global_geosite_enable__) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": @[@"geosite:category-ads-all"],
            @"outboundTag": @"block"
        };
        NSDictionary *B = @{
            @"type": @"field",
            @"domain": @[@"geosite:cn"],
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
        [rules addObject:B];
    }
    
    if (__global_geoip_enable__) {
        NSDictionary *A = @{
            @"type": @"field",
            @"ip": @[@"geoip:private", @"geoip:cn"],
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
    }
    
    if (__global_geoip_enable__ || __global_geosite_enable__) {
        NSDictionary *C = @{
            @"type": @"field",
            @"domain": @[@"geosite:geolocation-!cn"],
            @"outboundTag": tag
        };
        [rules addObject:C];
    }
    
    if (!__global_geoip_enable__ && !__global_geosite_enable__) {
        NSDictionary *all = @{
            @"type":@"field",
            @"outboundTag":tag,
            @"port":@"0-65535"
        };
        [rules addObject:all];
    }
    
    configuration[@"routing"] = @{
        @"domainStrategy" : @"AsIs",
        @"rules" : rules
    };
    
    configuration[@"stats"] = @{};
    configuration[@"policy"] = @{
        @"levels": @{
            @"0": @{
                @"statsUserUplink": [NSNumber numberWithBool:true],
                @"statsUserDownlink": [NSNumber numberWithBool:true]
            }
        },
        @"system": @{
            @"statsInboundUplink": [NSNumber numberWithBool:true],
            @"statsInboundDownlink": [NSNumber numberWithBool:true],
            @"statsOutboundUplink": [NSNumber numberWithBool:true],
            @"statsOutboundDownlink": [NSNumber numberWithBool:true]
        }
    };
    
    NSMutableArray *inbounds = [NSMutableArray new];
    configuration[@"inbounds"] = inbounds;
    
    NSDictionary *defaultInbound = @{
        @"listen" : @"127.0.0.1",
        @"protocol" : @"http",
        @"settings" : @{
            @"auth": @"noauth",
            @"timeout" : @60
        },
        @"tag" : @"httpinbound",
        @"port" : @(__http_proxy_port__)
    };
    
    NSDictionary *socksInbound = @{
        @"sniffing": @{
            @"enabled": @true,
            @"destOverride": @[
                @"tls",
                @"http"
            ]
        },
        @"listen" : @"127.0.0.1",
        @"protocol" : @"socks",
        @"settings" : @{
            @"udp": @false,
            @"auth": @"noauth",
            @"timeout" : @60
        },
        @"tag" : @"socksinbound",
        @"port" : @(__http_socks_port__)
    };
    
    if ([network isEqualToString:@"tcp"] && [security isEqualToString:@"xtls"]) {
        [inbounds addObject:@{
            @"listen": @"127.0.0.1",
            @"port": @(443),
            @"protocol": @"vless",
            @"settings": @{
                @"udp": @(true)
            },
            @"sniffing": @{
                @"enabled": @(true),
                @"destOverride": @[
                    @"http",
                    @"tls",
                    @"quic"
                ],
                @"routeOnly": @(true)
            }
        }
        ];
    } else {
        [inbounds addObject:defaultInbound];
    }
    
//    [inbounds addObject:socksInbound];
    
    NSMutableArray *outbounds = [NSMutableArray new];
    configuration[@"outbounds"] = outbounds;
    NSMutableDictionary *outbound = @{
        @"protocol":@"vless",
        @"tag":tag,
        @"settings": @{
            @"vnext" : @[
                @{
                    @"address":address,
                    @"port":port,
                    @"users" :@[
                        @{
                            @"encryption":@"none",
                            @"id":uuid,
                            @"flow": flow
                        }
                    ]
                }
            ]
        },
        @"streamSettings":@{
            @"security" : security,
            @"network" : network
        }
    }.mutableCopy;
    
    if ([network isEqualToString:@"ws"]) {
        if (wspath && wshost) {
            outbound[@"streamSettings"] = @{
                @"security" : security,
                @"network" : network,
                @"wsSettings" : @{
                    @"path":wspath,
                    @"headers": @{
                        @"Host":sni,
                        @"User-Agent": @"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36"
                    }
                },
                @"tlsSettings" : @{
                    @"allowInsecure": [NSNumber numberWithBool:true],
                    @"serverName": sni,
                    @"fingerprint": @"chrome"
                },
            };
        }
    }
    else if ([network isEqualToString:@"quic"]) {
            if (quicKey && quicSecurity && quicHeaderType) {
                outbound[@"streamSettings"] = @{
                    @"security" : security,
                    @"network" : network,
                    @"quicSettings" : @{
                        @"header":@{
                            @"type":quicHeaderType
                        },
                        @"key":quicKey,
                        @"security":quicSecurity
                }
            };
        }
    }
    else if ([network isEqualToString:@"tcp"]) {
        if ([security isEqualToString:@"xtls"]) {
            outbound[@"streamSettings"] = @{
                @"security" : security,
                @"network" : network,
                @"xtlsSettings" : @{
                    @"serverName":address
                }
            };
        } else if ([security isEqualToString:@"reality"]) {
            outbound[@"streamSettings"] = @{
                @"tcpSettings": @{
                    @"header": @{
                        @"type": quicHeaderType
                    }
                },
                @"network": network,
                @"security": security,
                @"realitySettings": @{
                    @"spiderX": @"",
                    @"fingerprint": @"chrome", // 必填，使用 uTLS 库模拟客户端 TLS 指纹
                    @"serverName": sni, // 服务端 serverNames 之一
                    @"publicKey": pbk, // 服务端私钥对应的公钥
                    @"shortId": sid, // 服务端 shortIds 之一
                }
            };
        }
    }
    else if ([network isEqualToString:@"kcp"]) {
        if (kcpKey) {
            outbound[@"streamSettings"] = @{
                @"security" : security,
                @"network" : network,
                @"kcpSettings": @{
                    @"congestion": [NSNumber numberWithBool:false],
                    @"downlinkCapacity": @100,
                    @"header": @{
                        @"type": @"none"
                    },
                    @"mtu": @1350,
                    @"readBufferSize": @1,
                    @"seed": kcpKey,
                    @"tti": @50,
                    @"uplinkCapacity": @12,
                    @"writeBufferSize": @1
                },
            };
        }
    }
    else if ([network isEqualToString:@"grpc"]) {
        outbound[@"streamSettings"] = @{
            @"network": network,
            @"security": security,
            @"realitySettings": @{
                @"show": @true, // 选填，若为 true，输出调试信息
                @"fingerprint": @"chrome", // 必填，使用 uTLS 库模拟客户端 TLS 指纹
                @"serverName": sni, // 服务端 serverNames 之一
                @"publicKey": pbk, // 服务端私钥对应的公钥
                @"shortId": sid, // 服务端 shortIds 之一
            }
        };
    }
    [outbounds addObject:outbound];
    NSDictionary *direct = @{
        @"tag": @"direct",
        @"protocol": @"freedom",
        @"settings": @{
            
        }
    };
    
    NSDictionary *block = @{
        @"tag": @"block",
        @"protocol": @"blackhole",
        @"settings": @{
            @"response": @{
                @"type": @"http"
            }
        }
    };
    [outbounds addObject:direct];
    [outbounds addObject:block];
    
    NSMutableDictionary *dns = @{}.mutableCopy;
    dns[@"servers"] = @[@"8.8.8.8"];
    configuration[@"dns"] = dns;
    configuration[@"remark"] = remark;
    
    NSLog(@"x-Ray配置:%@",configuration);
    
    return configuration;
}

+(nullable NSDictionary *)parseVmess:(NSString *)uri {
    
    NSData *payload = [[NSData alloc] initWithBase64EncodedString:uri options:0];
    NSError *error;
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:payload options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    NSString *address = info[@"add"];
    NSNumber *port = info[@"port"];
    if (port && ![port isKindOfClass:NSNumber.class]) {
        port = @(port.integerValue);
    }
    NSNumber *aid = info[@"aid"] ? info[@"aid"] : @0;
    if (![aid isKindOfClass:NSNumber.class]) {
        aid = @(aid.integerValue);
    }
    NSString *uuid = info[@"id"];
    NSString *tag = info[@"ps"];
    NSString *tls = info[@"tls"] ? info[@"tls"] : @"none";
    
    NSString *wspath = info[@"path"];
    NSString *wshost = info[@"host"];
    NSString *remark = info[@"remark"] ? info[@"remark"] : info[@"ps"];
    tag = @"proxy";
    NSString *network = info[@"net"];
    
    NSString *kcpKey = info[@"path"];
    
    NSString *quicSecurity = info[@"host"];
    NSString *quicKey = info[@"path"];
    NSString *quicHeaderType = info[@"type"];
    
    if (!address || !port || !uuid || !tag || !network) return nil;
    NSMutableDictionary *configuration = [NSMutableDictionary new];
    configuration[@"log"] = @{@"loglevel":__log_level__};
    
    NSMutableArray *rules = @[
    ].mutableCopy;
    
    if (__proxyDomainList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": __proxyDomainList__,
            @"outboundTag": tag
        };
        [rules addObject:A];
    }
    
    if (__blockDomainList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": __blockDomainList__,
            @"outboundTag": @"block"
        };
        [rules addObject:A];
    }
    
    if (__global_geosite_enable__) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": @[@"geosite:category-ads-all"],
            @"outboundTag": @"block"
        };
        NSDictionary *B = @{
            @"type": @"field",
            @"domain": @[@"geosite:cn"],
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
        [rules addObject:B];
    }
    
    if (__global_geoip_enable__) {
        NSDictionary *A = @{
            @"type": @"field",
            @"ip": @[@"geoip:private", @"geoip:cn"],
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
    }
    
    if (__global_geoip_enable__ || __global_geosite_enable__) {
        NSDictionary *C = @{
            @"type": @"field",
            @"domain": @[@"geosite:geolocation-!cn"],
            @"outboundTag": tag
        };
        [rules addObject:C];
    }
    
    if (!__global_geoip_enable__ && !__global_geosite_enable__) {
        NSDictionary *all = @{
            @"type":@"field",
            @"outboundTag":tag,
            @"port":@"0-65535"
        };
        [rules addObject:all];
    }
    
    configuration[@"routing"] = @{
        @"domainStrategy" : @"AsIs",
        @"rules" : rules
    };
    
    
    NSMutableArray *inbounds = [NSMutableArray new];
    configuration[@"inbounds"] = inbounds;
    
    NSDictionary *defaultInbound = @{
        @"listen" : @"127.0.0.1",
        @"protocol" : @"http",
        @"settings" : @{
            @"timeout" : @60
        },
        @"tag" : @"httpinbound",
        @"port" : @(__http_proxy_port__)
    };
    [inbounds addObject:defaultInbound];
    
    NSMutableArray *outbounds = [NSMutableArray new];
    configuration[@"outbounds"] = outbounds;
    NSMutableDictionary *outbound = @{
        @"mux": @{
            @"concurrency": @8,
            @"enabled": [NSNumber numberWithBool:false]
        },
        @"protocol":@"vmess",
        @"tag":tag,
        @"settings": @{
            @"vnext" : @[
                @{
                    @"address":address,
                    @"port":port,
                    @"users" :@[
                        @{
                            @"encryption":@"",
                            @"security":@"auto",
                            @"alterId":aid,
                            @"id":uuid,
                            @"flow":@"",
                            @"level":@8
                        }
                    ]
                }
            ]
        },
        @"streamSettings" : @{
            @"security" : tls,
            @"network" : network,
            @"tcpSettings": @{
                @"header": @{
                    @"type": @"none"
                }
            }
        }
    }.mutableCopy;
    
    if ([network isEqualToString:@"ws"]) {
        if (wspath && wshost) {
            outbound[@"streamSettings"] = @{
                @"security" : tls,
                @"network" : network,
                @"wsSettings" : @{
                    @"headers":@{
                        @"host":wshost
                    },
                    @"path":wspath
                },
                @"tlsSettings": @{
                    @"serverName": wshost,
                    @"allowInsecure": @YES
                },
            };
        }
    }
    else if ([network isEqualToString:@"quic"]) {
        if (quicKey && quicSecurity && quicHeaderType) {
            outbound[@"streamSettings"] = @{
                @"security" : tls,
                @"network" : network,
                @"quicSettings" : @{
                    @"header":@{
                        @"type":quicHeaderType
                    },
                    @"key":quicKey,
                    @"security":quicSecurity
                }
            };
        }
    } else if([network isEqualToString:@"kcp"]) {
        if (kcpKey) {
            outbound[@"streamSettings"] = @{
                @"security" : tls,
                @"network" : network,
                @"kcpSettings": @{
                    @"congestion": [NSNumber numberWithBool:false],
                    @"downlinkCapacity": @100,
                    @"header": @{
                        @"type": @"none"
                    },
                    @"mtu": @1350,
                    @"readBufferSize": @1,
                    @"seed": kcpKey,
                    @"tti": @50,
                    @"uplinkCapacity": @12,
                    @"writeBufferSize": @1
                },
            };
        }
    }
    [outbounds addObject:outbound];
    NSDictionary *direct = @{
        @"tag": @"direct",
        @"protocol": @"freedom",
        @"settings": @{}
    };
    NSDictionary *block = @{
        @"tag": @"block",
        @"protocol": @"blackhole",
        @"settings": @{
            @"response": @{
                @"type": @"http"
            }
        }
    };
    [outbounds addObject:direct];
    [outbounds addObject:block];
    if (remark) {
        configuration[@"remark"] = remark;
    }
    configuration[@"dns"] = @{
        @"hosts": @{
            @"domain:googleapis.cn": @"googleapis.com"
        },
        @"servers": @[
            @"1.1.1.1"
        ]
    };
    
    return configuration;
}

+ (nullable NSDictionary *)parseSS:(NSString *)base64EncodeStr {
    NSString *decodeStr = [YDProtocolParser base64Decode:base64EncodeStr];
    NSArray *parts = [decodeStr componentsSeparatedByString:@":"];
    
    if (parts.count != 3) {
        NSLog(@"不能解析SS链接: %@", base64EncodeStr);
        return nil;
    }
    
    NSString *method = parts[0];
    NSString *passwordAndIP = parts[1];
    NSString *port = parts[2];
    
    NSArray *passAndServer = [passwordAndIP componentsSeparatedByString:@"@"];
    NSString *password = passAndServer[0];
    NSString *server = passAndServer[1];
    
    NSLog(@"加密方法: %@, 密码: %@, server: %@, port: %@", method, password, server, port);
    
    NSMutableDictionary *config = [NSMutableDictionary new];
    
    if (server) {
        [config setObject:server forKey:@"server"];
    }
    
    if (port) {
        [config setObject:port forKey:@"port"];
    }
    
    if (password) {
        [config setObject:password forKey:@"password"];
    }
    
    if (method) {
        [config setObject:server forKey:@"method"];
    }
    return config;
}

+ (nullable NSDictionary *)parseSSR:(NSString *)base64EncodeStr {
    NSString *decodeStr = [self base64Decode:base64EncodeStr];
    NSArray *parts = [decodeStr componentsSeparatedByString:@":"];
    
    if (parts.count != 6) {
        NSLog(@"不能解析SSR链接: %@", base64EncodeStr);
        return nil;
    }
    
    NSString *server = parts[0];
    NSString *port = parts[1];
    NSString *protocol = parts[2];
    NSString *method = parts[3];
    NSString *obfs = parts[4];
    NSString *passwordAndParams = parts[5];
    
    NSArray *passwordAndParamsComponents = [passwordAndParams componentsSeparatedByString:@"/?"];
    NSString *passwordEncodeStr = passwordAndParamsComponents[0];
    NSString *password = [self base64Decode:passwordEncodeStr];
    
    
    NSMutableDictionary *config = [NSMutableDictionary new];
    
    if (server) {
        [config setObject:server forKey:@"server"];
    }
    
    if (port) {
        [config setObject:port forKey:@"port"];
    }
    
    if (password) {
        [config setObject:password forKey:@"password"];
    }
    
    if (method) {
        [config setObject:method forKey:@"method"];
    }
    
    if (protocol) {
        [config setObject:protocol forKey:@"protocol"];
    }
    
    if (obfs) {
        [config setObject:obfs forKey:@"obfs"];
    }
    
    NSLog(@"server: %@, port: %@, 协议: %@, 加密方法: %@, 密码: %@, 混淆: %@",
          server, port, protocol, method, password, obfs);
    
    return config;
}

+ (NSString *)fillPadding:(NSString *)base64EncodeStr {
    BOOL needPadding = base64EncodeStr.length % 4 != 0;
    
    if (needPadding) {
        NSUInteger missingPadding = 4 - (base64EncodeStr.length % 4);
        base64EncodeStr = [base64EncodeStr stringByAppendingString:[@"=" stringByPaddingToLength:missingPadding withString:@"=" startingAtIndex:0]];
    }
    
    return base64EncodeStr;
}

+ (NSString *)base64Decode:(NSString *)base64EncodeStr {
    base64EncodeStr = [self fillPadding:base64EncodeStr];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64EncodeStr options:0];
    NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return decodedString;
}

+ (NSDictionary *)parseURI:(NSString *)uri {
    NSArray <NSString *>*list = [uri componentsSeparatedByString:@"//"];
    xVPNProtocol protocol;
    if (list.count != 2) {
        return nil;
    }
    if ([list[0] hasPrefix:@"vmess"]) {
        protocol = xVPNProtocolVmess;
    }
    else if ([list[0] hasPrefix:@"vless"]) {
        protocol = xVPNProtocolVless;
    }
    else if ([list[0] hasPrefix:@"ss"]) {
        protocol = xVPNProtocolSs;
    }
    else if ([list[0] hasPrefix:@"ssr"]) {
        protocol = xVPNProtocolSsr;
    }
    else {
        return nil;
    }
    NSDictionary *configuration = [YDProtocolParser parse:list[1] protocol:protocol];
    return configuration;
}


@end

