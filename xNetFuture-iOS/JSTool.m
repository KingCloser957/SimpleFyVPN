//
//  JSTool.m
//  JadeiteShop
//
//  Created by chsai on 2020/8/19.
//  Copyright © 2020 chsai. All rights reserved.
//

#import "JSTool.h"
#import <CoreTelephony/CTCellularData.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AVFoundation/AVFoundation.h>//相机权限
#import <Photos/Photos.h>//相册权限
#import <MediaPlayer/MediaPlayer.h>
#import <Contacts/Contacts.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/sysctl.h>
#import <CoreLocation/CoreLocation.h>
#import "JSNetReachableManager.h"

@implementation JSTool
+ (UILabel *)lableWithFrame:(CGRect)frame Text:(NSString *)text textColor:(UIColor *)color Alignment:(NSTextAlignment)alignment Font:(UIFont *)font{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = color;
    label.textAlignment = alignment;
    label.font = font;
    return label;
}

+ (UIButton *)buttonWithType:(UIButtonType)type Frame:(CGRect)frame Title:(NSString *)title TitileColor:(UIColor *)color Image:(UIImage *)image target:(id)target selector:(SEL)selector{
    
    UIButton *button = [UIButton buttonWithType:type];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


+ (BOOL)isNotchScreen {

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return NO;
    }

    CGSize size = [UIScreen mainScreen].bounds.size;
    NSInteger notchValue = size.width / size.height * 100;

    if (216 == notchValue || 46 == notchValue) {
        return YES;
    }
    return NO;
}

+ (CGFloat)getStatusBarHight {
//    float statusBarHeight = 0;
//    if (@available(iOS 13.0, *)) {
//        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
//        statusBarHeight = statusBarManager.statusBarFrame.size.height;
//    }else {
//        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    }
    return 64;
}


+ (CGFloat)getBottonStatusHeight{
    if ([JSTool isNotchScreen]) {
        return 34.0f;
    }
    return 0;
}

+ (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

/**
 判断邮箱格式是否正确
 */
+ (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/**
 判断手机号格式是否正确
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum{
    /**
    * 手机号码
    * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
    * 联通：130,131,132,152,155,156,185,186
    * 电信：133,1349,153,180,189
    */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
    10        * 中国移动：China Mobile
    11        * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
    12        */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
    15        * 中国联通：China Unicom
    16        * 130,131,132,152,155,156,185,186
    17        */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
    20        * 中国电信：China Telecom
    21        * 133,1349,153,180,189
    22        */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
    虚拟运营商
    */
    NSString * COther = @"^1[7]\\d{9}$";
    /**
    25        * 大陆地区固话及小灵通
    26        * 区号：010,020,021,022,023,024,025,027,028,029
    27        * 号码：七位或八位
    28        */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    NSPredicate *regextestcother = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", COther];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
    || ([regextestcm evaluateWithObject:mobileNum] == YES)
    || ([regextestct evaluateWithObject:mobileNum] == YES)
    || ([regextestcu evaluateWithObject:mobileNum] == YES)
    || ([regextestPHS evaluateWithObject:mobileNum] == YES)
    || ([regextestcother evaluateWithObject:mobileNum] == YES))
    {
    return YES;
    }
    else
    {
    return NO;
    }

}


/**
// 计算文字宽度
// */
//+ (CGFloat)getTextWidthWithString:(NSString *)text fontSize:(CGFloat)fontSize{
//    
//    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:PX_OR_PT(fontSize)} context:nil].size;
//    return size.width;
//}

+ (NSMutableAttributedString *)getStringWithText:(NSString *)text alignment:(NSTextAlignment)alignment LineSpace:(CGFloat)lineSpace{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    paragraphStyle.alignment = alignment;
    NSDictionary *dict = @{NSParagraphStyleAttributeName:paragraphStyle};
    [str addAttributes:dict range:NSMakeRange(0, text.length)];
    return str;
}

- (NSString*)htmlEntityDecode:(NSString*)string{
    
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return string;
}


