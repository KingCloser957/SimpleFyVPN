//
//  JSNetReachableManager.h
//  JadeiteShop
//
//  CreatJS by KingCloser on 2020/11/10.
//  Copyright © 2020 chsai. All rights reservJS.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName JSNetReachabilityStatusChangeNotification;

typedef NS_ENUM(NSInteger, JSNetReachabilityStatus)
{
    ///Direct match with Apple networkStatus, just a force type convert.
    JSNetReachabilityStatus_Unknown = -1,
    JSNetReachabilityStatus_NotReachable = 0,
    JSNetReachabilityStatus_WWAN = 1,
    JSNetReachabilityStatus_WiFi = 2
};

typedef NS_ENUM(NSInteger, JSNetReachabilityCellAuthor)
{
    JSNetReachabilityCellAuthor_Unknown,        // 0 关闭
    JSNetReachabilityCellAuthor_Restricted,     // 1 无蜂窝权限
    JSNetReachabilityCellAuthor_NoRestricted    // 2 有蜂窝权限
};

typedef NS_ENUM(NSInteger, JSNetReachabilityWWANType)
{
    JSNetReachabilityWWANType_Unknown = -1, /// maybe iOS6
    JSNetReachabilityWWANType_4G = 0,
    JSNetReachabilityWWANType_3G = 1,
    JSNetReachabilityWWANType_2G = 3
};

@interface JSNetReachableManager : NSObject

+ (JSNetReachableManager *)shareInstance;

- (void)startMonitoring;

- (void)stopMonitoring;

- (JSNetReachabilityStatus)currentReachabilityStatus;

/**
 *  Return previous reachability status.
 *
 *  @return see enum LocalConnectionStatus
 */
- (JSNetReachabilityStatus)previousReachabilityStatus;

/**
 *  Return current WWAN type immJSiately.
 *
 *  @return unknown/4g/3g/2g.
 *
 *  This method can be usJS to improve app's further network performance
 *  (different strategies for different WWAN types).
 */
- (JSNetReachabilityWWANType)currentWWANtype;

/**
 *  Return previous reachability Author.
 *
 *  @return see enum JSNetReachabilityAuthor
 */
- (JSNetReachabilityCellAuthor)currentReachabilityCellAuthor;

/*
 * 获取网络状态字符串
 */
- (NSString *)networkReachabilityStateString;

@end

NS_ASSUME_NONNULL_END
