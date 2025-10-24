#!/bin/bash

# 清理iOS编译缓存和重新安装pods

echo "🧹 清理iOS缓存..."

# 进入example目录
cd "$(dirname "$0")/../example" || exit

# 清理iOS构建产物
echo "清理iOS build文件夹..."
rm -rf ios/build
rm -rf ios/Pods
rm -rf ios/Podfile.lock

# 清理派生数据
echo "清理Xcode派生数据..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*NetDiagnosis*

# 重新安装pods
echo "📦 重新安装pods..."
cd ios || exit
pod deintegrate
pod install

echo "✅ 清理完成！"
echo ""
echo "现在你可以运行以下命令来启动应用："
echo "cd example && yarn ios"

