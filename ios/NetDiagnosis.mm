#import "NetDiagnosis.h"
#import "libs/public/PhoneNetManager.h"
#import "libs/public/bean/PNetModel.h"
#import "libs/tcpping/PNTcpPing.h"
#import "libs/udptracert/PNUdpTraceroute.h"
#import "libs/lanscan/PNetMLanScanner.h"
#import <React/RCTBridge.h>
#import <React/RCTEventEmitter.h>

@interface NetDiagnosis () <PNetMLanScannerDelegate>
@property (nonatomic, strong) PNTcpPing *tcpPingInstance;
@property (nonatomic, strong) PNUdpTraceroute *udpTracerouteInstance;
@end

@implementation NetDiagnosis
{
    bool hasListeners;
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[
        @"onPingResult",
        @"onTracerouteResult",
        @"onUdpTracerouteResult",
        @"onTcpPingResult",
        @"onPortScanResult",
        @"onLanScanActiveIp",
        @"onLanScanProgress",
        @"onLanScanFinished"
    ];
}

- (void)startObserving
{
    hasListeners = YES;
}

- (void)stopObserving
{
    hasListeners = NO;
}

#pragma mark - SDK Configuration

- (void)initialize
{
    [[PhoneNetManager shareInstance] registPhoneNetSDK];
}

- (void)setLogLevel:(double)level
{
    PhoneNetSDKLogLevel logLevel = (PhoneNetSDKLogLevel)(int)level;
    [[PhoneNetManager shareInstance] settingSDKLogLevel:logLevel];
}

- (NSString *)getSDKVersion
{
    return [[PhoneNetManager shareInstance] sdkVersion];
}

#pragma mark - Ping

- (void)startPing:(NSString *)host count:(double)count
{
    __weak __typeof__(self) weakSelf = self;
    [[PhoneNetManager shareInstance] netStartPing:host
                                      packetCount:(int)count
                              pingResultHandler:^(NSString * _Nullable pingres, BOOL isEnd) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf->hasListeners) {
            [strongSelf sendEventWithName:@"onPingResult"
                                     body:@{
                                         @"result": pingres ?: @"",
                                         @"isEnd": @(isEnd)
                                     }];
        }
    }];
}

- (void)stopPing
{
    [[PhoneNetManager shareInstance] netStopPing];
}

- (NSNumber *)isPinging
{
    BOOL result = [[PhoneNetManager shareInstance] isDoingPing];
    return @(result);
}

#pragma mark - Traceroute (ICMP)

- (void)startTraceroute:(NSString *)host
{
    __weak __typeof__(self) weakSelf = self;
    [[PhoneNetManager shareInstance] netStartTraceroute:host
                               tracerouteResultHandler:^(NSString * _Nullable tracertRes, NSString * _Nullable destIp, BOOL isEnd) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf->hasListeners) {
            [strongSelf sendEventWithName:@"onTracerouteResult"
                                     body:@{
                                         @"result": tracertRes ?: @"",
                                         @"destIp": destIp ?: @"",
                                         @"isEnd": @(isEnd)
                                     }];
        }
    }];
}

- (void)stopTraceroute
{
    [[PhoneNetManager shareInstance] netStopTraceroute];
}

- (NSNumber *)isTracerouting
{
    BOOL result = [[PhoneNetManager shareInstance] isDoingTraceroute];
    return @(result);
}

#pragma mark - UDP Traceroute

- (void)startUdpTraceroute:(NSString *)host maxTtl:(double)maxTtl
{
    __weak __typeof__(self) weakSelf = self;
    
    if (maxTtl > 0) {
        self.udpTracerouteInstance = [PNUdpTraceroute start:host
                                                     maxTtl:(NSUInteger)maxTtl
                                                   complete:^(NSMutableString *result) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            if (strongSelf && strongSelf->hasListeners) {
                [strongSelf sendEventWithName:@"onUdpTracerouteResult"
                                         body:@{
                                             @"result": result ?: @""
                                         }];
            }
        }];
    } else {
        self.udpTracerouteInstance = [PNUdpTraceroute start:host
                                                   complete:^(NSMutableString *result) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            if (strongSelf && strongSelf->hasListeners) {
                [strongSelf sendEventWithName:@"onUdpTracerouteResult"
                                         body:@{
                                             @"result": result ?: @""
                                         }];
            }
        }];
    }
}

- (void)stopUdpTraceroute
{
    if (self.udpTracerouteInstance) {
        [self.udpTracerouteInstance stopUdpTraceroute];
        self.udpTracerouteInstance = nil;
    }
}

- (NSNumber *)isUdpTracerouting
{
    BOOL result = self.udpTracerouteInstance && [self.udpTracerouteInstance isDoingUdpTraceroute];
    return @(result);
}

#pragma mark - TCP Ping

- (void)startTcpPing:(NSString *)host port:(double)port count:(double)count
{
    __weak __typeof__(self) weakSelf = self;
    self.tcpPingInstance = [PNTcpPing start:host
                                       port:(NSUInteger)port
                                      count:(NSUInteger)count
                                   complete:^(NSMutableString *result, BOOL isEnd) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf->hasListeners) {
            [strongSelf sendEventWithName:@"onTcpPingResult"
                                     body:@{
                                         @"result": result ?: @"",
                                         @"isEnd": @(isEnd)
                                     }];
        }
    }];
}

