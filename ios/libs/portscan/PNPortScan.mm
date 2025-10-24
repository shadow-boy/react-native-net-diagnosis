//
//  PNPortScan.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/2/28.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNPortScan.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"
#import "PhoneNetDiagnosisHelper.h"
#import "PNetQueue.h"
@interface PNPortScan()
{
    int socket_client;
}

@property (nonatomic,assign) BOOL isStopPortScan;

@end

@implementation PNPortScan
static PNPortScan *pnPortScan_instance = NULL;
- (instancetype)init
{
    if (self = [super init]) {
        _isStopPortScan = YES;
    }
    return self;
}

+ (instancetype)shareInstance
{
    if (pnPortScan_instance == NULL) {
        pnPortScan_instance = [[PNPortScan alloc] init];
    }
    return pnPortScan_instance;
}

// 端口扫描实现：接收端口数组
- (void)portScan:(NSString *)host ports:(NSArray<NSNumber *> *)ports completeHandler:(NetPortScanHandler)handler
{
    if (ports.count == 0) {
        return;
    }
    
    [PNetQueue pnet_async:^{
        [self startPortScanWithPorts:host ports:ports completeHandler:handler];
    }];
}

- (void)startPortScanWithPorts:(NSString *)host ports:(NSArray<NSNumber *> *)ports completeHandler:(NetPortScanHandler)handler
{
    // 获取 IP 地址
    struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
    if (NULL == remoteHostEnt) {
        log4cplus_warn("PhoneNetSDKPortScan", "Unable to parse host");
        handler(nil, NO, [PNError errorWithInvalidCondition:@"Unable to parse host"]);
        return;
    }
    
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    self.isStopPortScan = NO;
    
    // 遍历端口数组
    for (NSNumber *portNum in ports) {
        if (self.isStopPortScan) {
            break;
        }
        
        NSUInteger port = [portNum unsignedIntegerValue];
        
        socket_client = socket(AF_INET, SOCK_STREAM, 0);
        if (-1 == socket_client) {
            handler([NSString stringWithFormat:@"%lu", (unsigned long)port], NO, 
                   [PNError errorWithInvalidCondition:@"Failed to create socket"]);
            continue;
        }
        
        // 设置 socket 参数
        struct sockaddr_in socketParameters;
        socketParameters.sin_family = AF_INET;
        socketParameters.sin_addr = *remoteInAddr;
        socketParameters.sin_port = htons(port);
        
        int ret = connect(socket_client, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
        if (-1 == ret) {
            close(socket_client);
            handler([NSString stringWithFormat:@"%lu", (unsigned long)port], NO, nil);
            continue;
        }
        
        handler([NSString stringWithFormat:@"%lu", (unsigned long)port], YES, nil);
        close(socket_client);
    }
    
    self.isStopPortScan = YES;
}

- (BOOL)isDoingScanPort
{
    return !self.isStopPortScan;
}

- (void)stopPortScan
{
    self.isStopPortScan = YES;
}
@end
