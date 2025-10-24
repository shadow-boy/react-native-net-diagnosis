# react-native-net-diagnosis

iOS平台网络诊断SDK，支持对IP和域名的ping、traceroute（UDP、ICMP协议）、TCP ping、端口扫描、nslookup、局域网活跃IP扫描等功能。

iOS platform network diagnostic SDK, supporting ping for IPs and domains, traceroute (UDP, ICMP protocols), TCP ping, port scanning, nslookup, LAN active IP scanning and other functions.

## 功能特性 Features

- ✅ **Ping**: 支持ICMP ping，测试网络延迟和丢包率
- ✅ **Traceroute**: 支持ICMP和UDP协议的路由追踪
- ✅ **TCP Ping**: TCP端口连通性测试
- ✅ **端口扫描**: 批量扫描主机端口状态
- ✅ **域名查询**: DNS解析，支持IPv4/IPv6
- ✅ **局域网扫描**: 扫描局域网内的活跃设备
- ✅ **网络信息**: 获取设备网络状态和IP信息
- ✅ **完整的TypeScript类型定义**: 完善的类型支持
- ✅ **事件驱动**: 实时获取诊断结果

## 安装 Installation

```sh
npm install react-native-net-diagnosis
# or
yarn add react-native-net-diagnosis
```

### iOS配置

```sh
cd ios && pod install
```

## 快速开始 Quick Start

```typescript
import NetDiagnosis, { SDKLogLevel } from 'react-native-net-diagnosis';

// 1. 初始化SDK
NetDiagnosis.initialize();
NetDiagnosis.setLogLevel(SDKLogLevel.DEBUG);

// 2. Ping测试
const unsubscribe = NetDiagnosis.startPing('www.google.com', 4, (result) => {
  console.log(result.result);
  if (result.isEnd) {
    console.log('Ping完成');
    unsubscribe();
  }
});

// 3. 域名查询
const results = await NetDiagnosis.lookupDomain('www.baidu.com');
console.log(results);

// 4. 获取网络信息
const info = await NetDiagnosis.getNetworkInfo();
console.log(info);
```

## API文档 API Documentation

### 初始化 Initialization

#### `initialize()`
初始化SDK，必须在使用其他功能前调用。

```typescript
NetDiagnosis.initialize();
```

#### `setLogLevel(level: SDKLogLevel)`
设置SDK日志级别。

```typescript
enum SDKLogLevel {
  FATAL = 0,
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  DEBUG = 4,
}

NetDiagnosis.setLogLevel(SDKLogLevel.DEBUG);
```

#### `getSDKVersion(): string`
获取SDK版本号。

```typescript
const version = NetDiagnosis.getSDKVersion();
```

### Ping功能

#### `startPing(host: string, count: number, listener: PingResultListener): () => void`
开始Ping测试。

**参数:**
- `host`: IP地址或域名
- `count`: 发送的ping包数量
- `listener`: 结果回调函数

**返回:** 取消订阅函数

```typescript
const unsubscribe = NetDiagnosis.startPing('8.8.8.8', 4, (result) => {
  console.log(result.result); // ping结果字符串
  console.log(result.isEnd);  // 是否完成
});

// 取消订阅
unsubscribe();
```

#### `stopPing()`
停止Ping测试。

#### `isPinging(): boolean`
检查是否正在进行Ping测试。

### Traceroute功能（ICMP）

#### `startTraceroute(host: string, listener: TracerouteResultListener): () => void`
开始ICMP路由追踪。

```typescript
const unsubscribe = NetDiagnosis.startTraceroute('www.google.com', (result) => {
  console.log(result.result);  // 路由结果
  console.log(result.destIp);  // 目标IP
  console.log(result.isEnd);   // 是否完成
});
```

#### `stopTraceroute()`
停止路由追踪。

#### `isTracerouting(): boolean`
检查是否正在进行路由追踪。

### UDP Traceroute功能

#### `startUdpTraceroute(host: string, maxTtl: number, listener: UdpTracerouteResultListener): () => void`
开始UDP路由追踪。

**参数:**
- `host`: 目标主机
- `maxTtl`: 最大跳数，默认30
- `listener`: 结果回调

```typescript
const unsubscribe = NetDiagnosis.startUdpTraceroute('www.baidu.com', 30, (result) => {
  console.log(result.result);
});
```

#### `stopUdpTraceroute()`
停止UDP路由追踪。

#### `isUdpTracerouting(): boolean`
检查是否正在进行UDP路由追踪。

### TCP Ping功能

#### `startTcpPing(host: string, port: number, count: number, listener: TcpPingResultListener): () => void`
开始TCP Ping测试。

**参数:**
- `host`: 目标主机
- `port`: 端口号，默认80
- `count`: ping次数，默认4
- `listener`: 结果回调

```typescript
const unsubscribe = NetDiagnosis.startTcpPing('www.google.com', 443, 4, (result) => {
  console.log(result.result);
  console.log(result.isEnd);
});
```

#### `stopTcpPing()`
停止TCP Ping。

#### `isTcpPinging(): boolean`
检查是否正在进行TCP Ping。

### 端口扫描功能

#### `startPortScan(host: string, ports: number[], listener: PortScanResultListener): () => void`
开始端口扫描。支持扫描指定的端口列表，可以是不连续的端口。

**参数:**
- `host`: 目标主机
- `ports`: 要扫描的端口数组，例如 `[80, 443, 8080]` 或 `[20, 21, 22, 23, ..., 100]`
- `listener`: 结果回调

