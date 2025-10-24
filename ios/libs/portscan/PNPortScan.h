//
//  PNPortScan.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/2/28.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneNetSDKHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNPortScan : NSObject
+ (instancetype)shareInstance;

// 端口扫描：接收端口数组
- (void)portScan:(NSString *)host ports:(NSArray<NSNumber *> *)ports completeHandler:(NetPortScanHandler)handler;

- (BOOL)isDoingScanPort;
- (void)stopPortScan;
@end

NS_ASSUME_NONNULL_END
