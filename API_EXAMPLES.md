# API使用示例 API Usage Examples

本文档提供了react-native-net-diagnosis库的详细使用示例。

## 目录

- [基础设置](#基础设置)
- [Ping测试](#ping测试)
- [Traceroute测试](#traceroute测试)
- [TCP Ping测试](#tcp-ping测试)
- [端口扫描](#端口扫描)
- [域名查询](#域名查询)
- [局域网扫描](#局域网扫描)
- [网络信息](#网络信息)
- [完整示例](#完整示例)

## 基础设置

在使用任何功能之前，必须先初始化SDK：

```typescript
import NetDiagnosis, { SDKLogLevel } from 'react-native-net-diagnosis';

// 初始化SDK
NetDiagnosis.initialize();

// 设置日志级别（可选，开发时推荐使用DEBUG）
NetDiagnosis.setLogLevel(SDKLogLevel.DEBUG);

// 获取SDK版本
const version = NetDiagnosis.getSDKVersion();
console.log('SDK版本:', version);
```

## Ping测试

### 基础Ping

```typescript
// 对百度进行4次ping
const unsubscribe = NetDiagnosis.startPing('www.baidu.com', 4, (result) => {
  console.log(result.result);
  
  if (result.isEnd) {
    console.log('Ping完成');
    unsubscribe(); // 清理监听器
  }
});
```

### Ping IP地址

```typescript
// Ping Google DNS
NetDiagnosis.startPing('8.8.8.8', 10, (result) => {
  if (!result.isEnd) {
    console.log('Ping结果:', result.result);
  } else {
    console.log('统计信息:', result.result);
  }
});
```

### 手动停止Ping

```typescript
const unsubscribe = NetDiagnosis.startPing('www.google.com', 100, (result) => {
  console.log(result.result);
});

// 3秒后停止
setTimeout(() => {
  NetDiagnosis.stopPing();
  unsubscribe();
}, 3000);
```

### 检查Ping状态

```typescript
if (NetDiagnosis.isPinging()) {
  console.log('正在进行Ping测试');
} else {
  console.log('没有正在进行的Ping测试');
}
```

## Traceroute测试

### ICMP Traceroute

```typescript
const unsubscribe = NetDiagnosis.startTraceroute('www.google.com', (result) => {
  console.log('跳数结果:', result.result);
  console.log('目标IP:', result.destIp);
  
  if (result.isEnd) {
    console.log('Traceroute完成');
    unsubscribe();
  }
});
```

### UDP Traceroute

```typescript
// 使用默认TTL（30）
const unsubscribe1 = NetDiagnosis.startUdpTraceroute('www.baidu.com', 30, (result) => {
  console.log('UDP Traceroute:', result.result);
});

// 自定义最大TTL
const unsubscribe2 = NetDiagnosis.startUdpTraceroute('8.8.8.8', 20, (result) => {
  console.log('UDP Traceroute:', result.result);
});

// 30秒后停止
setTimeout(() => {
  NetDiagnosis.stopUdpTraceroute();
  unsubscribe1();
  unsubscribe2();
}, 30000);
```

### 比较ICMP和UDP Traceroute

```typescript
const host = 'www.google.com';

console.log('开始ICMP Traceroute...');
const icmpUnsubscribe = NetDiagnosis.startTraceroute(host, (result) => {
  console.log('[ICMP]', result.result);
  if (result.isEnd) {
    console.log('ICMP Traceroute完成');
    
    // ICMP完成后开始UDP
    console.log('开始UDP Traceroute...');
    const udpUnsubscribe = NetDiagnosis.startUdpTraceroute(host, 30, (result) => {
      console.log('[UDP]', result.result);
    });
    
    setTimeout(() => {
      udpUnsubscribe();
      console.log('UDP Traceroute完成');
    }, 30000);
  }
});
```

## TCP Ping测试

### 测试HTTP端口

```typescript
const unsubscribe = NetDiagnosis.startTcpPing('www.baidu.com', 80, 4, (result) => {
  console.log('TCP Ping结果:', result.result);
  
  if (result.isEnd) {
    console.log('TCP Ping完成');
    unsubscribe();
  }
});
```

### 测试HTTPS端口

```typescript
const unsubscribe = NetDiagnosis.startTcpPing('www.google.com', 443, 5, (result) => {
  console.log(result.result);
  if (result.isEnd) {
    unsubscribe();
  }
});
```

### 测试SSH端口

```typescript
NetDiagnosis.startTcpPing('192.168.1.1', 22, 3, (result) => {
  if (result.isEnd) {
    console.log('SSH端口测试完成:', result.result);
  } else {
    console.log('测试中...', result.result);
  }
});
```

### 批量测试多个端口

```typescript
const host = 'example.com';
const ports = [80, 443, 22, 3306, 5432];

ports.forEach(port => {
  NetDiagnosis.startTcpPing(host, port, 1, (result) => {
    if (result.isEnd) {
      console.log(`端口 ${port}:`, result.result);
    }
  });
});
```

## 端口扫描

### 扫描常用端口

```typescript
const unsubscribe = NetDiagnosis.startPortScan('192.168.1.1', 80, 85, (result) => {
  if (result.isOpen) {
    console.log(`✅ 端口 ${result.port} 开放`);
  } else {
    console.log(`❌ 端口 ${result.port} 关闭`);
  }
  
  if (result.error) {
    console.error(`错误: ${result.error}`);
  }
});

// 10秒后停止扫描
setTimeout(() => {
  NetDiagnosis.stopPortScan();
  unsubscribe();
}, 10000);
```

### 扫描Web服务端口

```typescript
const host = 'example.com';
const webPorts = { start: 80, end: 85 }; // 80, 81, 82, 83, 84, 85

const openPorts: string[] = [];

const unsubscribe = NetDiagnosis.startPortScan(
  host,
  webPorts.start,
  webPorts.end,
  (result) => {
    if (result.isOpen) {
      openPorts.push(result.port);
    }
  }
);

// 扫描完成后显示结果
setTimeout(() => {
  NetDiagnosis.stopPortScan();
  unsubscribe();
  console.log('开放的端口:', openPorts);
}, 15000);
```

### 扫描数据库端口

```typescript
const host = '192.168.1.100';

// MySQL, PostgreSQL, MongoDB, Redis
const dbPorts = [3306, 5432, 27017, 6379];

dbPorts.forEach(port => {
  NetDiagnosis.startPortScan(host, port, port, (result) => {
    console.log(`数据库端口 ${result.port}:`, result.isOpen ? '开放' : '关闭');
  });
});
```

## 域名查询

### 基础域名查询

```typescript
try {
  const results = await NetDiagnosis.lookupDomain('www.baidu.com');
  console.log('查询结果:');
  results.forEach(item => {
    console.log(`  ${item.name} -> ${item.ip}`);
  });
} catch (error) {
  console.error('域名查询失败:', error);
}
```

### 批量域名查询

```typescript
const domains = ['www.google.com', 'www.baidu.com', 'www.github.com'];

async function lookupMultipleDomains() {
  for (const domain of domains) {
    try {
      const results = await NetDiagnosis.lookupDomain(domain);
      console.log(`\n${domain}:`);
      results.forEach(item => {
        console.log(`  ${item.ip}`);
      });
    } catch (error) {
      console.error(`查询 ${domain} 失败:`, error);
    }
  }
}

lookupMultipleDomains();
```

### 查询并Ping

```typescript
async function lookupAndPing(domain: string) {
  try {
    // 先查询域名
    const results = await NetDiagnosis.lookupDomain(domain);
    console.log('域名解析结果:');
    results.forEach(item => {
      console.log(`  ${item.name} -> ${item.ip}`);
    });
    
    // 对第一个IP进行ping
    if (results.length > 0) {
      const ip = results[0].ip;
      console.log(`\n开始Ping ${ip}...`);
      
      NetDiagnosis.startPing(ip, 4, (result) => {
        console.log(result.result);
      });
    }
  } catch (error) {
    console.error('操作失败:', error);
  }
}

lookupAndPing('www.google.com');
```

## 局域网扫描

### 基础局域网扫描

```typescript
const activeIPs: string[] = [];

const unsubscribe = NetDiagnosis.startLanScan(
  // 发现活跃IP
  (result) => {
    console.log('发现活跃设备:', result.ip);
    activeIPs.push(result.ip);
  },
  // 扫描进度
  (result) => {
    const progress = (result.percent * 100).toFixed(1);
    console.log(`扫描进度: ${progress}%`);
  },
  // 扫描完成
  () => {
    console.log('扫描完成！');
    console.log(`共发现 ${activeIPs.length} 个活跃设备:`);
    activeIPs.forEach(ip => console.log(`  - ${ip}`));
    unsubscribe();
  }
);
```

### 扫描并获取设备信息

```typescript
interface DeviceInfo {
  ip: string;
  ports: number[];
}

const devices: DeviceInfo[] = [];

const unsubscribe = NetDiagnosis.startLanScan(
  async (result) => {
    const ip = result.ip;
    console.log(`正在检查设备: ${ip}`);
    
    // 检查常用端口
    const openPorts: number[] = [];
    const commonPorts = [22, 80, 443, 8080];
    
    for (const port of commonPorts) {
      // 这里可以使用TCP ping检查端口
      // 简化示例，实际使用时需要添加延迟和错误处理
    }
    
    devices.push({ ip, ports: openPorts });
  },
  (result) => {
    console.log(`进度: ${(result.percent * 100).toFixed(0)}%`);
  },
  () => {
    console.log('\n扫描完成！');
    console.log('设备列表:');
    devices.forEach(device => {
      console.log(`  ${device.ip} - 开放端口: ${device.ports.join(', ')}`);
    });
    unsubscribe();
  }
);
```

### 停止局域网扫描

```typescript
const unsubscribe = NetDiagnosis.startLanScan(
  (result) => console.log('发现IP:', result.ip),
  (result) => console.log('进度:', result.percent)
);

// 30秒后停止
setTimeout(() => {
  console.log('手动停止扫描');
  NetDiagnosis.stopLanScan();
  unsubscribe();
}, 30000);
```

## 网络信息

### 获取基础网络信息

```typescript
try {
  const info = await NetDiagnosis.getNetworkInfo();
  
  console.log('=== 设备网络信息 ===');
  console.log('网络类型:', info.deviceNetInfo.netType);
  console.log('WiFi SSID:', info.deviceNetInfo.wifiSSID);
  console.log('WiFi BSSID:', info.deviceNetInfo.wifiBSSID);
  console.log('WiFi IPv4:', info.deviceNetInfo.wifiIPV4);
  console.log('WiFi IPv6:', info.deviceNetInfo.wifiIPV6);
  console.log('子网掩码:', info.deviceNetInfo.wifiNetmask);
  console.log('蜂窝IP:', info.deviceNetInfo.cellIPV4);
  
  console.log('\n=== 公网信息 ===');
  console.log('公网IP:', info.ipInfoModel.ip);
  console.log('城市:', info.ipInfoModel.city);
  console.log('地区:', info.ipInfoModel.region);
  console.log('国家:', info.ipInfoModel.country);
  console.log('位置:', info.ipInfoModel.location);
  console.log('运营商:', info.ipInfoModel.org);
} catch (error) {
  console.error('获取网络信息失败:', error);
}
```

### 网络状态监控

```typescript
async function monitorNetwork() {
  const checkInterval = 5000; // 5秒检查一次
  
  setInterval(async () => {
    try {
      const info = await NetDiagnosis.getNetworkInfo();
      console.log(`[${new Date().toLocaleTimeString()}]`);
      console.log(`  网络类型: ${info.deviceNetInfo.netType}`);
      console.log(`  本地IP: ${info.deviceNetInfo.wifiIPV4 || info.deviceNetInfo.cellIPV4}`);
      console.log(`  公网IP: ${info.ipInfoModel.ip}`);
    } catch (error) {
      console.error('网络检查失败:', error);
    }
  }, checkInterval);
}

monitorNetwork();
```

## 完整示例

### 网络诊断工具

```typescript
import NetDiagnosis, { SDKLogLevel } from 'react-native-net-diagnosis';

class NetworkDiagnosticTool {
  constructor() {
    NetDiagnosis.initialize();
    NetDiagnosis.setLogLevel(SDKLogLevel.INFO);
  }
  
  // 完整的主机诊断
  async diagnoseHost(host: string) {
    console.log(`\n===== 开始诊断 ${host} =====\n`);
    
    // 1. 域名查询
    console.log('1. 域名解析...');
    try {
      const lookupResults = await NetDiagnosis.lookupDomain(host);
      lookupResults.forEach(item => {
        console.log(`   ${item.name} -> ${item.ip}`);
      });
    } catch (error) {
      console.error('   域名解析失败:', error);
      return;
    }
    
    // 2. Ping测试
    console.log('\n2. Ping测试...');
    await new Promise((resolve) => {
      NetDiagnosis.startPing(host, 4, (result) => {
        console.log('   ', result.result);
        if (result.isEnd) {
          resolve(null);
        }
      });
    });
    
    // 3. Traceroute
    console.log('\n3. Traceroute...');
    await new Promise((resolve) => {
      NetDiagnosis.startTraceroute(host, (result) => {
        console.log('   ', result.result);
        if (result.isEnd) {
          resolve(null);
        }
      });
    });
    
    // 4. 端口检测
    console.log('\n4. 端口检测...');
    await new Promise((resolve) => {
      const ports = [80, 443];
      let checked = 0;
      
      ports.forEach(port => {
        NetDiagnosis.startTcpPing(host, port, 1, (result) => {
          if (result.isEnd) {
            console.log(`   端口 ${port}:`, result.result);
            checked++;
            if (checked === ports.length) {
              resolve(null);
            }
          }
        });
      });
    });
    
    console.log('\n===== 诊断完成 =====\n');
  }
  
  // 网络质量测试
  async testNetworkQuality() {
    console.log('\n===== 网络质量测试 =====\n');
    
    const testHosts = [
      { name: '百度', host: 'www.baidu.com' },
      { name: 'Google', host: 'www.google.com' },
      { name: '腾讯', host: 'www.qq.com' }
    ];
    
    for (const { name, host } of testHosts) {
      console.log(`\n测试 ${name} (${host})...`);
      
      await new Promise((resolve) => {
        NetDiagnosis.startPing(host, 3, (result) => {
          if (result.isEnd) {
            console.log(result.result);
            resolve(null);
          }
        });
      });
    }
    
    console.log('\n===== 测试完成 =====\n');
  }
  
  // 局域网分析
  async analyzeLAN() {
    console.log('\n===== 局域网分析 =====\n');
    
    // 获取当前网络信息
    try {
      const info = await NetDiagnosis.getNetworkInfo();
      console.log('当前WiFi:', info.deviceNetInfo.wifiSSID);
      console.log('本地IP:', info.deviceNetInfo.wifiIPV4);
      console.log('子网掩码:', info.deviceNetInfo.wifiNetmask);
    } catch (error) {
      console.error('获取网络信息失败:', error);
      return;
    }
    
    // 扫描局域网
    console.log('\n开始扫描局域网设备...');
    return new Promise((resolve) => {
      const devices: string[] = [];
      
      NetDiagnosis.startLanScan(
        (result) => {
          devices.push(result.ip);
          console.log(`发现设备: ${result.ip}`);
        },
        (result) => {
          const progress = (result.percent * 100).toFixed(0);
          console.log(`扫描进度: ${progress}%`);
        },
        () => {
          console.log(`\n扫描完成，共发现 ${devices.length} 个设备`);
          resolve(devices);
        }
      );
    });
  }
}

// 使用示例
const tool = new NetworkDiagnosticTool();

// 诊断特定主机
tool.diagnoseHost('www.baidu.com');

// 测试网络质量
tool.testNetworkQuality();

// 分析局域网
tool.analyzeLAN();
```

## React组件示例

```typescript
import React, { useState, useEffect } from 'react';
import { View, Text, Button } from 'react-native';
import NetDiagnosis from 'react-native-net-diagnosis';

const NetworkDiagnostic: React.FC = () => {
  const [results, setResults] = useState<string[]>([]);
  const [isRunning, setIsRunning] = useState(false);
  
  useEffect(() => {
    NetDiagnosis.initialize();
  }, []);
  
  const addResult = (text: string) => {
    setResults(prev => [...prev, `[${new Date().toLocaleTimeString()}] ${text}`]);
  };
  
  const handlePing = () => {
    setIsRunning(true);
    setResults([]);
    
    const unsubscribe = NetDiagnosis.startPing('www.baidu.com', 4, (result) => {
      addResult(result.result);
      if (result.isEnd) {
        setIsRunning(false);
        unsubscribe();
      }
    });
  };
  
  return (
    <View>
      <Button 
        title="开始Ping测试" 
        onPress={handlePing}
        disabled={isRunning}
      />
      {results.map((result, index) => (
        <Text key={index}>{result}</Text>
      ))}
    </View>
  );
};

export default NetworkDiagnostic;
```

