#!/usr/bin/env fish
# 后台启动留言管理系统（守护进程模式）

echo "🚀 启动留言管理系统（后台模式）..."
echo ""

# 检查虚拟环境
if not test -d .venv
    echo "❌ 虚拟环境不存在，请先运行 setup.fish"
    exit 1
end

# 激活虚拟环境
source .venv/bin/activate.fish

# 检查数据库
if not test -f comments.db
    echo "⚠️  数据库不存在，正在初始化..."
    python init_db.py
    echo ""
end

# 清理旧进程
echo "📦 清理旧进程..."
pkill -f "python main.py" 2>/dev/null
pkill -f "python -m http.server 8080" 2>/dev/null
sleep 1

# 启动后端服务（后台运行）
echo "🔧 启动后端服务..."
nohup python main.py > backend.log 2>&1 &
set backend_pid $last_pid
echo $backend_pid > .backend.pid
echo "  后端 PID: $backend_pid"

# 等待服务启动
sleep 2

# 启动前端服务（后台运行）
echo "🌐 启动前端服务..."
nohup python -m http.server 8080 > frontend.log 2>&1 &
set frontend_pid $last_pid
echo $frontend_pid > .frontend.pid
echo "  前端 PID: $frontend_pid"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 系统已在后台启动！"
echo ""
echo "📍 后端 API: http://localhost:8000"
echo "📍 管理后台: http://localhost:8080/admin.html"
echo "📍 API 文档: http://localhost:8000/docs"
echo ""
echo "📊 日志文件:"
echo "   后端日志: backend.log"
echo "   前端日志: frontend.log"
echo ""
echo "🛑 停止服务: ./stop.fish"
echo "📋 查看状态: ./status.fish"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 现在可以安全关闭此终端窗口，服务将继续运行"
