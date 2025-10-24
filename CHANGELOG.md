# 更新日志 Changelog

## [2.0.0] - 2025-10-24

### 🚀 重大变更 Breaking Changes

#### 端口扫描API完全重构
- **旧API**: `startPortScan(host, beginPort, endPort, listener)` ❌ 已移除
- **新API**: `startPortScan(host, ports, listener)` ✅ 唯一接口

**原因**: 新API更加灵活，支持扫描不连续的端口。

**底层变化**:
- `PNPortScan` 旧接口 `portScan:beginPort:endPort:` 已完全移除
- 只保留 `portScan:ports:` 接口
- `PhoneNetManager` 内部自动适配新接口

**迁移示例**:
```typescript
// 旧代码
NetDiagnosis.startPortScan('192.168.1.1', 80, 100, callback);

// 新代码
const ports = Array.from({ length: 21 }, (_, i) => i + 80);
NetDiagnosis.startPortScan('192.168.1.1', ports, callback);
```

### ✨ 新增功能 Added

- ✅ 支持扫描不连续端口，如 `[80, 443, 8080]`
- ✅ 支持扫描端口范围，如 `[20, 21, 22, ..., 100]`
- ✅ 自动优化：连续端口使用范围扫描，不连续端口逐个扫描
- ✅ 更灵活的端口组合方式

### 🔧 优化 Improved

- 端口扫描性能优化：自动检测连续端口并使用范围扫描
- 更清晰的API设计：使用数组参数替代两个数字参数
- 更好的TypeScript类型支持

### 📚 文档 Documentation

- ✅ 更新 README.md 中的端口扫描API文档
- ✅ 更新 API_EXAMPLES.md 中的所有示例
- ✅ 添加 PORT_SCAN_UPDATE.md 详细说明文档
- ✅ 更新示例应用代码

### 🧪 测试 Testing

- ✅ TypeScript类型检查通过
- ✅ iOS编译成功
- ✅ 所有端口扫描场景测试通过

---

## [1.0.0] - 2025-10-24

### 🎉 首次发布 Initial Release

- ✅ **Ping**: 支持ICMP ping，测试网络延迟和丢包率
- ✅ **Traceroute**: 支持ICMP和UDP协议的路由追踪
- ✅ **TCP Ping**: TCP端口连通性测试
- ✅ **端口扫描**: 批量扫描主机端口状态
- ✅ **域名查询**: DNS解析，支持IPv4/IPv6
- ✅ **局域网扫描**: 扫描局域网内的活跃设备
- ✅ **网络信息**: 获取设备网络状态和IP信息
- ✅ **完整的TypeScript类型定义**
- ✅ **事件驱动架构**
- ✅ **React Native Turbo Modules支持**
- ✅ **完整的文档和示例**

### 平台支持 Platform Support

- ✅ iOS (15.1+)
- ⏳ Android (计划中)

### 文档 Documentation

- ✅ README.md - 完整使用指南
- ✅ API_EXAMPLES.md - 详细API示例
- ✅ QUICK_START.md - 快速开始指南
- ✅ VERIFICATION.md - 功能验证清单
- ✅ FIXES.md - 问题修复记录

---

## 版本说明 Version Notes

### 语义化版本控制
本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

- **主版本号(Major)**: 不兼容的API修改
- **次版本号(Minor)**: 向后兼容的功能性新增
- **修订号(Patch)**: 向后兼容的问题修正

### 支持政策
- 当前稳定版本: 2.0.0
- 最低支持版本: 1.0.0
- 旧版本支持: 建议升级到最新版本

