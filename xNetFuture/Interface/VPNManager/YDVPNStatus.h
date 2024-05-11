//
//  YDVPNStatus.h
// IMango
//
//  Created by 李白 on 2020/4/21.
//  Copyright © 2020 isec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YDVPNManager.h"

@import NetworkExtension;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VPNStatus) {
    off = 0,
    connecting,
    on,
    disconnecting
};

@interface YDVPNStatus : NSObject
@property(nonatomic, copy)void(^vpnStatus)(VPNStatus);
@property(nonatomic, assign)VPNStatus vpn_status;

+ (instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