**示例1: 扫描特定端口**
```typescript
// 扫描常用端口
const commonPorts = [21, 22, 80, 443, 3306, 8080];
const unsubscribe = NetDiagnosis.startPortScan('192.168.1.1', commonPorts, (result) => {
  console.log(`端口 ${result.port}: ${result.isOpen ? '开放' : '关闭'}`);
  if (result.error) {
    console.log(`错误: ${result.error}`);
  }
});
```

**示例2: 扫描端口范围**
```typescript
// 扫描端口 80-100
const ports = Array.from({ length: 21 }, (_, i) => i + 80);
const unsubscribe = NetDiagnosis.startPortScan('192.168.1.1', ports, (result) => {
  console.log(`端口 ${result.port}: ${result.isOpen ? '开放' : '关闭'}`);
});
```

**注意事项:**
- 底层SDK会按照数组顺序逐个扫描端口
- 建议单次扫描端口数量不超过100个，大量端口建议分批扫描
- 使用 `stopPortScan()` 可以随时停止扫描

#### `stopPortScan()`
停止端口扫描。

#### `isPortScanning(): boolean`
检查是否正在进行端口扫描。

### 域名查询功能

#### `lookupDomain(domain: string): Promise<DomainLookupResult[]>`
查询域名的IP地址。

**返回:** Promise，解析为域名查询结果数组

```typescript
try {
  const results = await NetDiagnosis.lookupDomain('www.baidu.com');
  results.forEach(item => {
    console.log(`${item.name}: ${item.ip}`);
  });
} catch (error) {
  console.error('查询失败:', error);
}
```

**返回类型:**
```typescript
interface DomainLookupResult {
  name: string;  // 域名
  ip: string;    // IP地址
}
```

### 局域网扫描功能

#### `startLanScan(onActiveIp: LanScanActiveIpListener, onProgress?: LanScanProgressListener, onFinished?: LanScanFinishedListener): () => void`
开始局域网扫描。

**参数:**
- `onActiveIp`: 发现活跃IP时的回调
- `onProgress`: 扫描进度回调（可选）
- `onFinished`: 扫描完成回调（可选）

```typescript
const unsubscribe = NetDiagnosis.startLanScan(
  (result) => {
    console.log(`发现活跃IP: ${result.ip}`);
  },
  (result) => {
    console.log(`扫描进度: ${(result.percent * 100).toFixed(1)}%`);
  },
  () => {
    console.log('扫描完成');
  }
);
```

#### `stopLanScan()`
停止局域网扫描。

#### `isLanScanning(): boolean`
检查是否正在进行局域网扫描。

### 网络信息功能

#### `getNetworkInfo(): Promise<NetworkInfo>`
获取设备网络信息。

```typescript
try {
  const info = await NetDiagnosis.getNetworkInfo();
  console.log('网络类型:', info.deviceNetInfo.netType);
  console.log('WiFi SSID:', info.deviceNetInfo.wifiSSID);
  console.log('WiFi IP:', info.deviceNetInfo.wifiIPV4);
  console.log('公网IP:', info.ipInfoModel.ip);
  console.log('位置:', info.ipInfoModel.city, info.ipInfoModel.country);
} catch (error) {
  console.error('获取失败:', error);
}
```

**返回类型:**
```typescript
interface NetworkInfo {
  deviceNetInfo: {
    netType: string;      // 网络类型
    wifiSSID: string;     // WiFi名称
    wifiBSSID: string;    // WiFi MAC地址
    wifiIPV4: string;     // WiFi IPv4地址
    wifiNetmask: string;  // 子网掩码
    wifiIPV6: string;     // WiFi IPv6地址
    cellIPV4: string;     // 蜂窝网络IP
  };
  ipInfoModel: {
    ip: string;           // 公网IP
    city: string;         // 城市
    region: string;       // 地区
    country: string;      // 国家
    location: string;     // 位置坐标
    org: string;          // 运营商
  };
}
```

## 类型定义 Type Definitions

```typescript
// 日志级别
enum SDKLogLevel {
  FATAL = 0,
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  DEBUG = 4,
}

// Ping结果
interface PingResult {
  result: string;  // 结果文本
  isEnd: boolean;  // 是否结束
}

// Traceroute结果
interface TracerouteResult {
  result: string;  // 结果文本
  destIp: string;  // 目标IP
  isEnd: boolean;  // 是否结束
}

// UDP Traceroute结果
interface UdpTracerouteResult {
  result: string;  // 结果文本
}

// TCP Ping结果
interface TcpPingResult {
  result: string;  // 结果文本
  isEnd: boolean;  // 是否结束
}

// 端口扫描结果
interface PortScanResult {
  port: string;    // 端口号
  isOpen: boolean; // 是否开放
  error?: string;  // 错误信息
}

// 局域网扫描结果
interface LanScanActiveIpResult {
  ip: string;      // 活跃IP
}

interface LanScanProgressResult {
  percent: number; // 进度（0-1）
}
```

## 示例应用 Example

查看 `example` 文件夹中的完整示例应用，演示了所有功能的使用方法。

```sh
# 运行示例应用
cd example
yarn install
cd ios && pod install && cd ..
yarn ios
```

## 注意事项 Notes

1. **权限要求**: iOS需要在Info.plist中添加网络权限
2. **后台运行**: 某些诊断功能可能需要应用处于前台
3. **网络环境**: 某些功能（如局域网扫描）需要设备连接到WiFi
4. **性能影响**: 大范围端口扫描和局域网扫描会消耗较多资源

## 故障排除 Troubleshooting

### 编译错误

如果遇到编译错误，请尝试：

```sh
cd example/ios
pod deintegrate
pod install
cd ..
yarn ios
```

### 运行时错误

确保已正确初始化SDK：

```typescript
NetDiagnosis.initialize();
```

## 贡献 Contributing

欢迎贡献代码！请阅读：

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## 许可证 License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