//+ (NSMutableString *)getSecretWithStr:(NSString *)str style:(JSSecretStyle)style{
//    
//    if (style == JSSecretStylePhone) {
//        NSMutableString *string = [[NSMutableString alloc] initWithString:str];
//        [string replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
//        return string;
//    }
//    NSString *subStr = [NSString stringWithFormat:@"**** **** **** %@",[str substringFromIndex:str.length - 4]];
//    NSMutableString *numStr = [[NSMutableString alloc] initWithString:subStr];
//    return numStr;
//}

+ (NSString *)fileSizeWithInterge:(NSInteger)size{
    // 1k = 1024, 1m = 1024k

    if (size < 1024) {// 小于1k

    return [NSString stringWithFormat:@"%ldB",(long)size];

    }else if (size < 1024 * 1024){// 小于1m

    CGFloat aFloat = size/1024;

    return [NSString stringWithFormat:@"%.0fK",aFloat];

    }else if (size < 1024 * 1024 * 1024){// 小于1G

    CGFloat aFloat = size/(1024 * 1024);

    return [NSString stringWithFormat:@"%.1fM",aFloat];

    }else{

    CGFloat aFloat = size/(1024*1024*1024);

    return [NSString stringWithFormat:@"%.1fG",aFloat];

    }
}

+(UIViewController *)getCurrentVC
{
//    __block UIViewController *currentViewController = nil;
//    void (^ block)(void) = ^{
//        UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
//        currentViewController = [self findCurrentViewControllerFromRootViewController:rootViewController isRoot:YES];
//    };
//    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {
//        block();
//    } else {
//        dispatch_sync(dispatch_get_main_queue(), block);
//    }
    return [UIViewController new];
}
+ (UIViewController *)findCurrentViewControllerFromRootViewController:(UIViewController *)viewController isRoot:(BOOL)isRoot {
    UIViewController *currentViewController = nil;
    if (viewController.presentedViewController) {
        viewController = [self findCurrentViewControllerFromRootViewController:viewController.presentedViewController isRoot:NO];
    }
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        currentViewController = [self findCurrentViewControllerFromRootViewController:[(UITabBarController *)viewController selectedViewController] isRoot:NO];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        // 根视图为UINavigationController
        currentViewController = [self findCurrentViewControllerFromRootViewController:[(UINavigationController *)viewController visibleViewController] isRoot:NO];
    } else if ([viewController respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIViewController *tempViewController = [viewController performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
        if (tempViewController) {
            currentViewController = [self findCurrentViewControllerFromRootViewController:tempViewController isRoot:NO];
        }
    } else if (viewController.childViewControllers.count == 1 && isRoot) {
        currentViewController = [self findCurrentViewControllerFromRootViewController:viewController.childViewControllers.firstObject isRoot:NO];
    } else {
        currentViewController = viewController;
    }
    return currentViewController;
}
+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL,uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [[uuid lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}
//取一个数组中前num个对象
+ (NSArray *)fetchLimitNumFromArray:(NSArray *)arr limitedNum:(NSInteger)num
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (arr.count > num)
    {
        for (NSInteger i = 0; i < num; i++)
        {
            [result addObject:arr[i]];
        }
    }
    else
    {
        [result addObjectsFromArray:arr];
    }
    return result;
}

//取一个数组中后num个对象
+ (NSArray *)fetchLastLimitNumFromArray:(NSArray *)arr limitedNum:(NSInteger)num
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (arr.count > num)
    {
        for (NSInteger i = arr.count - 1; i >= arr.count - num; i--)
        {
            [result insertObject:arr[i] atIndex:0];
        }
    }
    else
    {
        [result addObjectsFromArray:arr];
    }
    return result;
}

/**
 *  调整尺寸，限制在一定的尺寸内
 *
 *  @param originSize 原始尺寸
 *  @param maxSize    最大尺寸
 *
 *  @return 调整后的尺寸
 */
