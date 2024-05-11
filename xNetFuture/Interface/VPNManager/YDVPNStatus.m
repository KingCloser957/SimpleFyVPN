//
//  YDVPNStatus.m
// IMango
//
//  Created by 李白 on 2020/4/21.
//  Copyright © 2020 isec. All rights reserved.
//

#import "YDVPNStatus.h"

@implementation YDVPNStatus
- (instancetype)init{
    self = [super init];
    if (self) {
        [YDVPNManager sharedManager];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"VPNStatusChangeNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSNumber *status = note.userInfo[@"vpnStatus"];
            [YDVPNStatus shareInstance].vpn_status = (VPNStatus)[status integerValue];
            if ([YDVPNStatus shareInstance].vpnStatus) {
                [YDVPNStatus shareInstance].vpnStatus((VPNStatus)[status integerValue]);
            }
        }];
    }
    return self;
}

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static YDVPNStatus *instance;
    dispatch_once(&onceToken, ^{
        instance = [[YDVPNStatus alloc] init];
    });
    return instance;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

