#!/usr/bin/env bash
# cl-baseline PreToolUse Bash validator
#
# Called by Claude Code via hooks.json. Receives tool input JSON on stdin.
# Exit 0 = allow, exit 2 = deny (emit JSON decision on stderr).

set -uo pipefail

input=$(cat)
if [[ -z "$input" ]]; then
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
else
  cmd=$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

if [[ -z "$cmd" ]]; then
  exit 0
fi

block() {
  local id="$1"
  local reason="$2"
  printf '{"decision":"deny","pattern_id":"%s","reason":"[cl-baseline:%s] %s"}\n' \
    "$id" "$id" "$reason" >&2
  exit 2
}

# --- Pattern: rm-rf-root ---
if [[ "$cmd" =~ (^|[[:space:]])rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*[fF][a-zA-Z]*|-[a-zA-Z]*[fF][a-zA-Z]*[rR][a-zA-Z]*)[[:space:]]+(--no-preserve-root[[:space:]]+)?(/[^[:space:]]*|~[^[:space:]]*|\$HOME[^[:space:]]*)([[:space:]]|$|\;|\&) ]]; then
  block "rm-rf-root" "ディスク全体を破壊する恐れのある rm コマンドです（/*, /home など含む）"
fi
if [[ "$cmd" =~ (^|[[:space:]])rm[[:space:]].*--no-preserve-root ]]; then
  block "rm-rf-root" "--no-preserve-root オプションは禁止です"
fi

# --- Pattern: curl-pipe-shell ---
if [[ "$cmd" =~ (curl|wget)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh|ksh)([[:space:]]|$|-) ]]; then
  block "curl-pipe-shell" "ネットワークから取得したコンテンツを直接シェルにパイプしています"
fi

# --- Pattern: fork-bomb ---
if [[ "$cmd" =~ :[[:space:]]*\([[:space:]]*\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:[[:space:]]*\& ]]; then
  block "fork-bomb" "fork bomb を検出しました"
fi

# --- Pattern: dd-device ---
if [[ "$cmd" =~ (^|[[:space:]])dd[[:space:]].*of=/dev/(sd[a-z]|nvme[0-9]|disk[0-9]|hd[a-z]|xvd[a-z]) ]]; then
  block "dd-device" "物理デバイスに直接書き込む dd コマンドです"
fi

# --- Pattern: chmod-777-root ---
if [[ "$cmd" =~ (^|[[:space:]])chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/([[:space:]]|$) ]] || \
   [[ "$cmd" =~ (^|[[:space:]])chmod[[:space:]]+777[[:space:]]+-R[[:space:]]+/([[:space:]]|$) ]]; then
  block "chmod-777-root" "ルート配下のパーミッションを 777 に変更しています"
fi
if [[ "$cmd" =~ (^|[[:space:]])chown[[:space:]]+-R[[:space:]]+[^[:space:]]+[[:space:]]+/([[:space:]]|$) ]]; then
  block "chmod-777-root" "ルート配下の所有者を変更しています"
fi

# --- Pattern: mkfs-device ---
if [[ "$cmd" =~ (^|[[:space:]])mkfs\.[a-z0-9]+[[:space:]] ]]; then
  block "mkfs-device" "mkfs でファイルシステムを初期化しようとしています"
fi
if [[ "$cmd" =~ \>[[:space:]]*/dev/(sd[a-z]|nvme[0-9]|hd[a-z]|xvd[a-z]) ]]; then
  block "mkfs-device" "物理デバイスへのリダイレクトを検出しました"
fi

# --- Pattern: force-push ---
if [[ "$cmd" =~ (^|[[:space:]])git[[:space:]]+push[[:space:]] ]]; then
  has_force=0
  if [[ "$cmd" =~ (^|[[:space:]])(--force|-f)([[:space:]]|$) ]]; then
    has_force=1
  fi
  has_protected=0
  if [[ "$cmd" =~ (^|[[:space:]]|:)(main|master|production|release)([[:space:]]|$|:) ]]; then
    has_protected=1
  fi
  if [[ $has_force -eq 1 && $has_protected -eq 1 ]]; then
    block "force-push" "保護ブランチ (main/master/production/release) への force push は禁止です"
  fi
fi

# --- Pattern: base64-pipe-shell ---
if [[ "$cmd" =~ (base64)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh|ksh|python|ruby|perl)([[:space:]]|$|-) ]]; then
  block "base64-pipe-shell" "base64 デコード結果を直接シェルにパイプしています（難読化されたコマンド実行）"
