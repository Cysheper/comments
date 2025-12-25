#!/usr/bin/env fish
# 启动留言管理系统

echo "🚀 启动留言管理系统..."
echo ""

# 检查虚拟环境
if not test -d .venv
    echo "❌ 虚拟环境不存在，请先运行 setup.fish"
    exit 1
end

# 激活虚拟环境
echo "📦 激活虚拟环境..."
source .venv/bin/activate.fish

# 检查数据库
if not test -f comments.db
    echo "⚠️  数据库不存在，正在初始化..."
    python init_db.py
    echo ""
end

# 清理旧进程
pkill -f "python main.py" 2>/dev/null
pkill -f "python -m http.server 8080" 2>/dev/null
sleep 1

# 启动后端服务（后台运行）
echo "🔧 启动后端服务..."
python main.py > backend.log 2>&1 &
set backend_pid $last_pid
echo $backend_pid > .backend.pid

# 等待服务启动
sleep 2

echo "🌐 启动前端服务..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 系统启动成功！"
echo ""
echo "📍 后端 API: http://localhost:8000"
echo "📍 管理后台: http://localhost:8080/admin.html"
echo "📍 API 文档: http://localhost:8000/docs"
echo ""
echo "⚠️  停止服务："
echo "   方法1: 按 Ctrl+C 然后运行: ./stop.fish"
echo "   方法2: 新终端运行: ./stop.fish"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 使用 trap 捕获 SIGINT (Ctrl+C)
function handle_sigint --on-signal SIGINT
    echo ""
    echo "🛑 正在停止服务..."
    if test -f .backend.pid
        kill (cat .backend.pid) 2>/dev/null
    end
    pkill -f "python main.py" 2>/dev/null
    pkill -f "python -m http.server 8080" 2>/dev/null
    rm -f .backend.pid
    echo "✅ 服务已停止"
    exit 0
end

# 启动前端服务（前台运行）
python -m http.server 8080
