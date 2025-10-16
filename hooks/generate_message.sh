#!/bin/bash

# メッセージ生成スクリプト

# プラグインのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR"
NOTIFY_LOG_PATH="$HOOKS_DIR/notify.log"

# 標準入力からメッセージ要約を取得
SUMMARY=$(cat)

EXISTING_EXAMPLES=$(cat <<'EOT'
- 対応を完了しました。
- 修正を反映しました。
- 最終確認をお願いします。
- 確認事項があります。
- 次の点についてご確認ください。
- ご回答をお願いします。
- 追加の情報が必要です。
- ご指示をお願いします。
- ご確認ください。
- 以上です。
EOT
)

# 直近10件のログを取得
RECENT_LOGS=""
if [ -f "$NOTIFY_LOG_PATH" ]; then
    RECENT_LOGS=$(tail -n 10 "$NOTIFY_LOG_PATH" | cut -d'|' -f2)
fi

# Claude APIへのプロンプトを作成
PROMPT="あなたは無個性で中立的なアシスタントです。以下のタスク要約に対し、
感情やキャラクター性を排した、簡潔で平易な敬体のメッセージを50文字以内で生成してください。

前提: これはAgentからユーザーへの切り替え時の発言です（質問がある時または対応完了時）。

タスク要約: $SUMMARY

【必須要件】
- 無個性・中立。感情やキャラクター性を出さない。
- です／ます調。過度に仰々しい敬語や比喩は避ける。
- 記号・絵文字・感嘆符を使わない。平易な語彙を用いる。
- 着手・開始・実行・進める等の未来時制の表現は使わない。
- 成果の報告または質問の提示に限定する。

【重複回避】
- 最近の発言（下記）と同義反復や語句の重複を避ける。
$RECENT_LOGS

【発言パターン例】
$EXISTING_EXAMPLES

【出力形式】
- 何をしたかが具体的にわかるよう、端的に記載する（前後の解説・記号・引用符なし）。"

# フォールバック文言の判定（質問/確認が含まれるかで出し分け）
if echo "$SUMMARY" | grep -Eq '[\?？]|質問|確認|教えて|不明点|ご回答'; then
	FALLBACK_MESSAGE="ご確認をお願いします。"
else
	FALLBACK_MESSAGE="対応を完了しました。"
fi

# Claude CLIコマンドを使用してメッセージ生成
if command -v claude >/dev/null 2>&1; then
    # プロンプトを直接パイプで渡す
    RESPONSE=$(echo "$PROMPT" | claude -p - 2>/dev/null)
    # レスポンスが取得できた場合
    if [ -n "$RESPONSE" ] && [ "$RESPONSE" != "" ]; then
        echo "$RESPONSE" | head -n 2
    else
        # Claude CLIが失敗した場合のフォールバック
        echo "$FALLBACK_MESSAGE"
    fi
else
    # Claude CLIが利用できない場合のフォールバック
    echo "$FALLBACK_MESSAGE"
fi


