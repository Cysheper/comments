#!/usr/bin/env fish
# Token 验证测试脚本

set API_BASE "http://localhost:8000"
set TOKEN "your-secret-token-2025"

echo "🧪 开始测试 Token 验证..."
echo ""

# 测试 1: GET 请求（不需要 Token）
echo "📍 测试 1: GET 请求（不需要 Token）"
echo "────────────────────────────────────────"
curl -s "$API_BASE/get_comments" | python -m json.tool | head -20
echo ""
echo "✅ GET 请求测试完成"
echo ""

# 测试 2: POST 请求不带 Token（应该失败）
echo "📍 测试 2: POST 请求不带 Token（应该失败）"
echo "────────────────────────────────────────"
curl -s -X POST "$API_BASE/post_comment" \
  -H "Content-Type: application/json" \
  -d '{"username":"测试用户","content":"测试内容","isAnonymous":false}' | python -m json.tool
echo ""
echo "❌ 预期失败（缺少 Token）"
echo ""

# 测试 3: POST 请求带错误 Token（应该失败）
echo "📍 测试 3: POST 请求带错误 Token（应该失败）"
echo "────────────────────────────────────────"
curl -s -X POST "$API_BASE/post_comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: wrong-token" \
  -d '{"username":"测试用户","content":"测试内容","isAnonymous":false}' | python -m json.tool
echo ""
echo "❌ 预期失败（Token 错误）"
echo ""

# 测试 4: POST 请求带正确 Token（应该成功）
echo "📍 测试 4: POST 请求带正确 Token（应该成功）"
echo "────────────────────────────────────────"
curl -s -X POST "$API_BASE/post_comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: $TOKEN" \
  -d '{"username":"Token测试","content":"这是带Token的测试留言","isAnonymous":false}' | python -m json.tool
echo ""
echo "✅ 预期成功（Token 正确）"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 测试完成！"
echo ""
echo "如果测试 4 成功创建了留言，说明 Token 配置正确！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