+(CGSize)fitMaxSizeFromSize:(CGSize)originSize maxSize:(CGSize)maxSize minSize:(CGSize)minSize
{
    float width  = originSize.width;
    float height = originSize.height;
    
    if (width == 0 || height == 0)
    {//图片宽高如果有0，则返回原始数据
        return CGSizeMake(150, 150);
    }
    else if (width > minSize.width && width < maxSize.width &&
             height > minSize.height && height < maxSize.height)
    {
        return CGSizeMake(width, height);
    }
    
    if (width < height)
    {
        if (width < minSize.width)
        {
            height = height*minSize.width/width;
            width  = minSize.width;
            if (height>maxSize.height)
            {
                height=maxSize.height;
            }
        }
        else if (height > maxSize.height)
        {
            width  = width*maxSize.height/height;
            height = maxSize.height;
            if (width<minSize.width)
            {
                width=minSize.width;
            }
        }
    }
    else
    {
        if(height < minSize.height)
        {
            width  = width*minSize.height/height;
            height = minSize.height;
            if (width > maxSize.width)
            {
                width = maxSize.width;
            }
        }
        else if (width > maxSize.width)
        {
            height = height*maxSize.width/width;
            width  = maxSize.width;
            if (height < minSize.height)
            {
                height = minSize.height;
            }
        }
    }
    return CGSizeMake(width, height);
}
+ (NSString *)dataToStringWithTime:(long)interval
{
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString       = [formatter stringFromDate: date];
    return dateString;
}

//json字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
    }
    
    return dic;
}

+ (NSArray *)filterImage:(NSString *)html
{
    if (html.length == 0) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<(img|IMG)(.*?)(/>|></img>|>)" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray *result = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length)];
    
    for (NSTextCheckingResult *item in result) {
        NSString *imgHtml = [html substringWithRange:[item rangeAtIndex:0]];
        
        NSArray *tmpArray = nil;
        if ([imgHtml rangeOfString:@"src=\""].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src=\""];
        } else if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src="];
        }
        
        if (tmpArray.count >= 2) {
            NSString *src = tmpArray[1];
            
            NSUInteger loc = [src rangeOfString:@"\""].location;
            if (loc != NSNotFound) {
                src = [src substringToIndex:loc];
                [resultArray addObject:src];
            }
        }
    }
    return resultArray;
}

+ (NSString *)getCurrentDeviceModel
{
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"])   return @"iPhone 6S";
    if ([platform isEqualToString:@"iPhone8,2"])   return @"iPhone 6S Plus";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

+ (BOOL)checkDeviceCanTel
{
    BOOL bRet = NO;
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType  isEqualToString:@"iPod touch"] ||
       [deviceType  isEqualToString:@"iPad"] ||
       [deviceType  isEqualToString:@"iPhone Simulator"])
    {
        bRet = NO;
    }else{
        bRet = YES;
    }
    return bRet;
}

+ (UIImage *)appIcon
{
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    
    UIImage* image = [UIImage imageNamed:icon];
    return image;
}

+ (NSString *)appName
{
    NSDictionary *bundleDic = [NSBundle mainBundle].infoDictionary;
    NSString *name = bundleDic[@"CFBundleDisplayName"];
    if (!name)
    {
        name = bundleDic[@"CFBundleName"];
    }
    return name;
}

+ (NSString *)cellularProvider
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info serviceSubscriberCellularProviders];
//    NSString *mcc = [carrier mobileCountryCode]; // 国家码 如：460
//    NSString *mnc = [carrier mobileNetworkCode]; // 网络码 如：01
    NSString *name = [carrier carrierName]; // 运营商名称，中国联通
//    NSString *isoCountryCode = [carrier isoCountryCode]; // cn
//    BOOL allowsVOIP = [carrier allowsVOIP];// YES
//    NSString *radioAccessTechnology = info.currentRadioAccessTechnology; /
    
    return  name;
}

+ (uint64_t)diskSpace
{
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return 0;
    uint64_t space =  [[attrs objectForKey:NSFileSystemSize] unsignedLongLongValue];
    if (space < 0) space = 0;
    return space;
}

