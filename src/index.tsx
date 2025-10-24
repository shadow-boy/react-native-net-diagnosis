import { NativeEventEmitter, NativeModules, Platform } from 'react-native';
import NativeNetDiagnosis, {
  SDKLogLevel,
  type DomainLookupResult,
  type NetworkInfo,
} from './NativeNetDiagnosis';

// 导出类型
export { SDKLogLevel };
export type { DomainLookupResult, NetworkInfo };

// 事件类型定义
export interface PingResult {
  result: string;
  isEnd: boolean;
}

export interface TracerouteResult {
  result: string;
  destIp: string;
  isEnd: boolean;
}

export interface UdpTracerouteResult {
  result: string;
}

export interface TcpPingResult {
  result: string;
  isEnd: boolean;
}

export interface PortScanResult {
  port: string;
  isOpen: boolean;
  error?: string;
}

export interface LanScanActiveIpResult {
  ip: string;
}

export interface LanScanProgressResult {
  percent: number;
}

// 事件监听器类型
export type PingResultListener = (result: PingResult) => void;
export type TracerouteResultListener = (result: TracerouteResult) => void;
export type UdpTracerouteResultListener = (
  result: UdpTracerouteResult
) => void;
export type TcpPingResultListener = (result: TcpPingResult) => void;
export type PortScanResultListener = (result: PortScanResult) => void;
export type LanScanActiveIpListener = (result: LanScanActiveIpResult) => void;
export type LanScanProgressListener = (result: LanScanProgressResult) => void;
export type LanScanFinishedListener = () => void;

// 创建事件发射器
const eventEmitter =
  Platform.OS === 'ios'
    ? new NativeEventEmitter(NativeModules.NetDiagnosis)
    : null;

/**
 * 网络诊断SDK
 */
