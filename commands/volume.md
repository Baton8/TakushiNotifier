---
description: "Takushi音量を0-100の範囲で設定する"
argument-hint: [volume]
---

# エージェント向け指示

引数がある場合は音量を設定し、引数がない場合は現在の音量を表示してください。

```bash
# 音量設定（引数がある場合）
bash "${CLAUDE_PLUGIN_ROOT}/hooks/volume_manager.sh" set [volume]

# 現在の音量取得（引数がない場合）
bash "${CLAUDE_PLUGIN_ROOT}/hooks/volume_manager.sh" get
```

---

# ユーザー向け使用方法

## 概要
Takushi（Text-to-Speech）の音量を0-100の範囲で設定します。

## 使用例

```bash
# 音量を75%に設定
/volume 75

# 現在の音量を確認
/volume
```

## 引数

- `volume` (オプション): 音量レベル（0-100の整数）
  - 0: 無音
  - 50: 中間音量
  - 100: 最大音量
  - 省略時: 現在の音量を表示

## 設定保存

設定は `~/.config/takushi_notifier/volume.conf` に保存されます。
