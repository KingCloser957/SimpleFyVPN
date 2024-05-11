//
//  HLLFileLog.m
//  HLLPCH
//
//  Created by isec on 2019/10/16.
//  Copyright © 2019 isec. All rights reserved.
//

#import "HLLFileLog.h"
#import "Potatso.h"
@implementation HLLFileLog
+ (void)passToLogFile:(NSString *)str{
    
#if DEBUG
//        NSString *filePath = [[Potatso shared] sharedAutoLogFile] ;
//        filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""] ;
//        filePath = [filePath stringByReplacingOccurrencesOfString:@"%20" withString:@" "] ;
//        FILE *fp ;
//        if ((fp=fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "a"))==NULL){
//            if ((fp=fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w"))==NULL){
//                NSLog(@"open file error") ;
//            }
//        }
//        if (fp){
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.timeStyle = NSDateFormatterMediumStyle;
//            NSString *logTime = [dateFormatter stringFromDate:[NSDate date]];
//            NSString *loginfo =  [NSString stringWithFormat:@"\n\n%@: %@", logTime, (str)] ;
//            if (fwrite([loginfo cStringUsingEncoding:NSUTF8StringEncoding], [loginfo lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 1, fp)<1) {
//                NSLog(@"fwrite file error") ;
//            }
//            fclose(fp) ;
//        }
#endif
}
@end
