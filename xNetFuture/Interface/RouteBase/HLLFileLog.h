//
//  HLLFileLog.h
//  HLLPCH
//
//  Created by isec on 2019/10/16.
//  Copyright © 2019 isec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLLFileLog : NSObject

+ (void)passToLogFile:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
