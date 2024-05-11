//
//  MDVPNModel.h
//  xNetFuture
//
//  Created by huangrui on 2024/5/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDVPNModel : NSObject

@property (nonatomic,copy) NSString *linkUrl;
@property (nonatomic,copy) NSString *linkName;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,assign) BOOL isGlobel;
@property (nonatomic,assign) BOOL isVless;

@end

NS_ASSUME_NONNULL_END