class NetDiagnosisSDK {
  /**
   * 初始化SDK
   */
  initialize(): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.initialize();
    }
  }

  /**
   * 设置日志级别
   * @param level SDK日志级别
   */
  setLogLevel(level: SDKLogLevel): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.setLogLevel(level);
    }
  }

  /**
   * 获取SDK版本
   * @returns SDK版本号
   */
  getSDKVersion(): string {
    if (Platform.OS === 'ios') {
      return NativeNetDiagnosis.getSDKVersion();
    }
    return 'N/A';
  }

  // ==================== Ping ====================

  /**
   * 开始ping
   * @param host IP地址或域名
   * @param count ping包数量
   * @param listener 结果监听器
   * @returns 取消订阅函数
   */
  startPing(
    host: string,
    count: number,
    listener: PingResultListener
  ): () => void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.startPing(host, count);
      const subscription = eventEmitter?.addListener(
        'onPingResult',
        listener as any
      );
      return () => subscription?.remove();
    }
    return () => {};
  }

  /**
   * 停止ping
   */
  stopPing(): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.stopPing();
    }
  }

  /**
   * 是否正在ping
   * @returns true表示正在ping
   */
  isPinging(): boolean {
    if (Platform.OS === 'ios') {
      return NativeNetDiagnosis.isPinging();
    }
    return false;
  }

  // ==================== Traceroute (ICMP) ====================

  /**
   * 开始traceroute（ICMP协议）
   * @param host IP地址或域名
   * @param listener 结果监听器
   * @returns 取消订阅函数
   */
  startTraceroute(
    host: string,
    listener: TracerouteResultListener
  ): () => void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.startTraceroute(host);
      const subscription = eventEmitter?.addListener(
        'onTracerouteResult',
        listener as any
      );
      return () => subscription?.remove();
    }
    return () => {};
  }

  /**
   * 停止traceroute
   */
  stopTraceroute(): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.stopTraceroute();
    }
  }

  /**
   * 是否正在traceroute
   * @returns true表示正在traceroute
   */
  isTracerouting(): boolean {
    if (Platform.OS === 'ios') {
      return NativeNetDiagnosis.isTracerouting();
    }
    return false;
  }

  // ==================== UDP Traceroute ====================

  /**
   * 开始UDP traceroute
   * @param host IP地址或域名
   * @param maxTtl 最大TTL值，默认30
   * @param listener 结果监听器
   * @returns 取消订阅函数
   */
  startUdpTraceroute(
    host: string,
    maxTtl: number = 30,
    listener: UdpTracerouteResultListener
  ): () => void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.startUdpTraceroute(host, maxTtl);
      const subscription = eventEmitter?.addListener(
        'onUdpTracerouteResult',
        listener as any
      );
      return () => subscription?.remove();
    }
    return () => {};
  }

  /**
   * 停止UDP traceroute
   */
  stopUdpTraceroute(): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.stopUdpTraceroute();
    }
  }

  /**
   * 是否正在UDP traceroute
   * @returns true表示正在UDP traceroute
   */
  isUdpTracerouting(): boolean {
    if (Platform.OS === 'ios') {
      return NativeNetDiagnosis.isUdpTracerouting();
    }
    return false;
  }

  // ==================== TCP Ping ====================

  /**
   * 开始TCP ping
   * @param host IP地址或域名
   * @param port 端口号，默认80
   * @param count ping次数
   * @param listener 结果监听器
   * @returns 取消订阅函数
   */
  startTcpPing(
    host: string,
    port: number = 80,
    count: number = 4,
    listener: TcpPingResultListener
  ): () => void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.startTcpPing(host, port, count);
      const subscription = eventEmitter?.addListener(
        'onTcpPingResult',
        listener as any
      );
      return () => subscription?.remove();
    }
    return () => {};
  }

  /**
   * 停止TCP ping
   */
  stopTcpPing(): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.stopTcpPing();
    }
  }

  /**
   * 是否正在TCP ping
   * @returns true表示正在TCP ping
   */
  isTcpPinging(): boolean {
    if (Platform.OS === 'ios') {
      return NativeNetDiagnosis.isTcpPinging();
    }
    return false;
  }

  // ==================== Port Scan ====================

  /**
   * 开始端口扫描
   * @param host 主机地址
   * @param beginPort 起始端口
   * @param endPort 结束端口
   * @param listener 结果监听器
   * @returns 取消订阅函数
   */
  startPortScan(
    host: string,
    beginPort: number,
    endPort: number,
    listener: PortScanResultListener
  ): () => void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.startPortScan(host, beginPort, endPort);
      const subscription = eventEmitter?.addListener(
        'onPortScanResult',
        listener as any
      );
      return () => subscription?.remove();
    }
    return () => {};
  }

  /**
   * 停止端口扫描
   */
  stopPortScan(): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.stopPortScan();
    }
  }

  /**
   * 是否正在端口扫描
   * @returns true表示正在端口扫描
   */
  isPortScanning(): boolean {
    if (Platform.OS === 'ios') {
      return NativeNetDiagnosis.isPortScanning();
    }
    return false;
  }

  // ==================== Domain Lookup ====================

  /**
   * 域名查询
   * @param domain 域名
   * @returns Promise<DomainLookupResult[]> 查询结果
   */
  async lookupDomain(domain: string): Promise<DomainLookupResult[]> {
    if (Platform.OS === 'ios') {
      return new Promise((resolve, reject) => {
        NativeNetDiagnosis.lookupDomain(domain, (jsonString: string) => {
          try {
            const results = JSON.parse(jsonString);
            if (results.error) {
              reject(new Error(results.error));
            } else {
              resolve(results);
            }
          } catch (error) {
            reject(error);
          }
        });
      });
    }
    return Promise.reject(new Error('Platform not supported'));
  }

  // ==================== LAN Scan ====================

  /**
   * 开始局域网扫描
   * @param onActiveIp 发现活跃IP时的回调
   * @param onProgress 扫描进度回调
   * @param onFinished 扫描完成回调
   * @returns 取消订阅函数
   */
  startLanScan(
    onActiveIp: LanScanActiveIpListener,
    onProgress?: LanScanProgressListener,
    onFinished?: LanScanFinishedListener
  ): () => void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.startLanScan();

      const subscriptions = [
        eventEmitter?.addListener('onLanScanActiveIp', onActiveIp as any),
      ];

      if (onProgress) {
        subscriptions.push(
          eventEmitter?.addListener('onLanScanProgress', onProgress as any)
        );
      }

      if (onFinished) {
        subscriptions.push(
          eventEmitter?.addListener('onLanScanFinished', onFinished as any)
        );
      }

      return () => {
        subscriptions.forEach((sub) => sub?.remove());
      };
    }
    return () => {};
  }

  /**
   * 停止局域网扫描
   */
  stopLanScan(): void {
    if (Platform.OS === 'ios') {
      NativeNetDiagnosis.stopLanScan();
    }
  }

  /**
   * 是否正在局域网扫描
   * @returns true表示正在扫描
   */
  isLanScanning(): boolean {
    if (Platform.OS === 'ios') {
      return NativeNetDiagnosis.isLanScanning();
    }
    return false;
  }

  // ==================== Network Info ====================

  /**
   * 获取网络信息
   * @returns Promise<NetworkInfo> 网络信息
   */
  async getNetworkInfo(): Promise<NetworkInfo> {
    if (Platform.OS === 'ios') {
      return new Promise((resolve, reject) => {
        NativeNetDiagnosis.getNetworkInfo((jsonString: string) => {
          try {
            const info = JSON.parse(jsonString);
            if (info.error) {
              reject(new Error(info.error));
            } else {
              resolve(info);
            }
          } catch (error) {
            reject(error);
          }
        });
      });
    }
    return Promise.reject(new Error('Platform not supported'));
  }
}

// 导出单例
export default new NetDiagnosisSDK();