+ (uint64_t)diskSpaceFree
{
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return 0;
    uint64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    if (space < 0) space = 0;
    return space;
}

+ (uint64_t)diskSpaceUsed
{
    uint64_t total = self.diskSpace;
    uint64_t free = self.diskSpaceFree;
    if (total < 0 || free < 0) return 0;
    uint64_t used = total - free;
    if (used < 0) used = 0;
    return used;
}

//+ (BOOL)authorCheckForAudio
//{
//    BOOL isAuthor = NO;
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
//    
//    switch (authStatus) {
//        case AVAuthorizationStatusRestricted:
//        case AVAuthorizationStatusDenied:
//        {
//            NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭麦克风权限",[[self class] appName]];
//            [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开麦克风权限"];
//        }
//            break;
//        case AVAuthorizationStatusNotDetermined:
//        {
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
//                if (granted)
//                {// 用户同意授权
//                    
//                }
//                else
//                {// 用户拒绝授权
//                    
//                }
//            }];
//        }
//            break;
//        case AVAuthorizationStatusAuthorized:
//        {
//            isAuthor = YES;
//        }
//            break;
//        default:
//            break;
//    }
//    
//    return isAuthor;
//}

//+ (BOOL)authorCheckForAudio1
//{
//    BOOL isAuthor = NO;
//    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    
//    switch (audioSession.recordPermission) {
//        case AVAudioSessionRecordPermissionUndetermined:
//        {
//            [audioSession requestRecordPermission:^(BOOL granted) {
//                if (granted)
//                {// 用户同意授权
//                }
//                else
//                {// 用户拒绝授权
//                }
//            }];
//        }
//            break;
//        case AVAudioSessionRecordPermissionDenied:
//        {
//            NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭麦克风权限",[[self class] appName]];
//            [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开麦克风权限"];
//        }
//            break;
//        case AVAudioSessionRecordPermissionGranted:
//        {
//            isAuthor = YES;
//        }
//            break;
//        default:
//            break;
//    }
//    
//    return isAuthor;
//}
//
//+ (BOOL)authorCheckForVideo
//{
//    BOOL isAuthor = NO;
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    
//    switch (authStatus) {
//        case AVAuthorizationStatusRestricted:
//        case AVAuthorizationStatusDenied:
//        {
//            NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭相机权限",[[self class] appName]];
//            [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开相机权限"];
//        }
//            break;
//        case AVAuthorizationStatusNotDetermined:
//        {
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                
//                if (granted)
//                {// 用户同意授权
//                }
//                else
//                {// 用户拒绝授权
//                }
//            }];
//        }
//            break;
//        case AVAuthorizationStatusAuthorized:
//        {
//            isAuthor = YES;
//        }
//            break;
//        default:
//            break;
//    }
//    
//    return isAuthor;
//}
//
//+ (BOOL)authorCheckForLocation
//{
//    BOOL isAuthor = NO;
//    
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    
//    switch (status) {
//        case kCLAuthorizationStatusRestricted:
//        case kCLAuthorizationStatusDenied:
//        {
//            NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭定位权限",[[self class] appName]];
//            [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开定位权限"];
//        }
//            break;
//        case kCLAuthorizationStatusNotDetermined:
//        case kCLAuthorizationStatusAuthorizedAlways:
//        case kCLAuthorizationStatusAuthorizedWhenInUse:
//        {
//            isAuthor = YES;
//        }
//            break;
//            
//        default:
//            break;
//    }
//    
//    return isAuthor;
//}

//+ (void)showAuthorTipsWithTitle:(NSString *)title message:(NSString *)message
//{
//    //未授权
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
//                                                                             message:message
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    
//    
//    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"知道了"
//                                                           style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    
//    
//    
//    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"去开启"
//                                                       style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction * _Nonnull action) {
//        [[self class] openAppSettings];
//    }];
//    
//    
//    
//    [alertController addAction:actionCancel];
//    [alertController addAction:actionOK];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [alertController show];
//    });
//}

