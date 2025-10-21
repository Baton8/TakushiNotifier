#!/bin/bash

# Takushiプロジェクト名管理スクリプト
# 使用方法: ./project_manager.sh [action] [args...]
# action: set, get, init

CONFIG_DIR="$HOME/.config/takushi_notifier"
PROJECT_NAMES_FILE="$CONFIG_DIR/project_names.conf"

# 設定ディレクトリの作成
init_config() {
    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$PROJECT_NAMES_FILE" ]; then
        touch "$PROJECT_NAMES_FILE"
    fi
}

# プロジェクト名設定
set_project_name() {
    local project_path="$1"
    local project_name="$2"

    # 引数チェック
    if [ -z "$project_path" ] || [ -z "$project_name" ]; then
        echo "エラー: プロジェクトパスと名前を指定してください"
        exit 1
    fi

    init_config

    # 一時ファイルを作成
    local temp_file=$(mktemp)
    local var_name="PROJECT_NAME_${project_path//\//_}"
    local updated=false

    # 設定ファイルを読み込み、該当行を更新
    if [ -f "$PROJECT_NAMES_FILE" ]; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^${var_name}= ]]; then
                echo "${var_name}=\"$project_name\"" >> "$temp_file"
                updated=true
            else
                echo "$line" >> "$temp_file"
            fi
        done < "$PROJECT_NAMES_FILE"
    fi

    # 新規追加の場合
    if [ "$updated" = false ]; then
        echo "${var_name}=\"$project_name\"" >> "$temp_file"
    fi

    # 一時ファイルで設定ファイルを上書き
    mv "$temp_file" "$PROJECT_NAMES_FILE"

    echo "プロジェクト「${project_name}」を設定しました (パス: ${project_path})"
}

# プロジェクト名取得
get_project_name() {
    local project_path="$1"

    if [ -z "$project_path" ]; then
        echo "エラー: プロジェクトパスを指定してください"
        exit 1
    fi

    init_config

    if [ -f "$PROJECT_NAMES_FILE" ]; then
        local current_path="$project_path"
        
        # 現在のパスから親階層まで順に探索
        while [ -n "$current_path" ]; do
            local var_name="PROJECT_NAME_${current_path//\//_}"
            local project_name=$(grep "^${var_name}=" "$PROJECT_NAMES_FILE" | cut -d'=' -f2- | tr -d '"')
            
            if [ -n "$project_name" ]; then
                echo "$project_name"
                return
            fi
            
            # 親ディレクトリに移動
            if [ "$current_path" = "/" ] || [ "$current_path" = "." ]; then
                break
            fi
            current_path=$(dirname "$current_path")
            if [ "$current_path" = "." ]; then
                break
            fi
        done
    fi
    
    echo ""
}

# メイン処理
case "${1:-get}" in
    "set")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "エラー: プロジェクトパスと名前を指定してください"
            echo "使用方法: $0 set [path] [name]"
            exit 1
        fi
        set_project_name "$2" "$3"
        ;;
    "get")
        if [ -z "$2" ]; then
            echo "エラー: プロジェクトパスを指定してください"
            echo "使用方法: $0 get [path]"
            exit 1
        fi
        get_project_name "$2"
        ;;
    "init")
        init_config
        echo "設定ディレクトリを初期化しました: $CONFIG_DIR"
        ;;
    *)
        echo "使用方法: $0 [set|get|init] [args...]"
        echo "  set [path] [name] : プロジェクト名を設定"
        echo "  get [path]        : プロジェクト名を取得"
        echo "  init              : 設定ディレクトリを初期化"
        exit 1
        ;;
esac
