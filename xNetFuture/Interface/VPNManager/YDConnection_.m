//
//  YDConnection_.m
//  ShadowSocks_libev
//
//  Created by 李白 on 2020/4/24.
//  Copyright © 2020 long he. All rights reserved.
//

#import "YDConnection_.h"

@implementation YDConnection_

- (NSDictionary *)config{
    return @{
        @"host": self.host,
        @"port": self.port,
        @"password": self.password,
        @"method": self.method,
        @"auth": self.auth
    };
}
@end
