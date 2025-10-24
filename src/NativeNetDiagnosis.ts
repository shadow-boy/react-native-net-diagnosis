import { TurboModuleRegistry, type TurboModule } from 'react-native';

// 网络信息类型定义
export interface DeviceNetInfo {
  netType: string;
  wifiSSID: string;
  wifiBSSID: string;
  wifiIPV4: string;
  wifiNetmask: string;
  wifiIPV6: string;
  cellIPV4: string;
}

export interface IpInfoModel {
  ip: string;
  city: string;
  region: string;
  country: string;
  location: string;
  org: string;
}

export interface NetworkInfo {
  deviceNetInfo: DeviceNetInfo;
  ipInfoModel: IpInfoModel;
}

// 域名查询结果
export interface DomainLookupResult {
  name: string;
  ip: string;
}

// SDK日志级别
export enum SDKLogLevel {
  FATAL = 0,
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  DEBUG = 4,
}

export interface Spec extends TurboModule {
  // SDK初始化和配置
  initialize(): void;
  setLogLevel(level: number): void;
  getSDKVersion(): string;

  // Ping功能
  startPing(host: string, count: number): void;
  stopPing(): void;
  isPinging(): boolean;

  // Traceroute功能（ICMP）
  startTraceroute(host: string): void;
  stopTraceroute(): void;
  isTracerouting(): boolean;

  // UDP Traceroute功能
  startUdpTraceroute(host: string, maxTtl: number): void;
  stopUdpTraceroute(): void;
  isUdpTracerouting(): boolean;

  // TCP Ping功能
  startTcpPing(host: string, port: number, count: number): void;
  stopTcpPing(): void;
  isTcpPinging(): boolean;

  // 端口扫描功能
  startPortScan(host: string, beginPort: number, endPort: number): void;
  stopPortScan(): void;
  isPortScanning(): boolean;

  // 域名查询功能
  lookupDomain(domain: string, callback: (results: string) => void): void;

  // 局域网扫描功能
  startLanScan(): void;
  stopLanScan(): void;
  isLanScanning(): boolean;

  // 获取网络信息
  getNetworkInfo(callback: (info: string) => void): void;

  // 事件监听器
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NetDiagnosis');
