# Takushi Notifier Plugin

Claude Assistantの応答を音声で読み上げるプラグインです。Style-Bert-VITS2を使用して高品質な音声合成を行います。

## 機能

- Assistantの応答を自動的に音声で読み上げ
- Style-Bert-VITS2を使用した高品質な音声合成
- Claude CLIを使用したメッセージの動的生成
- 通知ログの管理
- macOSネイティブ通知対応
- `/takushi_volume`コマンドで音量調整（0-100%）

## インストール

1. Claude Codeを起動
2. 以下のコマンドを実行：
   ```
   /plugin marketplace add .
   /plugin install takushi-notifier@takushi-notifier-marketplace
   ```

## 音量調整

プラグインインストール後、以下のコマンドで音量を調整できます：

```
# 音量を50%に設定
/takushi_volume 50

# 現在の音量を確認
/takushi_volume

# 音量を0%（無音）に設定
/takushi_volume 0
```

設定は `~/.config/takushi_notifier/volume.conf` に保存されます。

## 要件

- **Claude CLI**: メッセージ生成に使用されます
  - インストール: `npm install -g @anthropic-ai/claude`
  - 設定: `claude auth login`

## 設定

### API設定
`hooks/tts_bert_vits.sh`ファイル内で以下の設定を確認してください：
- CF_ACCESS_CLIENT_ID
- CF_ACCESS_CLIENT_SECRET
- API_BASE_URL
- MODEL_NAME

## ファイル構成

```
.
├── .claude-plugin/
│   ├── plugin.json          # プラグインのメタデータ
│   └── marketplace.json     # ローカルマーケットプレイス
├── hooks/
│   ├── hooks.json           # フック設定
│   ├── notify.sh            # メイン通知スクリプト
│   ├── tts_bert_vits.sh     # TTS音声合成スクリプト
│   ├── tts_bert_vits.settings # TTS設定ファイル
│   └── generate_message.sh  # メッセージ生成スクリプト
└── skills/
    └── tts-notification/
        └── SKILL.md         # スキル説明
```

## トラブルシューティング

- 音声が再生されない場合は、macOSの音量設定を確認してください
- APIエラーが発生する場合は、認証情報を確認してください
- ログは`hooks/notify.log`に保存されます

## ライセンス

MIT
