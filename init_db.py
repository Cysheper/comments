#!/usr/bin/env python3
"""
数据库初始化脚本
运行此脚本来创建数据库并添加示例数据
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from main import Base, Comment
from datetime import datetime, timedelta
from typing import cast

# 数据库配置
DATABASE_URL = "sqlite:///./comments.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def init_database():
    """初始化数据库并添加示例数据"""
    
    # 创建所有表
    print("正在创建数据库表...")
    Base.metadata.create_all(bind=engine)
    print("✓ 数据库表创建成功！")
    
    # 创建数据库会话
    db = SessionLocal()
    
    try:
        # 检查是否已有数据
        count = db.query(Comment).count()
        if count > 0:
            print(f"数据库中已有 {count} 条留言数据")
            response = input("是否清空现有数据并重新初始化？(y/n): ")
            if response.lower() == 'y':
                db.query(Comment).delete()
                db.commit()
                print("✓ 已清空现有数据")
            else:
                print("取消初始化")
                return
        
        # 添加示例数据
        print("\n正在添加示例数据...")
        sample_comments = [
            Comment(
                username="张三",
                isAnonymous=False,
                content="这是第一条留言，很高兴能在这里留言！",
                createTime=datetime.now() - timedelta(hours=5)
            ),
            Comment(
                username="匿名用户",
                isAnonymous=True,
                content="这是一条匿名留言 😊 感谢提供这个平台",
                createTime=datetime.now() - timedelta(hours=3)
            ),
            Comment(
                username="李四",
                isAnonymous=False,
                content="网站做得不错，继续加油！",
                createTime=datetime.now() - timedelta(hours=2)
            ),
            Comment(
                username="匿名用户",
                isAnonymous=True,
                content="建议可以添加更多功能 👍",
                createTime=datetime.now() - timedelta(hours=1)
            ),
            Comment(
                username="王五",
                isAnonymous=False,
                content="期待后续更新！",
                createTime=datetime.now() - timedelta(minutes=30)
            )
        ]
        
        for comment in sample_comments:
            db.add(comment)
        
        db.commit()
        print(f"✓ 成功添加 {len(sample_comments)} 条示例留言")
        
        # 显示所有留言
        print("\n当前数据库中的留言：")
        all_comments = db.query(Comment).all()
        for comment in all_comments:
            is_anonymous = cast(bool, comment.isAnonymous)
            anonymous = "【匿名】" if is_anonymous else ""
            print(f"ID: {comment.id} | {anonymous}{comment.username}")
            print(f"内容: {comment.content}")
            print(f"时间: {comment.createTime.strftime('%Y-%m-%d %H:%M:%S')}")
            print("-" * 80)
            print("-" * 80)
        
        print(f"\n✓ 数据库初始化完成！共有 {len(all_comments)} 条留言")
        
    except Exception as e:
        print(f"✗ 初始化失败: {str(e)}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 80)
    print("留言板数据库初始化脚本")
    print("=" * 80)
    init_database()