- (void)stopTcpPing
{
    if (self.tcpPingInstance) {
        [self.tcpPingInstance stopTcpPing];
        self.tcpPingInstance = nil;
    }
}

- (NSNumber *)isTcpPinging
{
    BOOL result = self.tcpPingInstance && [self.tcpPingInstance isTcpPing];
    return @(result);
}

#pragma mark - Port Scan

- (void)startPortScan:(NSString *)host beginPort:(double)beginPort endPort:(double)endPort
{
    __weak __typeof__(self) weakSelf = self;
    [[PhoneNetManager shareInstance] netPortScan:host
                                       beginPort:(NSUInteger)beginPort
                                         endPort:(NSUInteger)endPort
                                 completeHandler:^(NSString * _Nullable port, BOOL isOpen, PNError * _Nullable sdkError) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf->hasListeners) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            result[@"port"] = port ?: @"";
            result[@"isOpen"] = @(isOpen);
            if (sdkError) {
                result[@"error"] = sdkError.error.localizedDescription ?: @"";
            }
            [strongSelf sendEventWithName:@"onPortScanResult" body:result];
        }
    }];
}

- (void)stopPortScan
{
    [[PhoneNetManager shareInstance] netStopPortScan];
}

- (NSNumber *)isPortScanning
{
    BOOL result = [[PhoneNetManager shareInstance] isDoingPortScan];
    return @(result);
}

#pragma mark - Domain Lookup

- (void)lookupDomain:(NSString *)domain callback:(RCTResponseSenderBlock)callback
{
    [[PhoneNetManager shareInstance] netLookupDomain:domain
                                      completeHandler:^(NSMutableArray<DomainLookUpRes *> * _Nullable lookupRes, PNError * _Nullable sdkError) {
        if (sdkError) {
            callback(@[@{@"error": sdkError.error.localizedDescription ?: @"Unknown error"}]);
            return;
        }
        
        NSMutableArray *results = [NSMutableArray array];
        for (DomainLookUpRes *res in lookupRes) {
            [results addObject:@{
                @"name": res.name ?: @"",
                @"ip": res.ip ?: @""
            }];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:0 error:&error];
        if (error) {
            callback(@[@{@"error": error.localizedDescription}]);
            return;
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        callback(@[jsonString ?: @"[]"]);
    }];
}

#pragma mark - LAN Scan

- (void)startLanScan
{
    PNetMLanScanner *scanner = [PNetMLanScanner shareInstance];
    scanner.delegate = self;
    [scanner scan];
}

- (void)stopLanScan
{
    PNetMLanScanner *scanner = [PNetMLanScanner shareInstance];
    [scanner stop];
}

- (NSNumber *)isLanScanning
{
    BOOL result = [[PNetMLanScanner shareInstance] isScanning];
    return @(result);
}

#pragma mark - PNetMLanScannerDelegate

- (void)scanMLan:(PNetMLanScanner *)scanner activeIp:(NSString *)ip
{
    if (hasListeners) {
        [self sendEventWithName:@"onLanScanActiveIp"
                           body:@{@"ip": ip ?: @""}];
    }
}

- (void)scanMlan:(PNetMLanScanner *)scanner percent:(float)percent
{
    if (hasListeners) {
        [self sendEventWithName:@"onLanScanProgress"
                           body:@{@"percent": @(percent)}];
    }
}

- (void)finishedScanMlan:(PNetMLanScanner *)scanner
{
    if (hasListeners) {
        [self sendEventWithName:@"onLanScanFinished" body:@{}];
    }
}



#pragma mark - Network Info

- (void)getNetworkInfo:(RCTResponseSenderBlock)callback
{
    NetWorkInfo *info = [[PhoneNetManager shareInstance] netGetNetworkInfo];
    
    if (!info) {
        callback(@[@{@"error": @"Failed to get network info"}]);
        return;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    // Device net info
    if (info.deviceNetInfo) {
        result[@"deviceNetInfo"] = @{
            @"netType": info.deviceNetInfo.netType ?: @"",
            @"wifiSSID": info.deviceNetInfo.wifiSSID ?: @"",
            @"wifiBSSID": info.deviceNetInfo.wifiBSSID ?: @"",
            @"wifiIPV4": info.deviceNetInfo.wifiIPV4 ?: @"",
            @"wifiNetmask": info.deviceNetInfo.wifiNetmask ?: @"",
            @"wifiIPV6": info.deviceNetInfo.wifiIPV6 ?: @"",
            @"cellIPV4": info.deviceNetInfo.cellIPV4 ?: @""
        };
    }
    
    // IP info
    if (info.ipInfoModel) {
        result[@"ipInfoModel"] = @{
            @"ip": info.ipInfoModel.ip ?: @"",
            @"city": info.ipInfoModel.city ?: @"",
            @"region": info.ipInfoModel.region ?: @"",
            @"country": info.ipInfoModel.country ?: @"",
            @"location": info.ipInfoModel.location ?: @"",
            @"org": info.ipInfoModel.org ?: @""
        };
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
    if (error) {
        callback(@[@{@"error": error.localizedDescription}]);
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    callback(@[jsonString ?: @"{}"]);
}


#pragma mark - Turbo Module

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeNetDiagnosisSpecJSI>(params);
}

@end
