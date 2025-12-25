# 留言板项目 - 数据库配置指南

## 📦 安装依赖

首先安装所需的 Python 包：

```bash
pip install -r requirements.txt
```

或者手动安装：

```bash
pip install fastapi uvicorn sqlalchemy pydantic
```

## 🗄️ 数据库说明

本项目使用 **SQLite** 数据库，这是一个轻量级的文件型数据库，无需单独安装数据库服务器。

### 数据库文件

- 数据库文件名：`comments.db`
- 位置：项目根目录
- 在首次运行程序时会自动创建

### 数据表结构

**comments** 表：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键，自动递增 |
| username | String | 用户名 |
| isAnonymous | Boolean | 是否匿名 |
| content | String | 留言内容 |
| createTime | DateTime | 创建时间 |

## 🚀 创建和初始化数据库

### 方法一：自动创建（推荐）

运行主程序时会自动创建数据库：

```bash
python main.py
```

### 方法二：使用初始化脚本

运行初始化脚本创建数据库并添加示例数据：

```bash
python init_db.py
```

这个脚本会：
1. 创建数据库表
2. 添加 5 条示例留言
3. 显示所有留言数据

### 方法三：一键启动（最简单）

```bash
chmod +x start.fish
./start.fish
```

这将自动启动后端服务和管理后台！

## 🎮 启动应用

### 仅启动后端 API

```bash
python main.py
```

或使用 uvicorn：

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

应用将在 http://localhost:8000 运行

### 启动完整系统（后端 + 管理后台）

```bash
./start.fish
```

- 后端 API: http://localhost:8000
- 管理后台: http://localhost:8080/admin.html
- API 文档: http://localhost:8000/docs

## 📊 管理后台

### 功能特点

✨ **数据统计**
- 总留言数、实名留言、匿名留言、今日新增

🔍 **搜索功能**
- 实时搜索留言内容和用户名

📝 **增删改查**
- ➕ 新增留言
- ✏️ 编辑留言
- 🗑️ 删除留言
- 🔄 刷新数据

📥 **数据导出**
- 导出为 CSV 格式
- 支持中文（UTF-8 with BOM）

### 访问管理后台

```bash
# 启动前端服务
python -m http.server 8080

# 浏览器访问
open http://localhost:8080/admin.html
```

详细使用说明请查看 [ADMIN_GUIDE.md](ADMIN_GUIDE.md)

## 📡 API 接口

### 1. 获取所有留言

**GET** `/get_comments?sort=desc`

参数：
- `sort`: 排序方式，`desc`（降序）或 `asc`（升序）

响应示例：
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "username": "张三",
      "isAnonymous": false,
      "content": "这是一条留言",
      "createTime": "2025-12-26 10:30:00"
    }
  ]
}
```

### 2. 发布留言

**POST** `/post_comment`

请求体：
```json
{
  "username": "张三",
  "isAnonymous": false,
  "content": "这是我的留言内容"
}
```

响应示例：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 2,
    "username": "张三",
    "isAnonymous": false,
    "content": "这是我的留言内容",
    "createTime": "2025-12-26 12:00:00"
  }
}
```

### 3. 删除留言

**DELETE** `/delete_comment/{comment_id}`

参数：
- `comment_id`: 要删除的留言 ID

响应示例：
```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

### 4. 更新留言

**PUT** `/update_comment/{comment_id}`

参数：
- `comment_id`: 要更新的留言 ID

请求体：
```json
{
  "username": "张三",
  "isAnonymous": false,
  "content": "更新后的留言内容"
}
```

响应示例：
```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": 1,
    "username": "张三",
    "isAnonymous": false,
    "content": "更新后的留言内容",
    "createTime": "2025-12-26 10:30:00"
  }
}
```

## 🔧 常见操作

### 查看数据库内容

你可以使用 SQLite 工具查看数据库：

```bash
# 安装 sqlite3（通常系统自带）
sqlite3 comments.db

# 在 sqlite3 命令行中
.tables                    # 查看所有表
SELECT * FROM comments;    # 查看所有留言
.quit                      # 退出
```

### 重置数据库

如果需要重置数据库：

```bash
# 删除数据库文件
rm comments.db

# 重新运行初始化脚本
python init_db.py
```

### 备份数据库

```bash
# 简单备份
cp comments.db comments_backup.db

# 带时间戳的备份
cp comments.db comments_$(date +%Y%m%d_%H%M%S).db
```

## 📝 代码说明

### 数据库连接

```python
DATABASE_URL = "sqlite:///./comments.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
```

### 数据库模型

使用 SQLAlchemy ORM 定义数据模型：

```python
class Comment(Base):
    __tablename__ = "comments"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, nullable=False)
    isAnonymous = Column(Boolean, default=False)
    content = Column(String, nullable=False)
    createTime = Column(DateTime, default=datetime.now)
```

### 数据库操作示例

```python
# 创建会话
db = SessionLocal()

# 查询所有留言
comments = db.query(Comment).all()

# 创建新留言
new_comment = Comment(username="张三", content="留言内容")
db.add(new_comment)
db.commit()

# 删除留言
comment = db.query(Comment).filter(Comment.id == 1).first()
db.delete(comment)
db.commit()

# 关闭会话
db.close()
```

## 🎯 下一步

- [ ] 添加用户认证
- [ ] 添加留言点赞功能
- [ ] 添加留言回复功能
- [ ] 添加分页功能
- [ ] 迁移到 PostgreSQL/MySQL（生产环境）

## 📁 项目结构

```
comments/
├── main.py              # 主应用（FastAPI 后端）
├── init_db.py          # 数据库初始化脚本
├── admin.html          # 管理后台（可视化界面）
├── requirements.txt    # Python 依赖
├── setup.fish          # 自动设置脚本
├── start.fish          # 一键启动脚本
├── README.md           # 项目文档
├── ADMIN_GUIDE.md      # 管理后台使用指南
├── QUICKSTART.md       # 快速开始指南
└── comments.db         # SQLite 数据库（运行后生成）
```

## ❓ 常见问题

**Q: 为什么选择 SQLite？**
A: SQLite 轻量级、无需配置、适合小型项目和开发测试。

**Q: 如何切换到其他数据库？**
A: 只需修改 `DATABASE_URL`，例如：
- PostgreSQL: `postgresql://user:password@localhost/dbname`
- MySQL: `mysql+pymysql://user:password@localhost/dbname`

**Q: 数据库文件在哪里？**
A: 在项目根目录下的 `comments.db` 文件。

## 📄 许可证

MIT License
