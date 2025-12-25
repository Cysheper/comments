#!/usr/bin/env fish
# 查看留言管理系统状态

echo "📊 留言管理系统运行状态"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查后端服务
set backend_running false
if test -f .backend.pid
    set pid (cat .backend.pid)
    if ps -p $pid > /dev/null 2>&1
        echo "✅ 后端服务: 运行中 (PID: $pid)"
        set backend_running true
    else
        echo "❌ 后端服务: 已停止 (PID 文件存在但进程不存在)"
    end
else
    # 尝试查找进程
    set pids (pgrep -f "python main.py")
    if test -n "$pids"
        echo "⚠️  后端服务: 运行中但无 PID 文件"
        for pid in $pids
            echo "   进程 PID: $pid"
        end
        set backend_running true
    else
        echo "❌ 后端服务: 未运行"
    end
end

# 检查前端服务
set frontend_running false
if test -f .frontend.pid
    set pid (cat .frontend.pid)
    if ps -p $pid > /dev/null 2>&1
        echo "✅ 前端服务: 运行中 (PID: $pid)"
        set frontend_running true
    else
        echo "❌ 前端服务: 已停止 (PID 文件存在但进程不存在)"
    end
else
    # 尝试查找进程
    set pids (pgrep -f "python -m http.server 8080")
    if test -n "$pids"
        echo "⚠️  前端服务: 运行中但无 PID 文件"
        for pid in $pids
            echo "   进程 PID: $pid"
        end
        set frontend_running true
    else
        echo "❌ 前端服务: 未运行"
    end
end

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 测试服务连接
if $backend_running
    echo ""
    echo "🔗 测试后端连接..."
    if curl -s http://localhost:8000/get_comments > /dev/null
        echo "✅ 后端 API 可访问: http://localhost:8000"
    else
        echo "❌ 后端 API 无法访问: http://localhost:8000"
    end
end

if $frontend_running
    echo ""
    echo "🔗 测试前端连接..."
    if curl -s http://localhost:8080 > /dev/null
        echo "✅ 管理后台可访问: http://localhost:8080/admin.html"
    else
        echo "❌ 管理后台无法访问: http://localhost:8080"
    end
end

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 显示日志文件信息
if test -f backend.log
    echo ""
    echo "📄 后端日志 (最后 5 行):"
    tail -5 backend.log
end

if test -f frontend.log
    echo ""
    echo "📄 前端日志 (最后 5 行):"
    tail -5 frontend.log
end

echo ""
