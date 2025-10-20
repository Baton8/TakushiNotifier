---
description: "現在のプロジェクトに名前を設定する"
argument-hint: [project_name]
---

# エージェント向け指示

引数がある場合は現在の作業ディレクトリにプロジェクト名を設定し、引数がない場合は現在設定されているプロジェクト名を表示してください。

```bash
# プロジェクト名設定（引数がある場合）
bash "${CLAUDE_PLUGIN_ROOT}/hooks/project_manager.sh" set "$(pwd)" "[project_name]"

# 現在のプロジェクト名取得（引数がない場合）
bash "${CLAUDE_PLUGIN_ROOT}/hooks/project_manager.sh" get "$(pwd)"
```

---

# ユーザー向け使用方法

## 概要
現在のプロジェクトに名前を設定します。設定した名前は通知時に読み上げられます。

## 使用例

```bash
# プロジェクト名を設定
/project_name TakushiNotifier

# 現在のプロジェクト名を確認
/project_name
```

## 引数

- `project_name` (オプション): プロジェクトに付ける名前（文字列）
  - 省略時: 現在のプロジェクト名を表示

## 動作

プロジェクト名が設定されている場合、通知時に読み上げるテキストの先頭に「{プロジェクト名}です。」が追加されます。

**例:**
- プロジェクト名: `InfoComposer`
- 元のメッセージ: `処理が完了しました。`
- 読み上げ: `InfoComposerです。処理が完了しました。`

## 設定保存

設定は `~/.config/takushi_notifier/project_names.conf` に保存され、プロジェクトパスごとに管理されます。
