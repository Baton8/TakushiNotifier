---
description: "Takushi音量を0-100の範囲で設定する"
argument-hint: [volume]
---

# Takushi音量設定コマンド

Takushi（Text-to-Speech）の音量を0-100の範囲で設定します。

## 使用方法

```
/takushi_volume 50
```

## 引数

- `volume`: 音量レベル（0-100の整数）
  - 0: 無音
  - 50: 中間音量
  - 100: 最大音量

## 設定保存

設定は `~/.config/takushi_notifier/volume.conf` に保存され、Takushiスクリプトから自動的に読み込まれます。

## 例

```bash
# 音量を50%に設定
/takushi_volume 50

# 音量を0%（無音）に設定
/takushi_volume 0

# 音量を100%（最大）に設定
/takushi_volume 100
```

## 現在の音量確認

引数なしで実行すると、現在の音量設定が表示されます。

```bash
/takushi_volume
```
