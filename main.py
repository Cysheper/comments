from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, Mapped, mapped_column
from datetime import datetime
from pydantic import BaseModel
from typing import Optional

# 数据库配置
DATABASE_URL = "sqlite:///./comments.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 数据库模型
class Comment(Base):
    __tablename__ = "comments"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String, nullable=False)
    isAnonymous: Mapped[bool] = mapped_column(Boolean, default=False)
    content: Mapped[str] = mapped_column(String, nullable=False)
    createTime: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

# Pydantic 模型用于请求验证
class CommentCreate(BaseModel):
    username: Optional[str] = "匿名用户"
    isAnonymous: Optional[bool] = True
    content: str

# 创建数据库表
Base.metadata.create_all(bind=engine)

app = FastAPI()

# 数据库依赖
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 添加CORS中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 允许所有源，生产环境建议指定具体域名
    allow_credentials=True,
    allow_methods=["*"],  # 允许所有方法
    allow_headers=["*"],  # 允许所有头
)


@app.get("/get_comments")
async def get_comments(sort: str = "desc"):
    db = SessionLocal()
    try:
        # 从数据库获取所有留言
        comments = db.query(Comment).all()
        
        # 转换为字典列表
        data_list = []
        for comment in comments:
            data_list.append({
                "id": comment.id,
                "username": comment.username,
                "isAnonymous": comment.isAnonymous,
                "content": comment.content,
                "createTime": comment.createTime.strftime("%Y-%m-%d %H:%M:%S")
            })
        
        # 根据排序参数排序
        if sort == "desc":
            data_list.sort(key=lambda x: x["createTime"], reverse=True)
        else:
            data_list.sort(key=lambda x: x["createTime"])
        
        return {
            "code": 200,
            "message": "success",
            "data": data_list
        }
    finally:
        db.close()


@app.post("/post_comment")
async def post_comment(comment: CommentCreate):
    db = SessionLocal()
    try:
        # 创建新留言
        new_comment = Comment(
            username=comment.username if not comment.isAnonymous else "匿名用户",
            isAnonymous=comment.isAnonymous,
            content=comment.content,
            createTime=datetime.now()
        )
        
        # 保存到数据库
        db.add(new_comment)
        db.commit()
        db.refresh(new_comment)
        
        return {
            "code": 200,
            "message": "success",
            "data": {
                "id": new_comment.id,
                "username": new_comment.username,
                "isAnonymous": new_comment.isAnonymous,
                "content": new_comment.content,
                "createTime": new_comment.createTime.strftime("%Y-%m-%d %H:%M:%S")
            }
        }
    except Exception as e:
        db.rollback()
        return {
            "code": 500,
            "message": f"保存失败: {str(e)}",
            "data": None
        }
    finally:
        db.close()


@app.put("/update_comment/{comment_id}")
async def update_comment(comment_id: int, comment: CommentCreate):
    db = SessionLocal()
    try:
        existing_comment = db.query(Comment).filter(Comment.id == comment_id).first()
        if not existing_comment:
            return {
                "code": 404,
                "message": "留言不存在",
                "data": None
            }
        
        # 更新留言
        username = comment.username if comment.username else "匿名用户"
        existing_comment.username = username if not comment.isAnonymous else "匿名用户"
        existing_comment.isAnonymous = comment.isAnonymous if comment.isAnonymous is not None else True
        existing_comment.content = comment.content
        
        db.commit()
        db.refresh(existing_comment)
        
        return {
            "code": 200,
            "message": "更新成功",
            "data": {
                "id": existing_comment.id,
                "username": existing_comment.username,
                "isAnonymous": existing_comment.isAnonymous,
                "content": existing_comment.content,
                "createTime": existing_comment.createTime.strftime("%Y-%m-%d %H:%M:%S")
            }
        }
    except Exception as e:
        db.rollback()
        return {
            "code": 500,
            "message": f"更新失败: {str(e)}",
            "data": None
        }
    finally:
        db.close()


@app.delete("/delete_comment/{comment_id}")
async def delete_comment(comment_id: int):
    db = SessionLocal()
    try:
        comment = db.query(Comment).filter(Comment.id == comment_id).first()
        if not comment:
            return {
                "code": 404,
                "message": "留言不存在",
                "data": None
            }
        
        db.delete(comment)
        db.commit()
        
        return {
            "code": 200,
            "message": "删除成功",
            "data": None
        }
    except Exception as e:
        db.rollback()
        return {
            "code": 500,
            "message": f"删除失败: {str(e)}",
            "data": None
        }
    finally:
        db.close()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)