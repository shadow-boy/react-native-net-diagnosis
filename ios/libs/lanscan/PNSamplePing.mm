//
//  PNSamplePing.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "PNSamplePing.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"
#import "PNetQueue.h"


@interface PNSamplePing()
{
    int lan_scan_socket_client;
    struct sockaddr_in lan_scan_remote_addr;
}

@property (nonatomic,assign) BOOL isStopPingThread;
@property (nonatomic,strong) NSString *scanIp;
@property (nonatomic,assign) int sendPacketCount;
@end

@implementation PNSamplePing

- (instancetype)init
{
    if ([super init]) {
        
        _isStopPingThread = NO;
    }
    return self;
}

- (void)stopPing
{
    self.isStopPingThread = YES;
    shutdown(lan_scan_socket_client, SHUT_RDWR);
    close(lan_scan_socket_client);
    [self.delegate simplePing:self finished:self.scanIp];
    log4cplus_debug("PhoneNetSDK-LanScanner", "scan ip %s end...",[self.scanIp UTF8String]);
}

- (BOOL)isPing
{
    return !self.isStopPingThread;
}

- (BOOL)isResponseFromScanIpWithAddress:(struct sockaddr_storage *)retAddr buffer:(char *)buffer len:(int)len
{
    if (self.scanIp.length == 0) {
        return NO;
    }

    if (retAddr != NULL && retAddr->ss_family == AF_INET) {
        struct sockaddr_in *addr = (struct sockaddr_in *)retAddr;
        char sourceIp[INET_ADDRSTRLEN] = {0};
        const char *result = inet_ntop(AF_INET, &(addr->sin_addr), sourceIp, sizeof(sourceIp));
        if (result != NULL && strcmp(sourceIp, [self.scanIp UTF8String]) == 0) {
            return YES;
        }
    }

    if (buffer != NULL && len >= sizeof(PNetIPHeader)) {
        const PNetIPHeader *ipHeader = (const PNetIPHeader *)buffer;
        if ((ipHeader->versionAndHeaderLength & 0xF0) == 0x40) {
            char sourceIp[INET_ADDRSTRLEN] = {0};
            const char *result = inet_ntop(AF_INET, ipHeader->sourceAddress, sourceIp, sizeof(sourceIp));
            if (result != NULL && strcmp(sourceIp, [self.scanIp UTF8String]) == 0) {
                return YES;
            }
        }
    }

    return NO;
}

- (BOOL)settingUHostSocketAddressWithIp:(NSString *)host
{
    const char *hostaddr = [host UTF8String];
    memset(&lan_scan_remote_addr, 0, sizeof(lan_scan_remote_addr));
    lan_scan_remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 1000*200;
    lan_scan_socket_client = socket(AF_INET,SOCK_DGRAM,IPPROTO_ICMP);
    int nZero=0;
    setsockopt(lan_scan_socket_client,SOL_SOCKET,SO_SNDBUF,(char *)&nZero,sizeof(nZero));
    int res = setsockopt(lan_scan_socket_client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    if (res < 0) {
        log4cplus_warn("PhoneNetSimplePing", "ping %s , set timeout error..\n",[host UTF8String]);
        return YES;
    }
    lan_scan_remote_addr.sin_family = AF_INET;
    
    return YES;
}

- (void)startPingIp:(NSString *)ip packetCount:(int)count
{
    log4cplus_debug("PhoneNetSDK-LanScanner", "scan ip %s begin...",[ip UTF8String]);
    if ([self settingUHostSocketAddressWithIp:ip]) {
        self.scanIp = ip;
    }
    
    if (self.scanIp == NULL) {
        self.isStopPingThread = YES;
        log4cplus_warn("PhoneNetSDK-LanScanner", "There is no valid ip...\n");
        return;
    }
    
    if (count > 0) {
        _sendPacketCount = count;
    }
    [PNetQueue pnet_quick_ping_async:^{
        [self sendAndrecevPingPacket];
    }];
}

- (void)sendAndrecevPingPacket
{
    int index = 0;
    do {
        if (self.isStopPingThread) {
            return;
        }
        uint16_t identifier = (uint16_t)(KPingIcmpIdBeginNum + index);
        UICMPPacket *packet = [PhoneNetDiagnosisHelper constructPacketWithSeq:index andIdentifier:identifier];
        ssize_t sent = sendto(lan_scan_socket_client, packet, sizeof(UICMPPacket), 0, (struct sockaddr *)&lan_scan_remote_addr, (socklen_t)sizeof(struct sockaddr));
        if (sent < 0) {
            log4cplus_warn("PhoneNetSDK-LanScanner", "ping %s , error code:%d, send icmp packet error..\n",[self.scanIp UTF8String],(int)sent);
            [self stopPing];
            break;
        }
        
        BOOL res = NO;
        struct sockaddr_storage ret_addr;
        socklen_t addrLen = sizeof(ret_addr);
        void *buffer = malloc(65535);
        if (buffer == NULL) {
            log4cplus_warn("PhoneNetSDK-LanScanner", "ping %s , malloc receive buffer failed..\n",[self.scanIp UTF8String]);
            res = YES;
            continue;
        }
        
        size_t bytesRead = recvfrom(lan_scan_socket_client, buffer, 65535, 0, (struct sockaddr *)&ret_addr, &addrLen);
        
        if ((int)bytesRead < 0) {
            [self.delegate simplePing:self didTimeOut:self.scanIp];
            res = YES;
        }else if(bytesRead == 0){
            log4cplus_warn("PhoneNetSDK-LanScanner", "ping %s , receive icmp packet error , bytesRead=0",[self.scanIp UTF8String]);
            res = YES;
        }else{
            BOOL isExpectedSource = [self isResponseFromScanIpWithAddress:&ret_addr buffer:(char *)buffer len:(int)bytesRead];
            BOOL isExpectedPacket = [PhoneNetDiagnosisHelper isValidPingResponseWithBuffer:(char *)buffer
                                                                                       len:(int)bytesRead
                                                                                       seq:index
                                                                                identifier:identifier];
            
            if (isExpectedSource && isExpectedPacket) {
                [self.delegate simplePing:self receivedPacket:self.scanIp];
                free(buffer);
                [self stopPing];
                break;
            }
            
            res = YES;
        }

        free(buffer);
        
        if (res) {
            index++;
        }
        usleep(1000);
    } while (!self.isStopPingThread && index < _sendPacketCount);
    
    if (index == _sendPacketCount) {
        [self stopPing];
    }
    
}
@end
