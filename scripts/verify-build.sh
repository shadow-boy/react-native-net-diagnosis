#!/bin/bash

# 验证构建脚本
# 用于快速检查项目的编译和类型检查状态

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "======================================"
echo "   React Native Net Diagnosis"
echo "   Build Verification Script"
echo "======================================"
echo ""

# 检查当前目录
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: Must run from project root${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Step 1: TypeScript Type Check${NC}"
echo "Running: yarn typecheck"
if yarn typecheck; then
    echo -e "${GREEN}✅ TypeScript type check passed${NC}"
else
    echo -e "${RED}❌ TypeScript type check failed${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}📋 Step 2: Lint Check${NC}"
echo "Running: yarn lint"
if yarn lint; then
    echo -e "${GREEN}✅ Lint check passed${NC}"
else
    echo -e "${YELLOW}⚠️  Lint check had warnings (non-fatal)${NC}"
fi
echo ""

echo -e "${YELLOW}📋 Step 3: iOS Build Check${NC}"
echo "Checking if Pods are installed..."
if [ ! -d "example/ios/Pods" ]; then
    echo -e "${YELLOW}⚠️  Pods not installed, installing now...${NC}"
    cd example/ios
    export LANG=en_US.UTF-8
    pod install
    cd ../..
else
    echo -e "${GREEN}✅ Pods already installed${NC}"
fi
echo ""

echo -e "${YELLOW}📋 Step 4: Building iOS Project${NC}"
echo "This may take a few minutes..."
cd example/ios
if xcodebuild -workspace NetDiagnosisExample.xcworkspace \
               -scheme NetDiagnosisExample \
               -configuration Debug \
               -sdk iphonesimulator \
               -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
               build \
               CODE_SIGNING_ALLOWED=NO \
               > /tmp/xcodebuild.log 2>&1; then
    echo -e "${GREEN}✅ iOS build succeeded${NC}"
else
    echo -e "${RED}❌ iOS build failed${NC}"
    echo "Last 50 lines of build log:"
    tail -50 /tmp/xcodebuild.log
    exit 1
fi
cd ../..
echo ""

echo "======================================"
echo -e "${GREEN}✅ All verifications passed!${NC}"
echo "======================================"
echo ""
echo "Your project is ready to use!"
echo ""
echo "To run the example app:"
echo "  cd example"
echo "  yarn ios"
echo ""
echo "To run on a specific simulator:"
echo "  cd example"
echo "  yarn ios --simulator=\"iPhone 16 Pro\""
echo ""
echo "For more information, see:"
echo "  - README.md"
echo "  - QUICK_START.md"
echo "  - API_EXAMPLES.md"
echo ""