//+ (BOOL)authorCheckForMediaLibrary
//{
//    BOOL isAuthor = NO;
//    MPMediaLibraryAuthorizationStatus authorStatus = [MPMediaLibrary authorizationStatus];
//    switch (authorStatus)
//    {
//        case MPMediaLibraryAuthorizationStatusNotDetermined:
//        {//还未对此app权限做出选择
//            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//                if (status == PHAuthorizationStatusAuthorized)
//                {
//                    // 用户同意授权
//                }
//                else
//                {
//                    // 用户拒绝授权
//                }
//            }];
//        }
//            break;
//        case MPMediaLibraryAuthorizationStatusDenied://用户已明确拒绝此应用程序对照片数据的访问。
//        case MPMediaLibraryAuthorizationStatusRestricted://此应用程序没有权限访问照片数据。用户不能更改应用程序的状态，可能是由于活动限制。(比如家长控制（网上说的）)
//        {
//            //未授权
//            NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭Apple Music权限",[[self class] appName]];
//            [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开Apple Music权限"];
//        }
//            break;
//        case MPMediaLibraryAuthorizationStatusAuthorized:
//        {//已授权
//            isAuthor = YES;
//        }
//            break;
//            
//        default:
//            break;
//    }
//    return isAuthor;
//}
//+ (BOOL)authorCheckForAlbum
//{
//    BOOL isAuthor = NO;
//    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
//    
//    switch (photoAuthorStatus)
//    {
//        case PHAuthorizationStatusNotDetermined:
//        {//还未对此app权限做出选择
//            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//                if (status == PHAuthorizationStatusAuthorized)
//                {
//                    // 用户同意授权
//                }
//                else
//                {
//                    // 用户拒绝授权
//                }
//            }];
//        }
//            break;
//        case PHAuthorizationStatusDenied://用户已明确拒绝此应用程序对照片数据的访问。
//        case PHAuthorizationStatusRestricted://此应用程序没有权限访问照片数据。用户不能更改应用程序的状态，可能是由于活动限制。(比如家长控制（网上说的）)
//        {
//            //未授权
//            NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭相册权限",[[self class] appName]];
//            [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开相册权限"];
//        }
//            break;
//        case PHAuthorizationStatusAuthorized:
//        {//已授权
//            isAuthor = YES;
//        }
//            break;
//            
//        default:
//            break;
//    }
//    return isAuthor;
//}

//+ (BOOL)authorCheckForNetwork
//{
//    BOOL isAuthor = NO;
//    CTCellularData *cellularData = [[CTCellularData alloc]init];
//    CTCellularDataRestrictedState state = cellularData.restrictedState;
//    switch (state) {
//        case kCTCellularDataRestricted:
//        {
//            NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭网络权限",[[self class] appName]];
//            [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开网络权限"];
//        }
//            break;
//        case kCTCellularDataNotRestricted:
//        {
//            isAuthor = YES;
//        }
//            break;
//        case kCTCellularDataRestrictedStateUnknown:
//        {
//            
//        }
//            break;
//        default:
//            break;
//    }
//    return isAuthor;
//}

//+ (void)authorCheckNetworkMonitor
//{
//    CTCellularData *cellularData = [[CTCellularData alloc]init];
//    cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state){
//        //获取联网状态
//        switch (state) {
//            case kCTCellularDataRestricted:
//            {
//                NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭网络权限",[[self class] appName]];
//                [[self class] showAuthorTipsWithTitle:title message:@"可以在\"设置\"中为此应用打开权限"];
//            }
//                break;
//            case kCTCellularDataNotRestricted:
//                NSLog(@"Not Restricted");
//                break;
//            case kCTCellularDataRestrictedStateUnknown:
//                NSLog(@"Unknown");
//                break;
//            default:
//                break;
//        };
//    };
//}
//
//+ (BOOL)authorCheckForNetWorkUnReachable
//{
//    BOOL show = NO;
//    NSString *message = @"可以在\"设置\"中为此应用打开权限";
//    NSString *title = nil;
//    JSNetReachableManager *netReachableMgr = [JSNetReachableManager shareInstance];
//    JSNetReachabilityCellAuthor author = netReachableMgr.currentReachabilityCellAuthor;
//    if (JSNetReachabilityCellAuthor_Restricted == author){
//        show = YES;
//        title = [NSString stringWithFormat:@"已为\"%@\"关闭网络权限",[[self class] appName]];
//    }
//    
//    if (show){
//        [[self class] showAuthorTipsWithTitle:title message:message];
//    }
//    
//    return show;
//}

