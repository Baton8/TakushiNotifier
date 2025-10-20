---
description: "Takushi通知機能の設定と使用方法を提供するスキル"
---

# Takushi通知スキル

このスキルは、Claude Assistantの応答を音声で読み上げる機能を提供します。

## 機能

- Assistantの応答を自動的に音声で読み上げ
- Style-Bert-VITS2を使用した高品質な音声合成
- メッセージの要約と動的生成
- 通知ログの管理

## 設定

### 音量設定
`/volume`コマンドで音量を調整できます：
```
/volume 50  # 50%の音量に設定
```

### API設定
`hooks/tts_bert_vits.sh`ファイル内で以下の設定を確認してください：
- CF_ACCESS_CLIENT_ID
- CF_ACCESS_CLIENT_SECRET
- API_BASE_URL
- MODEL_NAME

## 使用方法

プラグインをインストールすると、Assistantの応答が自動的に音声で読み上げられます。

## トラブルシューティング

- 音声が再生されない場合は、macOSの音量設定を確認してください
- APIエラーが発生する場合は、認証情報を確認してください
- ログは`hooks/notify.log`に保存されます
