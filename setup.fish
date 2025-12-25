#!/usr/bin/env fish
# 设置脚本 - Fish Shell 版本

echo "🚀 开始设置留言板项目..."
echo ""

# 1. 创建虚拟环境
echo "📦 步骤 1: 创建虚拟环境..."
if not test -d .venv
    python3 -m venv .venv
    echo "✓ 虚拟环境创建完成"
else
    echo "✓ 虚拟环境已存在，跳过创建"
end
echo ""

# 2. 激活虚拟环境并安装依赖
echo "📥 步骤 2: 安装依赖包..."
source .venv/bin/activate.fish
pip install -r requirements.txt
echo "✓ 依赖包安装完成"
echo ""


# 3. 完成
echo "✅ 设置完成！"
echo ""
echo "🎯 下一步操作："
echo "1. 激活虚拟环境: source .venv/bin/activate.fish"
echo "2. 运行应用: python main.py"
echo "3. 访问: http://localhost:8000"
echo ""