fi

# --- Pattern: eval-obfuscation ---
if [[ "$cmd" =~ (^|[[:space:]])eval[[:space:]]+[\"\$\`\(] ]]; then
  block "eval-obfuscation" "eval による難読化されたコマンド実行を検出しました"
fi

# --- Pattern: aws-creds ---
if [[ "$cmd" =~ (^|[[:space:]])aws[[:space:]]+configure[[:space:]]+set[[:space:]]+aws_secret_access_key ]]; then
  block "aws-creds" "AWS クレデンシャルをコマンドラインに平文で設定しています"
fi
if [[ "$cmd" =~ (^|[[:space:]]*)(export[[:space:]]+)?AWS_SECRET_ACCESS_KEY[[:space:]]*= ]]; then
  block "aws-creds" "AWS シークレットキーを環境変数に平文で設定しています"
fi
if [[ "$cmd" =~ (^|[[:space:]]*)(export[[:space:]]+)?AWS_ACCESS_KEY_ID[[:space:]]*=[[:space:]]*AKIA ]]; then
  block "aws-creds" "AWS アクセスキー ID を環境変数に平文で設定しています"
fi

# --- Pattern: system-shutdown ---
if [[ "$cmd" =~ (^|[[:space:]]|sudo[[:space:]]+)(shutdown|reboot|halt|poweroff|init[[:space:]]+0|init[[:space:]]+6)([[:space:]]|$) ]]; then
  block "system-shutdown" "システムのシャットダウン・再起動コマンドを検出しました"
fi

# --- Pattern: kill-all ---
if [[ "$cmd" =~ (^|[[:space:]])kill[[:space:]].*[[:space:]]-1([[:space:]]|$) ]] || \
   [[ "$cmd" =~ (^|[[:space:]])kill[[:space:]].*[[:space:]]1([[:space:]]|$) && "$cmd" =~ -9|-KILL ]]; then
  block "kill-all" "全プロセスまたは init プロセスへの kill を検出しました"
fi

# --- Pattern: firewall-disable ---
if [[ "$cmd" =~ (^|[[:space:]])(sudo[[:space:]]+)?iptables[[:space:]]+-F([[:space:]]|$) ]] || \
   [[ "$cmd" =~ (^|[[:space:]])(sudo[[:space:]]+)?ufw[[:space:]]+disable([[:space:]]|$) ]] || \
   [[ "$cmd" =~ (^|[[:space:]])(sudo[[:space:]]+)?systemctl[[:space:]]+(stop|disable)[[:space:]]+(ufw|firewalld|iptables)([[:space:]]|$) ]]; then
  block "firewall-disable" "ファイアウォールの無効化・ルール削除を検出しました"
fi

# --- Pattern: crontab-remove ---
if [[ "$cmd" =~ (^|[[:space:]])crontab[[:space:]]+-r([[:space:]]|$) ]]; then
  block "crontab-remove" "crontab -r は全 cron ジョブを削除します"
fi

# --- Pattern: npm-usage (社内規約: npm/yarn/npx 禁止。pnpm + @aikido-sec/safe-chain を使う) ---
if [[ "$cmd" =~ (^|[[:space:]])npm([[:space:]]|$) ]]; then
  block "npm-usage" "npm は社内規約で禁止です。pnpm + @aikido-sec/safe-chain を使用してください"
fi
if [[ "$cmd" =~ (^|[[:space:]])yarn([[:space:]]|$) ]]; then
  block "npm-usage" "yarn は社内規約で禁止です。pnpm + @aikido-sec/safe-chain を使用してください"
fi
if [[ "$cmd" =~ (^|[[:space:]])npx([[:space:]]|$) ]]; then
  block "npm-usage" "npx は社内規約で禁止です。pnpm dlx または safe-chain 経由で実行してください"
fi

exit 0
