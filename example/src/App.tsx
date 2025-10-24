import { useState, useEffect } from 'react';
import {
  Text,
  View,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  SafeAreaView,
} from 'react-native';
import NetDiagnosis, { SDKLogLevel } from 'react-native-net-diagnosis';

export default function App() {
  const [host, setHost] = useState('www.baidu.com');
  const [port, setPort] = useState('80');
  const [results, setResults] = useState<string[]>([]);
  const [networkInfo, setNetworkInfo] = useState<string>('');

  useEffect(() => {
    // 初始化SDK
    NetDiagnosis.initialize();
    NetDiagnosis.setLogLevel(SDKLogLevel.DEBUG);
    
    const version = NetDiagnosis.getSDKVersion();
    addResult(`SDK版本: ${version}`);
  }, []);

  const addResult = (text: string) => {
    setResults((prev) => [...prev, `[${new Date().toLocaleTimeString()}] ${text}`]);
  };

  const clearResults = () => {
    setResults([]);
  };

  // Ping测试
  const handlePing = () => {
    clearResults();
    addResult(`开始Ping ${host}...`);
    
    const unsubscribe = NetDiagnosis.startPing(host, 4, (result) => {
      addResult(result.result);
      if (result.isEnd) {
        addResult('Ping完成');
        unsubscribe();
      }
    });
  };

  // Traceroute测试
  const handleTraceroute = () => {
    clearResults();
    addResult(`开始Traceroute ${host}...`);
    
    const unsubscribe = NetDiagnosis.startTraceroute(host, (result) => {
      addResult(`${result.result} (目标IP: ${result.destIp})`);
      if (result.isEnd) {
        addResult('Traceroute完成');
        unsubscribe();
      }
    });
  };

  // UDP Traceroute测试
  const handleUdpTraceroute = () => {
    clearResults();
    addResult(`开始UDP Traceroute ${host}...`);
    
    const unsubscribe = NetDiagnosis.startUdpTraceroute(host, 30, (result) => {
      addResult(result.result);
    });
    
    // 30秒后自动取消订阅
    setTimeout(() => {
      unsubscribe();
      addResult('UDP Traceroute完成');
    }, 30000);
  };

  // TCP Ping测试
  const handleTcpPing = () => {
    clearResults();
    addResult(`开始TCP Ping ${host}:${port}...`);
    
    const unsubscribe = NetDiagnosis.startTcpPing(
      host,
      parseInt(port),
      4,
      (result) => {
        addResult(result.result);
        if (result.isEnd) {
          addResult('TCP Ping完成');
          unsubscribe();
        }
      }
    );
  };

  // 端口扫描测试
  const handlePortScan = () => {
    clearResults();
    
    // 示例1: 扫描常用端口
    const commonPorts = [21, 22, 23, 25, 80, 443, 3306, 8080, 8443];
    addResult(`开始扫描 ${host} 的常用端口: ${commonPorts.join(', ')}...`);
    
    // 示例2: 扫描端口范围 (取消注释以使用)
    // const ports = Array.from({ length: 31 }, (_, i) => i + 20); // 20-50
    // addResult(`开始扫描 ${host} 端口 20-50...`);
    
    const unsubscribe = NetDiagnosis.startPortScan(host, commonPorts, (result) => {
      addResult(
        `端口 ${result.port}: ${result.isOpen ? '开放' : '关闭'}${
          result.error ? ` (错误: ${result.error})` : ''
        }`
      );
    });
    
    // 10秒后停止
    setTimeout(() => {
      NetDiagnosis.stopPortScan();
      unsubscribe();
      addResult('端口扫描完成');
    }, 10000);
  };

  // 域名查询测试
  const handleLookup = async () => {
    clearResults();
    addResult(`开始查询域名 ${host}...`);
    
    try {
      const results = await NetDiagnosis.lookupDomain(host);
      results.forEach((item) => {
        addResult(`${item.name}: ${item.ip}`);
      });
      addResult('域名查询完成');
    } catch (error) {
      addResult(`错误: ${error}`);
    }
  };

  // 局域网扫描测试
  const handleLanScan = () => {
    clearResults();
    addResult('开始扫描局域网...');
    
    const unsubscribe = NetDiagnosis.startLanScan(
      (result) => {
        addResult(`发现活跃IP: ${result.ip}`);
      },
      (result) => {
        addResult(`扫描进度: ${(result.percent * 100).toFixed(1)}%`);
      },
      () => {
        addResult('局域网扫描完成');
        unsubscribe();
      }
    );
  };

  // 获取网络信息
  const handleGetNetworkInfo = async () => {
    clearResults();
    addResult('获取网络信息...');
    
    try {
      const info = await NetDiagnosis.getNetworkInfo();
      setNetworkInfo(JSON.stringify(info, null, 2));
      addResult('网络信息获取完成');
    } catch (error) {
      addResult(`错误: ${error}`);
    }
  };

  const renderButton = (title: string, onPress: () => void) => (
    <TouchableOpacity style={styles.button} onPress={onPress}>
      <Text style={styles.buttonText}>{title}</Text>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          <Text style={styles.title}>网络诊断SDK测试</Text>
          
          <View style={styles.inputContainer}>
            <Text style={styles.label}>主机:</Text>
            <TextInput
              style={styles.input}
              value={host}
              onChangeText={setHost}
              placeholder="输入IP或域名"
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.label}>端口:</Text>
            <TextInput
              style={styles.input}
              value={port}
              onChangeText={setPort}
              placeholder="输入端口"
              keyboardType="numeric"
            />
          </View>

          <View style={styles.buttonContainer}>
            {renderButton('Ping', handlePing)}
            {renderButton('Traceroute', handleTraceroute)}
            {renderButton('UDP Traceroute', handleUdpTraceroute)}
            {renderButton('TCP Ping', handleTcpPing)}
            {renderButton('端口扫描', handlePortScan)}
            {renderButton('域名查询', handleLookup)}
            {renderButton('局域网扫描', handleLanScan)}
            {renderButton('网络信息', handleGetNetworkInfo)}
            {renderButton('清空结果', clearResults)}
          </View>

          {networkInfo ? (
            <View style={styles.resultContainer}>
              <Text style={styles.resultTitle}>网络信息:</Text>
              <Text style={styles.resultText}>{networkInfo}</Text>
            </View>
          ) : null}

          <View style={styles.resultContainer}>
            <Text style={styles.resultTitle}>测试结果:</Text>
            {results.map((result, index) => (
              <Text key={index} style={styles.resultText}>
                {result}
              </Text>
            ))}
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  label: {
    width: 60,
    fontSize: 16,
    fontWeight: '500',
  },
  input: {
    flex: 1,
    height: 40,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 12,
    backgroundColor: '#fff',
  },
  buttonContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginVertical: 16,
  },
  button: {
    width: '48%',
    backgroundColor: '#007AFF',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
    marginBottom: 12,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  resultContainer: {
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 12,
    marginTop: 16,
  },
  resultTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  resultText: {
    fontSize: 12,
    fontFamily: 'Courier',
    marginBottom: 4,
    color: '#333',
  },
});
