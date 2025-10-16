#!/bin/bash

# Style-Bert-VITS2 音声合成スクリプト
# 使用方法: ./tts_bert_vits.sh "読み上げたいテキスト"

# API認証情報
CF_ACCESS_CLIENT_ID="78daf18f4b82f77f12a0bfec004ab4ce.access"
CF_ACCESS_CLIENT_SECRET="cded896f04ee01c47f5098cebcd3118ed09ad1bc3666f1d59cc5912b2e724020"
API_BASE_URL="https://bert-vits-web.vildas.org"

# モデル設定（固定）
MODEL_NAME="izawa_toiyomi"
MODEL_FILE="model_assets/izawa_toiyomi/izawa_toiyomi_e100_s5000.safetensors"

# 設定ファイルの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# グローバル設定ファイルを読み込み
GLOBAL_CONFIG="$HOME/.config/takushi_notifier/volume.conf"

# グローバル設定ファイルが存在する場合は読み込み
if [ -f "$GLOBAL_CONFIG" ]; then
    . "$GLOBAL_CONFIG"
fi

# 音量設定（設定ファイルで AFPLAY_VOLUME を 0.0〜1.0 で指定可能。）
AFPLAY_VOLUME="${AFPLAY_VOLUME:-1.0}"

# 引数チェック
if [ $# -eq 0 ]; then
    echo "エラー: テキストを指定してください"
    echo "使用方法: $0 \"読み上げたいテキスト\""
    exit 1
fi

TEXT="$1"
SAVE_FILE="${2:-}"  # 第2引数で出力ファイル名を指定可能（省略時は一時ファイル）

# 出力ファイルの設定
if [ -z "$SAVE_FILE" ]; then
    # ファイル名が指定されていない場合は一時ファイルを使用
    OUTPUT_FILE=$(mktemp /tmp/tts_XXXXXX.wav)
    TEMP_FILE=true
else
    OUTPUT_FILE="$SAVE_FILE"
    TEMP_FILE=false
fi

# 1. G2P処理でmoraToneListを取得
G2P_RESULT=$(curl -s -X POST "${API_BASE_URL}/api/g2p" \
  -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
  -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"${TEXT}\"}")

# エラーチェック
if [ $? -ne 0 ]; then
    echo "エラー: G2P処理に失敗しました"
    exit 1
fi

# 2. 音声合成
SYNTHESIS_JSON=$(cat <<EOF
{
  "model": "${MODEL_NAME}",
  "modelFile": "${MODEL_FILE}",
  "text": "${TEXT}",
  "moraToneList": ${G2P_RESULT}
}
EOF
)

# 音声合成リクエスト
HTTP_STATUS=$(curl -s -X POST "${API_BASE_URL}/api/synthesis" \
  -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
  -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" \
  -H "Content-Type: application/json" \
  -H "Accept: audio/wav" \
  -d "${SYNTHESIS_JSON}" \
  --output "${OUTPUT_FILE}" \
  -w "%{http_code}")

# HTTPステータスコードチェック
if [ "$HTTP_STATUS" -eq 200 ]; then
    if [ -f "${OUTPUT_FILE}" ]; then
        if [ "$TEMP_FILE" = true ]; then
            # 一時ファイルの場合は自動再生して削除
            afplay -v "${AFPLAY_VOLUME}" "${OUTPUT_FILE}"
            rm "${OUTPUT_FILE}"
        else
            # ファイル保存の場合
            echo "ファイル: ${OUTPUT_FILE}"
        fi
    fi
else
    echo "エラー: 音声合成に失敗しました (HTTPステータス: ${HTTP_STATUS})"
    if [ -f "${OUTPUT_FILE}" ]; then
        echo "エラー内容:"
        cat "${OUTPUT_FILE}"
        rm "${OUTPUT_FILE}"
    fi
    exit 1
fi