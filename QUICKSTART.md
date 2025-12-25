# 留言板项目 - 快速开始指南

## 🎯 如何创建和使用数据库

### 步骤 1: 安装依赖

```bash
# 创建虚拟环境（推荐）
python3 -m venv venv

# 激活虚拟环境 (Fish Shell)
source venv/bin/activate.fish

# 安装依赖
pip install -r requirements.txt
```

**或者使用自动设置脚本：**

```bash
# 给脚本执行权限
chmod +x setup.fish

# 运行设置脚本
./setup.fish
```

### 步骤 2: 初始化数据库

```bash
# 运行初始化脚本（会创建数据库并添加示例数据）
python init_db.py
```

这个脚本会：
- ✓ 创建 `comments.db` 数据库文件
- ✓ 创建 `comments` 表
- ✓ 添加 5 条示例留言

### 步骤 3: 启动应用

```bash
python main.py
```

应用将在 http://localhost:8000 启动

## 📋 项目文件说明

```
comments/
├── main.py              # 主应用文件（包含数据库连接和 API）
├── init_db.py          # 数据库初始化脚本
├── requirements.txt    # Python 依赖列表
├── setup.fish          # 自动设置脚本
├── README.md           # 完整文档
├── QUICKSTART.md       # 本文件
└── comments.db         # SQLite 数据库文件（运行后自动创建）
```

## 🔧 数据库操作

### 查看数据库内容

```bash
# 使用 sqlite3 命令行工具
sqlite3 comments.db

# 在 sqlite3 中执行：
SELECT * FROM comments;   # 查看所有留言
.quit                     # 退出
```

### 重置数据库

```bash
# 删除数据库文件
rm comments.db

# 重新初始化
python init_db.py
```

## 🌐 API 测试

### 获取所有留言

```bash
curl http://localhost:8000/get_comments
```

### 发布新留言

```bash
curl -X POST http://localhost:8000/post_comment \
  -H "Content-Type: application/json" \
  -d '{"username":"测试用户","isAnonymous":false,"content":"这是测试留言"}'
```

### 删除留言

```bash
curl -X DELETE http://localhost:8000/delete_comment/1
```

## ❓ 常见问题

**Q: 如何查看数据库文件？**
A: 数据库文件 `comments.db` 在项目根目录下，使用 `sqlite3 comments.db` 可以打开。

**Q: 数据会丢失吗？**
A: 不会，所有数据都保存在 `comments.db` 文件中，只要不删除这个文件数据就会保留。

**Q: 如何备份数据？**
A: 直接复制 `comments.db` 文件即可：`cp comments.db backup.db`

**Q: 程序启动失败怎么办？**
A: 
1. 确保已激活虚拟环境：`source venv/bin/activate.fish`
2. 确保已安装依赖：`pip install -r requirements.txt`
3. 检查端口 8000 是否被占用

## 📚 更多信息

详细文档请查看 [README.md](README.md)

---

**Happy Coding! 🎉**
