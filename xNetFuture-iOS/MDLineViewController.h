//
//  MDLineViewController.h
//  xNetFuture
//
//  Created by huangrui on 2024/5/8.
//

#import <UIKit/UIKit.h>
#import "MDVPNModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^selectLineBlock)(MDVPNModel *model);

@interface MDLineViewController : UIViewController

@property (nonatomic,copy)selectLineBlock block;

@end

NS_ASSUME_NONNULL_END
