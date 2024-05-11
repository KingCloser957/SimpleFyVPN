//
//  JSNetReachableManager.m
//  JadeiteShop
//
//  CreatJS by KingCloser on 2020/11/10.
//  Copyright © 2020 chsai. All rights reservJS.
//


#import "JSNetReachableManager.h"
#import "RealReachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/sysctl.h>
#import <CoreTelephony/CTCellularData.h>
#import <UIKit/UIKit.h>

NSNotificationName JSNetReachabilityStatusChangeNotification = @"JSNetReachabilityStatusChangeNotification";

@interface JSNetReachableManager()

@end

@implementation JSNetReachableManager

+ (JSNetReachableManager *)shareInstance
{
    static JSNetReachableManager *sharJSNRMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharJSNRMgr = [[self alloc] init];
    });
    return sharJSNRMgr;
}

+(void)load
{
    [self shareInstance];
}

- (id)init
{
    if (self = [super init]){
        [self addNotifications];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc");
    [self removeNotifications];
}

- (void)startMonitoring
{
    [GLobalRealReachability startNotifier];
}

- (void)stopMonitoring
{
    [GLobalRealReachability stopNotifier];
}

- (JSNetReachabilityStatus)currentReachabilityStatus
{
    return (JSNetReachabilityStatus)[GLobalRealReachability currentReachabilityStatus];
}

- (JSNetReachabilityStatus)previousReachabilityStatus
{
    return (JSNetReachabilityStatus)[GLobalRealReachability previousReachabilityStatus];
}

- (JSNetReachabilityWWANType)currentWWANtype
{
    return (JSNetReachabilityWWANType)[GLobalRealReachability currentWWANtype];
}

- (JSNetReachabilityCellAuthor)currentReachabilityCellAuthor
{
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    CTCellularDataRestrictedState state = cellularData.restrictedState;
    return (JSNetReachabilityCellAuthor)state;
}

- (NSString *)networkReachabilityStateString
{
    NSString *retString = @"Unknown";
    
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    if (RealStatusNotReachable == status){
        retString = @"NotReachable";
    }else if (RealStatusViaWiFi == status){
        retString = @"wifi";
    }else if (RealStatusViaWWAN == status){
        // 获取手机网络类型
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        
        NSString *currentStatus = info.currentRadioAccessTechnology;
        
        if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
            
            retString = @"GPRS";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyJSge"]) {
            
            retString = @"2.75G JSGE";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
            
            retString = @"3G";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
            
            retString = @"3.5G HSDPA";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
            
            retString = @"3.5G HSUPA";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
            
            retString = @"2G";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
            
            retString = @"3G";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
            
            retString = @"3G";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
            
            retString = @"3G";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
            
            retString = @"HRPD";
        }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
            
            retString = @"4G";
        }
    }
    return retString;
}


#pragma mark - Notification Methods
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerRealReachabilityChangJSNotification:) name:kRealReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerApplicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handlerApplicationDidFinishLaunchingNotification:(NSNotification *)ntf
{
    [self startMonitoring];
}

- (void)handlerRealReachabilityChangJSNotification:(NSNotification *)ntf
{
    RealReachability *reachability = (RealReachability *)ntf.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    ReachabilityStatus previousStatus = [reachability previousReachabilityStatus];
    NSLog(@"networkChangJS, currentStatus:%@, previousStatus:%@", @(status), @(previousStatus));
    
    NSString *message = @"";
    if (status == RealStatusNotReachable){
        message = @"Network unreachable!";
    }
    
    if (status == RealStatusViaWiFi){
        message = @"Network wifi! Free!";
    }
    
    if (status == RealStatusViaWWAN){
        message = @"Network WWAN! In charge!";
    }
    
    WWANAccessType accessType = [GLobalRealReachability currentWWANtype];
    
    if (status == RealStatusViaWWAN)
    {
        if (accessType == WWANType2G){
            message = @"RealReachabilityStatus2G";
        }
        else if (accessType == WWANType3G){
            message = @"RealReachabilityStatus3G";
        }
        else if (accessType == WWANType4G){
            message = @"RealReachabilityStatus4G";
        }
        else{
            message = @"Unknown RealReachability WWAN Status, might be iOS6";
        }
    }
    NSLog(@"message = %@", message);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JSNetReachabilityStatusChangeNotification object:nil];
}

@end

