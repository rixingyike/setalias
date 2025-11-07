#!/usr/bin/env bash
set -euo pipefail

# 通州图书馆 WiFi 认证快捷脚本
# 默认使用示例卡号与密码，可通过参数或环境变量覆盖：
# 用法：loginwifi [card] [password]
# 环境变量：LOGINWIFI_CODE, LOGINWIFI_PWD（兼容 LOWIFI_CODE, LOWIFI_PWD）

CODE_DEFAULT="001300095176"
PWD_DEFAULT="830918"

CODE="${1:-${LOGINWIFI_CODE:-${LOWIFI_CODE:-$CODE_DEFAULT}}}"
PWD="${2:-${LOGINWIFI_PWD:-${LOWIFI_PWD:-$PWD_DEFAULT}}}"

URL="http://192.168.2.253:8080/api/tztsg/wifi-auth?code=${CODE}&pwd=${PWD}"
COOKIES="password=${PWD}; rememberMe=true; username=${CODE}"

 # 发起 GET 请求，附带 Cookie，并捕获 HTTP 状态码
RESP=$(curl -sS --connect-timeout 3 --max-time 8 \
  -H "Accept: application/json, text/plain, */*" \
  -H "Accept-Encoding: gzip, deflate" \
  -H "Accept-Language: zh-CN,zh-Hans;q=0.9" \
  -H "User-Agent: setalias-loginwifi/1.0" \
  -b "$COOKIES" \
  -w '\n%{http_code}' \
  "$URL")

HTTP_CODE=$(echo "$RESP" | tail -n1)
BODY=$(echo "$RESP" | sed '$d')

if [[ "$HTTP_CODE" != "200" ]]; then
  printf "WiFi 认证请求失败，HTTP 状态码：%s\n" "$HTTP_CODE"
  exit 1
fi

# 解析 status 与 card（优先 jq，回退到 sed）
STATUS=""
if command -v jq >/dev/null 2>&1; then
  STATUS=$(echo "$BODY" | jq -r '.status' 2>/dev/null || true)
fi
if [[ -z "$STATUS" || "$STATUS" == "null" ]]; then
  STATUS=$(echo "$BODY" | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"[:space:]]*\)".*/\1/p')
fi

CARD=""
if command -v jq >/dev/null 2>&1; then
  CARD=$(echo "$BODY" | jq -r '.card' 2>/dev/null || true)
fi
if [[ -z "$CARD" || "$CARD" == "null" ]]; then
  CARD=$(echo "$BODY" | sed -n 's/.*"card"[[:space:]]*:[[:space:]]*"\([^"[:space:]]*\)".*/\1/p')
fi

if [[ "$STATUS" == "login" ]]; then
  printf "WiFi 已连接 ✅（card=%s, status=%s）\n" "${CARD:-$CODE}" "$STATUS"
  exit 0
else
  printf "WiFi 未连接 ❌（card=%s, status=%s）\n响应：%s\n" "${CARD:-$CODE}" "${STATUS:-unknown}" "$BODY"
  exit 2
fi
