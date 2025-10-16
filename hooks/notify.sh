#!/bin/bash

# 音声通知スクリプト
# 最後のメッセージを取得し、要約してメッセージを読み上げ

# 標準入力からJSONを読み取る
INPUT=$(cat)

# プラグインのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$SCRIPT_DIR"
NOTIFY_LOG_PATH="$HOOKS_DIR/notify.log"

# ログディレクトリの作成
mkdir -p "$HOOKS_DIR"

# トランスクリプトを処理（.jsonl形式に対応）
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
if [ -f "$TRANSCRIPT_PATH" ]; then
    # 最後のアシスタントメッセージのみを取得（全文）
    TEMP_FILE=$(mktemp)
    
    if command -v tail >/dev/null 2>&1; then
        tail -r "$TRANSCRIPT_PATH" > "$TEMP_FILE"
        
        LAST_MESSAGE=""
        while IFS= read -r line; do
            # JSON形式の妥当性をチェック
            if echo "$line" | jq -e . >/dev/null 2>&1; then
                if echo "$line" | jq -e '.type == "assistant"' >/dev/null 2>&1; then
                    LAST_MESSAGE=$(echo "$line" | jq -r '.message.content[]? | select(.type == "text") | .text' 2>/dev/null)
                    break
                fi
            fi
        done < "$TEMP_FILE"
        
        rm -f "$TEMP_FILE"
    fi

    # メッセージが取得できた場合の処理
    if [ -n "$LAST_MESSAGE" ]; then
        # 要約生成（最初の100文字を使用）
        SUMMARY=$(echo "$LAST_MESSAGE" | head -c 100 | sed 's/[[:space:]]*$//')
        if [ ${#LAST_MESSAGE} -gt 100 ]; then
            SUMMARY="${SUMMARY}..."
        fi

        # メッセージの動的生成
        MESSAGE=""
        GENERATE_MESSAGE_SCRIPT="$HOOKS_DIR/generate_message.sh"
        if [ -f "$GENERATE_MESSAGE_SCRIPT" ]; then
            MESSAGE=$(echo "$SUMMARY" | bash "$GENERATE_MESSAGE_SCRIPT" 2>/dev/null)
        fi

        # デフォルト文例（生成に失敗した場合）
        if [ -z "$MESSAGE" ]; then
            MESSAGE="処理が完了しました。"
        fi



        # 通知実行
        # terminal-notifier使用（Macネイティブ通知）
        if command -v terminal-notifier >/dev/null 2>&1; then
            terminal-notifier -message "$MESSAGE" -title "Assistant" >/dev/null 2>&1 &
        fi
        
        # 音声出力（Style-Bert-VITS2）
        TTS_SCRIPT="$HOOKS_DIR/tts_bert_vits.sh"
        if [ -f "$TTS_SCRIPT" ]; then
            nohup bash "$TTS_SCRIPT" "$MESSAGE" >/dev/null 2>&1 &
        fi
        
        # ログ保存（タイムスタンプ|発言のみ、改行除去）
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        CLEAN_MESSAGE=$(echo "$MESSAGE" | tr -d '\n\r' | sed 's/[[:space:]]\+/ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        echo "$TIMESTAMP|$CLEAN_MESSAGE" >> "$NOTIFY_LOG_PATH"
        
        # ログを10件までに制限
        if [ -f "$NOTIFY_LOG_PATH" ]; then
            TEMP_LOG=$(mktemp)
            tail -n 10 "$NOTIFY_LOG_PATH" > "$TEMP_LOG"
            mv "$TEMP_LOG" "$NOTIFY_LOG_PATH"
        fi
    fi
fi

echo '{"decision": "approve"}'
exit 0