//
//  YDConnection_.h
//  ShadowSocks_libev
//
//  Created by 李白 on 2020/4/24.
//  Copyright © 2020 long he. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDConnection_ : NSObject

//一下是节点信息,解密得到
@property(nonatomic, copy)NSString *host;
@property(nonatomic, copy)NSString *port;
@property(nonatomic, copy)NSString *token;
@property(nonatomic, copy)NSString *auth;
@property(nonatomic, copy)NSString *method;
@property(nonatomic, copy)NSString *password;
//节点配置文件
@property(nonatomic, strong)NSDictionary *config;
@end

NS_ASSUME_NONNULL_END
