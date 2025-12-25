#!/usr/bin/env fish
# 停止留言管理系统

echo "🛑 正在停止服务..."

# 停止通过 PID 文件记录的后端服务
if test -f .backend.pid
    set pid (cat .backend.pid)
    if ps -p $pid > /dev/null 2>&1
        kill $pid 2>/dev/null
        echo "  ✓ 后端服务已停止 (PID: $pid)"
    end
    rm -f .backend.pid
end

# 停止所有相关进程
set backend_pids (pgrep -f "python main.py")
if test -n "$backend_pids"
    for pid in $backend_pids
        kill $pid 2>/dev/null
        echo "  ✓ 后端进程已停止 (PID: $pid)"
    end
end

set frontend_pids (pgrep -f "python -m http.server 8080")
if test -n "$frontend_pids"
    for pid in $frontend_pids
        kill $pid 2>/dev/null
        echo "  ✓ 前端进程已停止 (PID: $pid)"
    end
end

echo "✅ 所有服务已停止"
