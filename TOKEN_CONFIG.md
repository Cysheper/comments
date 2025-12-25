# 🔐 Token 令牌配置指南

## 📋 概述

系统已添加 Token 令牌验证机制，用于保护数据库的写操作（增、删、改）。

## 🔧 配置方法

### 1. 后端配置（main.py）

在 `main.py` 文件中找到以下代码：

```python
# Token 配置 - 在生产环境中应该使用更安全的方式存储
API_TOKEN = "your-secret-token-2025"  # 可以改成你想要的 Token
```

**修改 Token：**
将 `your-secret-token-2025` 改为你自己的安全令牌，例如：
```python
API_TOKEN = "my-super-secret-token-abc123"
```

### 2. 前端配置（admin.html）

在 `admin.html` 文件的 JavaScript 部分找到：

```javascript
const API_BASE = 'https://api.cysheper.top:8000';
const API_TOKEN = 'your-secret-token-2025';  // Token 令牌，需要与后端一致
```

**修改 Token：**
将 Token 改为与后端相同的值：
```javascript
const API_TOKEN = 'my-super-secret-token-abc123';
```

⚠️ **重要：前后端的 Token 必须完全一致！**

## 🔒 安全机制

### 受保护的接口

需要 Token 验证的操作：
- ✅ `POST /post_comment` - 创建新留言
- ✅ `PUT /update_comment/{id}` - 更新留言
- ✅ `DELETE /delete_comment/{id}` - 删除留言

### 不需要 Token 的接口

- ✅ `GET /get_comments` - 获取所有留言（公开访问）

### 验证方式

Token 在 HTTP 请求头中传递：
```
Authorization: your-secret-token-2025
```

也支持 Bearer 格式：
```
Authorization: Bearer your-secret-token-2025
```

## 🧪 测试验证

### 使用 curl 测试

**1. 不带 Token（应该失败）：**
```bash
curl -X POST http://localhost:8000/post_comment \
  -H "Content-Type: application/json" \
  -d '{"username":"测试","content":"测试内容","isAnonymous":false}'
```

预期结果：
```json
{"detail": "缺少 Authorization header"}
```

**2. 带 Token（应该成功）：**
```bash
curl -X POST http://localhost:8000/post_comment \
  -H "Content-Type: application/json" \
  -H "Authorization: your-secret-token-2025" \
  -d '{"username":"测试","content":"测试内容","isAnonymous":false}'
```

预期结果：
```json
{
  "code": 200,
  "message": "success",
  "data": {...}
}
```

**3. 错误的 Token（应该失败）：**
```bash
curl -X POST http://localhost:8000/post_comment \
  -H "Content-Type: application/json" \
  -H "Authorization: wrong-token" \
  -d '{"username":"测试","content":"测试内容","isAnonymous":false}'
```

预期结果：
```json
{"detail": "Token 验证失败"}
```

### 使用管理后台测试

1. 确保前后端的 Token 配置一致
2. 启动服务：`./start.fish`
3. 访问管理后台：http://localhost:8080/admin.html
4. 尝试添加、编辑或删除留言
5. 如果操作成功，说明 Token 配置正确

## ⚙️ 高级配置

### 使用环境变量（推荐）

**后端（main.py）：**
```python
import os

# 从环境变量读取 Token，如果不存在则使用默认值
API_TOKEN = os.getenv("API_TOKEN", "your-secret-token-2025")
```

**启动时设置：**
```bash
export API_TOKEN="my-super-secret-token"
python main.py
```

### 使用配置文件

创建 `config.py`：
```python
# config.py
API_TOKEN = "your-secret-token-2025"
```

在 `main.py` 中导入：
```python
from config import API_TOKEN
```

将 `config.py` 添加到 `.gitignore`：
```bash
echo "config.py" >> .gitignore
```

## 🔐 安全建议

### 生产环境

1. **使用强密码**
   - 至少 32 位随机字符
   - 包含大小写字母、数字和特殊字符
   - 使用工具生成：`openssl rand -base64 32`

2. **定期更换 Token**
   - 每月或每季度更换一次
   - 更换时同时更新前后端配置

3. **不要泄露 Token**
   - 不要提交到 Git 仓库
   - 不要在日志中打印
   - 不要通过 URL 传递

4. **使用 HTTPS**
   - 生产环境必须使用 HTTPS
   - 防止 Token 在传输中被窃取

5. **考虑使用 JWT**
   - 支持过期时间
   - 可以携带用户信息
   - 更适合多用户场景

### 开发环境

1. **使用简单的 Token**
   - 开发时可以使用简单的 Token
   - 例如：`dev-token-123`

2. **分离配置**
   - 开发和生产使用不同的 Token
   - 使用环境变量或配置文件管理

## 🐛 故障排查

### 问题 1：前端操作失败

**检查：**
1. 浏览器控制台是否有错误
2. 前端的 `API_TOKEN` 是否正确
3. 后端是否正常运行

**解决：**
确保前后端的 Token 完全一致

### 问题 2：curl 测试失败

**检查：**
1. Token 是否正确
2. 请求头格式是否正确
3. 后端服务是否启动

**解决：**
```bash
# 查看后端日志
tail -f backend.log
```

### 问题 3：401 或 403 错误

**原因：**
- 401: 缺少 Authorization header
- 403: Token 验证失败

**解决：**
检查并修正 Token 配置

## 📚 相关文档

- FastAPI Security: https://fastapi.tiangolo.com/tutorial/security/
- HTTP Authentication: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication

## 🎯 快速参考

### 当前默认 Token
```
your-secret-token-2025
```

### 修改位置
- 后端：`main.py` 第 16 行
- 前端：`admin.html` 第 509 行

### 重启生效
修改 Token 后需要重启服务：
```bash
./stop.fish
./start.fish
```

---

**安全提示**：生产环境请务必修改默认 Token！🔐
