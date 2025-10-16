以下は、**2025年10月以降の公式情報**を基にした「Claude Code プラグインの作り方」最新まとめです。ご要望の「カスタム・スラッシュコマンド」「エージェント」「ドキュメント（設計書や参照資料）の同梱」まで、**公式ドキュメントの該当箇所**に基づき、手順→構成→配布→運用の順で整理しています。

---

# 1) 全体像（何が作れるか）

Claude Code のプラグインは、以下の拡張点を**ひとまとめに配布・管理**できます。

* **Slash Commands（コマンド）**: `commands/*.md` に定義するカスタム・スラッシュコマンド。([Claude Docs][1])
* **Agents（サブエージェント）**: `agents/*.md` に専門タスク用のエージェント定義。([Claude Docs][2])
* **Skills（Agent Skills）**: `skills/<skill-name>/SKILL.md` と任意の補助ファイルでモデルが自律的に呼び出す機能単位。([Claude Docs][1])
* **Hooks／MCP**: `hooks/hooks.json`、`.mcp.json` でイベント処理や外部ツール連携。([Claude Docs][1])

プラグインは **マーケットプレイス**（単一の `marketplace.json`）に登録し、`/plugin marketplace add ...` → `/plugin install ...` で配布・導入します。([Claude Docs][3])

> 公式の「Plugins」入門は**Quickstart〜構成〜インストール〜チーム導入**まで一気通貫でまとまっています。まずはここをベースに実装を進めるのが最短です。([Claude Docs][1])

---

# 2) 最小構成（雛形）

```
my-first-plugin/
├── .claude-plugin/
│   └── plugin.json          # プラグインのメタデータ
├── commands/                # 任意：カスタム /コマンド
│   └── hello.md
├── agents/                  # 任意：カスタム・サブエージェント
│   └── helper.md
├── skills/                  # 任意：Agent Skills（ドキュメント同梱も可）
│   └── my-skill/
│       ├── SKILL.md
│       └── reference.md     # ← 参照資料を同梱する例
└── hooks/                   # 任意：イベント処理
    └── hooks.json
```

このレイアウトは公式の「Plugin structure overview」に準拠しています。([Claude Docs][1])

---

# 3) まずはローカルで動かす（Quickstart）

1. **プラグイン雛形**
   `.claude-plugin/plugin.json` を作成。最低限は `name/description/version/author`。([Claude Docs][1])
2. **サンプル・コマンド**
   `commands/hello.md` を作成（frontmatter に `description` 推奨）。([Claude Docs][1])
3. **ローカル・マーケットプレイス**
   プラグインの親に `.claude-plugin/marketplace.json` を置き、`plugins` 配列に `source` でパスを登録。([Claude Docs][1])
4. **インストール**
   Claude Code を起動し、`/plugin marketplace add ./test-marketplace` → `/plugin install my-first-plugin@test-marketplace`。([Claude Docs][1])

---

# 4) カスタム・スラッシュコマンドの作り方

* **配置**: `commands/<name>.md`（Markdown＋frontmatter）。コマンド名は拡張子を除いたファイル名。([anthropic.mintlify.app][4])
* **スコープ**:

  * プロジェクト配布: `.claude/commands/`
  * 個人配布: `~/.claude/commands/`（`/help` の表示で `(project)` / `(user)` が付与）。([anthropic.mintlify.app][4])
* **引数**: `$ARGUMENTS`, `$1`, `$2` … のプレースホルダが使えます。([anthropic.mintlify.app][4])
* **ファイル参照**: `@path/to/file` 記法でコードやテキストをインライン参照。([anthropic.mintlify.app][4])
* **モデルからの自動実行可否**: frontmatterに `disable-model-invocation: true` を入れると自動実行対象外にできます（`SlashCommand` tool の制御）。([anthropic.mintlify.app][4])

> **プラグイン由来のコマンド**はユーザ定義と同等に動作し、必要に応じて `/plugin-name:command-name` と**プラグイン接頭辞**で曖昧性を回避します。([anthropic.mintlify.app][4])

