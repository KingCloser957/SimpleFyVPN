//
//  JSTool.h
//  JadeiteShop
//
//  Created by chsai on 2020/8/19.
//  Copyright © 2020 chsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^JSPermissionBlock)(BOOL havePermission);

//NS_ASSUME_NONNULL_BEGIN

@interface JSTool : NSObject

/**
 创建标签
 
 @param frame 大小
 @param text 文字
 @param color 文字颜色
 @param alignment 对齐方式
 @param font 字体
 @return label
 */
+ (UILabel *)lableWithFrame:(CGRect)frame
                       Text:(NSString *)text
                  textColor:(UIColor *)color
                  Alignment:(NSTextAlignment)alignment
                       Font:(UIFont *)font;


/**
 创建按钮
 
 @param type button类型
 @param frame 大小
 @param title 标题
 @param color 标题颜色
 @param image 图片
 @param selector 点击事件
 @return button
 */
+ (UIButton *)buttonWithType:(UIButtonType)type
                       Frame:(CGRect)frame
                       Title:(NSString *)title
                 TitileColor:(UIColor *)color
                       Image:(UIImage *)image
                      target:(id)target
                    selector:(SEL)selector;


/**
 判断手机是否为刘海屏
 */
+ (BOOL)isNotchScreen;


/**
 获取状态栏高度
 */
+ (CGFloat)getStatusBarHight;


/**
 获取底部高度
 */
+ (CGFloat)getBottonStatusHeight;


/**
 判断字符串是否为空
 */
+ (BOOL)isBlankString:(NSString *)string;

/**
 判断邮箱格式是否正确
 */
+ (BOOL)isValidateEmail:(NSString *)email;

/**
 判断手机号格式是否正确
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

/**
 计算文字宽度
 */
+ (CGFloat)getTextWidthWithString:(NSString *)text fontSize:(CGFloat)fontSize;


/**
 设置文字间距
 */
+ (NSMutableAttributedString *)getStringWithText:(NSString *)text alignment:(NSTextAlignment)alignment LineSpace:(CGFloat)lineSpace;

/**
 隐藏卡号中间部分
 */

//+ (NSMutableString *)getSecretWithStr:(NSString *)str style:(JSSecretStyle)style;

/**
 计算缓存大小
 */
+ (NSString *)fileSizeWithInterge:(NSInteger)size;

/**
 获取当前控制器
 */
+ (UIViewController *)getCurrentVC;
/**
 获取uuid
 */
+ (NSString *)uuidString;

/*
 * 获取当前设备是否可以打电话
 */
+ (BOOL)checkDeviceCanTel;

/*
 * 获取当前设备Model字符串
 */
+ (NSString *)getCurrentDeviceModel;

/**
 获取系统icon
 */
+ (UIImage *)appIcon;
/**
 app 名字
 
 @return app 名字
 */
+ (NSString *)appName;

/**
 获取运营商名称
 */
+ (NSString *)cellularProvider;

+ (uint64_t)diskSpace;

+ (uint64_t)diskSpaceFree;

+ (uint64_t)diskSpaceUsed;

/**
 麦克风权限检测与获取
 */
+ (BOOL)authorCheckForAudio;
+ (BOOL)authorCheckForAudio1;//与 authorCheckForAudio 方法效果是一样的

/**
 相机权限检测与获取
 */
+ (BOOL)authorCheckForVideo;

/**
 定位权限
 */
+ (BOOL)authorCheckForLocation;

/**
 apple music 权限
 */
+ (BOOL)authorCheckForMediaLibrary;

/**
 相册权限与获取
 */
+ (BOOL)authorCheckForAlbum;

/**
 网络权限检测与获取
 */
+ (BOOL)authorCheckForNetwork;

/**
 实时监测网络权限变化
 */
+ (void)authorCheckNetworkMonitor;

/*
 * 检测网络权限当网络不通
 */
+ (BOOL)authorCheckForNetWorkUnReachable;

//网络状态检测
+ (BOOL)networkReachability;
//打电话
+ (void)callPhoneWithNum:(NSString *)phoneNum;

+ (void)openAppSettings;

+ (BOOL)isiPhoneX;

/*清除所有的存储本地的数据*/
+(void)clearAllUserDefaultsData;

+ (NSMutableArray *)shareTypeArray;


#pragma mark - block类型权限判断

/** 相机权限*/
+ (void)checkCameraPermission:(JSPermissionBlock)permissionBlock;
/** 相册权限*/
+ (void)checkPhotoPermission:(JSPermissionBlock)permissionBlock;

+ (UIViewController *)getRootViewController;

@end

//NS_ASSUME_NONNULL_END