////网络状态检测
//+ (BOOL)networkReachability
//{
//    BOOL isAuthor = YES;
//    if (![AFNetworkReachabilityManager sharedManager].reachable)
//    {
//        isAuthor = NO;
//        [[self class] showAuthorTipsWithTitle:[NSString stringWithFormat:@"已为\"%@\"关闭网络权限",[[self class] appName]]
//                                      message:@"可以在\"设置\"中为此应用打开权限"];
//    }
//    return isAuthor;
//}

////打电话
//+ (void)callPhoneWithNum:(NSString *)phoneNum
//{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
//    if (@available(iOS 10.0, *)) {
//        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
//    } else {
//        [[UIApplication sharedApplication] openURL:url];
//    }
//}
//
////跳转到app设置
//+ (void)openAppSettings
//{
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//}

+ (BOOL)isiPhoneX {
    // 先判断当前设备是否为 iPhone 或 iPod touch
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // 获取屏幕的宽度和高度，取较大一方判断是否为 812.0 或 896.0
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat maxLength = screenWidth > screenHeight ? screenWidth : screenHeight;
        if (maxLength == 812.0f || maxLength == 896.0f) {
            return YES;
        }
    }
    return NO;
}
/*清除所有的存储本地的数据*/
+ (void)clearAllUserDefaultsData
{
    NSUserDefaults*userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary*dic = [userDefaults dictionaryRepresentation];
    
    for(id key in dic)
    {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
    
}

//+ (void)checkCameraPermission:(JSPermissionBlock)permissionBlock {
//    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    
//    switch (cameraStatus) {
//        case AVAuthorizationStatusRestricted:
//        case AVAuthorizationStatusDenied:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭相机权限",[[self class] appName]];
//                [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开相机权限"];
//            });
//        }
//            break;
//            
//        case AVAuthorizationStatusNotDetermined:
//        {
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                if ([[NSThread currentThread] isMainThread]){
//                    permissionBlock(granted);
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        permissionBlock(granted);
//                    });
//                }
//                
//            }];
//        }
//            break;
//            
//        case AVAuthorizationStatusAuthorized:
//            permissionBlock(YES);
//            break;
//            
//        default:
//            permissionBlock(YES);
//            break;
//    }
//}
//
//+ (void)checkPhotoPermission:(JSPermissionBlock)permissionBlock {
//    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
//    
//    switch (photoStatus)
//    {
//        case PHAuthorizationStatusDenied:
//        case PHAuthorizationStatusRestricted:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *title = [NSString stringWithFormat:@"已为\"%@\"关闭相册权限",[[self class] appName]];
//                [[self class] showAuthorTipsWithTitle:title message:@"您可以在\"设置\"中为此应用打开相册权限"];
//            });
//        }
//            break;
//            
//        case PHAuthorizationStatusNotDetermined:
//        {
//            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//                if ([[NSThread currentThread] isMainThread]){
//                    permissionBlock(status == PHAuthorizationStatusAuthorized);
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        permissionBlock(status == PHAuthorizationStatusAuthorized);
//                    });
//                }
//            }];
//        }
//            break;
//            
//        case PHAuthorizationStatusAuthorized:
//            permissionBlock(YES);
//            break;
//            
//        default:
//            permissionBlock(YES);
//            break;
//    }
//}
//+ (UIViewController *)getRootViewController;
//{
//    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//    return window.rootViewController;
//}



@end