---

# 5) エージェント（サブエージェント）の作り方

* **配置**: `agents/<agent-id>.md`（Markdown＋frontmatter）。`description` と **capabilities** を明確に。([Claude Docs][2])
* **呼び出し**:

  * Claude が**タスク文脈に応じて自動呼び出し**
  * `/agents` UI から**手動**で選択実行も可。([Claude Docs][2])
* **権限設計**: 与えるツール（Read/Write、MCP ツール等）は必要最小限に。([Claude Docs][2])

> さらに高度なエージェント化や運用は **Claude Agent SDK**（Claude Code のハーネス上に構築）を使用します。SDK の最新ベストプラクティスは公式エンジニアリング記事を参照してください。([Anthropic][5])

---

# 6) **ドキュメントを入れたい**（設計資料・基準書・テンプレートの同梱）

プラグインには**任意の Markdown/スクリプト/リファレンス**を同梱できます。代表的には以下：

* **Skills 配下**に `reference.md` や `scripts/` を置き、**モデルが自律的に参照**する補足情報として活用（ブランドガイドやコード規約、Excel 操作手順など）。([Claude Docs][2])
* **commands/** に**社内標準レビュー項目**や**生成フォーマット**を直接書き込み、/review, /doc-template などとして配布。([anthropic.mintlify.app][4])

> 2025年10月に発表された **Skills for Claude** は、こうした「タスク特化のフォルダ（手順・規約・スクリプト等）」を一括読み込みする公式の仕立てで、Claude Code／API／Agent SDK 全体で再利用できます。([The Verge][6])

---

# 7) マーケットプレイスで配布（社内共有・自社用ストア）

* **定義**: リポジトリ直下に `.claude-plugin/marketplace.json`。`plugins` 配列に `name` と `source`（相対パス／GitHub repo／任意 git URL 等）を記述。([Claude Docs][3])
* **追加／導入**:

  * 追加: `/plugin marketplace add owner/repo`（GitHub）、`... add ./local-dir`（ローカル）等。([Claude Docs][3])
  * インストール: `/plugin install <plugin>@<marketplace>`。([Claude Docs][3])
* **チーム一括導入**: リポジトリの `.claude/settings.json` に `extraKnownMarketplaces` や `enabledPlugins` を記載 → **信頼済みフォルダ**としてメンバーが開くと自動導入。([Claude Docs][3])
* **検証**: `claude plugin validate .` で JSON 構文や構成の検証が可能。([Claude Docs][3])

> 公式ニュースにも「**marketplace.json だけで配信可能**」「`/plugin` メニューで探索・導入」と明記されています。([Anthropic][7])

---

# 8) セキュリティと権限（MCP／SlashCommand）

* **MCP 権限**は **ワイルドカード不可**。サーバ単位 `mcp__server` かツール単位 `mcp__server__tool` で明示許可。([anthropic.mintlify.app][4])
* **SlashCommand の自動実行**を抑止するには、`disable-model-invocation: true` か `/permissions` で `SlashCommand` を拒否。([anthropic.mintlify.app][4])

---

# 9) ベストプラクティス

* **小さく作り、Skills で段階的に拡張**（共通規約・テンプレ・ナレッジは skills/ に寄せる）。([Claude Docs][1])
* **エージェントは役割・権限を最小化**し、capabilities を明確に。([Claude Docs][2])
* **チーム配布は marketplace＋settings.json** で**再現性**を確保。([Claude Docs][3])
* **ローカルで反復テスト**（開発用マーケットプレイス→再インストールで差分適用）。([Claude Docs][1])

---

# 10) 具体的な作業チェックリスト

1. **リポジトリ作成**（または既存に追加）。
2. `my-plugin/.claude-plugin/plugin.json` を定義。**name/description/version/author** を記入。([Claude Docs][1])
3. `commands/` に `/review`, `/optimize` などを Markdown で追加（frontmatter に `description`）。([anthropic.mintlify.app][4])
4. `agents/` に `code-reviewer.md` 等を追加（`description`, `capabilities`）。([Claude Docs][2])
5. `skills/<skill>/SKILL.md` と `reference.md` に**社内規約・テンプレ**を格納。([Claude Docs][2])
6. ルートに **開発用マーケットプレイス**（`.claude-plugin/marketplace.json`）を用意。`source` に相対パスを指定。([Claude Docs][3])
7. Claude Code を開き、`/plugin marketplace add ./<marketplace-dir>` → `/plugin install <plugin>@<marketplace>`。([Claude Docs][3])
8. チーム配布する場合は、プロジェクト側 `.claude/settings.json` に `extraKnownMarketplaces` と `enabledPlugins` を記述。([Claude Docs][3])
9. `claude plugin validate .` で検証。([Claude Docs][3])

---

## 参考（公式・最新）

* **Plugins（入門〜導入〜構成〜チーム展開）**。([Claude Docs][1])
* **Plugins reference（スキーマ・各コンポーネント仕様）**。([Claude Docs][2])
* **Plugin marketplaces（marketplace.json・配布・検証・自動導入）**。([Claude Docs][3])
* **Slash commands（構文／引数／ファイル参照／自動実行制御）**。([anthropic.mintlify.app][4])
* **Skills（新機能の位置づけ・活用例：公式発表報道）**。([The Verge][6])
* **Claude Agent SDK（エージェント拡張の実装ナレッジ）**。([Anthropic][5])
* **機能追加の公式発表（プラグイン対応）**。([Anthropic][7])

---

## 付録：最小ファイル例

### `.claude-plugin/plugin.json`

```json
{
  "name": "vildas-dev-suite",
  "description": "Vildas のための開発支援プラグイン（レビュー/規約/スキル）",
  "version": "1.0.0",
  "author": { "name": "Your Team" }
}
```

（プラグイン・メタデータの最小例。公式 Quickstart にならう。）([Claude Docs][1])

### `commands/review.md`

```md
---
description: "社内規約に沿ったコードレビューを実施する"
argument-hint: [path-or-PR]
# disable-model-invocation: true  # 自動実行させたくない場合に有効化
---

以下を @$ARGUMENTS についてレビューせよ。重大度ごとに指摘し、修正パッチを提示する。
- セキュリティ（入力検証、権限、秘密情報）
- 可読性（命名、一貫性）
- パフォーマンス（アルゴリズム、I/O）
- テスト（追加が必要なケース）
```

（frontmatter と `$ARGUMENTS`、`@file` 参照の使用例。）([anthropic.mintlify.app][4])

### `agents/code-reviewer.md`

```md
---
description: "静的解析・差分注目・修正パッチ提案が得意なコードレビューワ"
capabilities: ["diff-analysis", "security-checks", "patch-suggestion"]
---
あなたは熟練のコードレビューエージェント。最小権限・安全第一で判断し、具体的な修正案を提示する。
```

（エージェントの基本構造と capabilities の明記。）([Claude Docs][2])

### `skills/review-policy/SKILL.md`

```md
---
description: "Vildas のコード規約とレビュー観点を読み込み、必要時に参照する"
---
このスキルは `reference.md` を参照し、レビュー時の観点・禁止事項・テンプレ出力を提供する。
```

同ディレクトリに `reference.md` を置けば、**規約やテンプレ文書を同梱**して参照可能です。([Claude Docs][2])

### `.claude-plugin/marketplace.json`（社内用）

```json
{
  "name": "vildas-tools",
  "owner": {"name": "Dev Productivity"},
  "plugins": [
    {
      "name": "vildas-dev-suite",
      "source": "./plugins/vildas-dev-suite",
      "description": "レビュー/規約/スキルを同梱した開発支援パック",
      "version": "1.0.0"
    }
  ]
}
```

（GitHub/任意 git/ローカルパスなど **柔軟な source 記述**に対応。）([Claude Docs][3])

---

必要であれば、**vildas 向けに実ファイル一式（雛形リポジトリ）**をこちらで即時に作成し、`marketplace.json` まで整えた形でお渡しします。なお、本回答は**2025年10月公開の公式ドキュメント／アナウンス**に基づいています。各手順・スキーマの根拠は上記の**公式該当ページ**をご確認ください。([Claude Docs][1])

[1]: https://docs.claude.com/en/docs/claude-code/plugins "Plugins - Claude Docs"
[2]: https://docs.claude.com/en/docs/claude-code/plugins-reference "Plugins reference - Claude Docs"
[3]: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces "Plugin marketplaces - Claude Docs"
[4]: https://anthropic.mintlify.app/en/docs/claude-code/slash-commands "Slash commands - Claude Docs"
[5]: https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk?utm_source=chatgpt.com "Building agents with the Claude Agent SDK \ Anthropic"
[6]: https://www.theverge.com/ai-artificial-intelligence/800868/anthropic-claude-skills-ai-agents?utm_source=chatgpt.com "Anthropic turns to 'skills' to make Claude more useful at work"
[7]: https://www.anthropic.com/news/claude-code-plugins?utm_source=chatgpt.com "Customize Claude Code with plugins \ Anthropic"


はい、**可能です**。公式ドキュメントが示すとおり、**プライベートなマーケットプレイス**（`marketplace.json`）を**社内リポジトリやローカルに設置**し、その参照先を**プロジェクトの `.claude/settings.json`** に宣言しておくと、チームメンバーがそのリポジトリを「信頼済み」として開いた際に、指定したマーケットプレイスおよび **`enabledPlugins` に列挙したプラグインを自動で導入**できます。([anthropic.mintlify.app][1])

## 配布パターン（いずれもチーム範囲に限定可能）

1. **社内GitHub/GitLabの私有リポジトリ**
   `/.claude-plugin/marketplace.json` を含むリポジトリを作成 → チームだけにリポジトリアクセスを付与 → 次の設定をプロジェクト側に追加。([anthropic.mintlify.app][1])

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": ["vildas-dev-suite"]   // 必要なら併用
}
```

この設定により、**信頼済みフォルダ**として開かれたとき、自動的にマーケットプレイス（＝社内プライベートカタログ）が認識され、`enabledPlugins` に列挙したプラグインが導入されます。([anthropic.mintlify.app][1])

2. **ローカル配布（開発・検証用）**
   リポジトリではなく**ローカルディレクトリ**に `marketplace.json` を置き、開発メンバーは ` /plugin marketplace add ./path/to/marketplace` で追加可能です。**URL直指定**や**ファイルパス直指定**にも対応しています（いずれも公開不要）。([anthropic.mintlify.app][1])

3. **特定Gitリポジトリを直接追加**
   `/plugin marketplace add https://git.company.com/project-plugins.git` のように**社内GitのURL**を直接登録できます（アクセス権で範囲を制御）。([anthropic.mintlify.app][1])

> なお、Anthropic公式の発表でも「**組織内に承認済みプラグインを配布**」する用途にマーケットプレイスを使える旨が明記されています。([Anthropic][2])

### 参考（公式）

* **Plugin marketplaces**：チーム配布、`extraKnownMarketplaces`、追加コマンド、ローカル/URL直指定、スキーマ、運用まで網羅。([anthropic.mintlify.app][1])
* **ニュースリリース**：組織配布のユースケースを明記。([Anthropic][2])

必要でしたら、**vildas用の私有マーケットプレイス雛形**（`marketplace.json`＋`enabledPlugins`が効く設定例）を即時に提示します。

[1]: https://anthropic.mintlify.app/en/docs/claude-code/plugin-marketplaces "Plugin marketplaces - Claude Docs"
[2]: https://www.anthropic.com/news/claude-code-plugins?utm_source=chatgpt.com "Customize Claude Code with plugins \ Anthropic"
