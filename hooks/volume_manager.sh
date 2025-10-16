#!/bin/bash

# Takushi音量管理スクリプト
# 使用方法: ./volume_manager.sh [volume] [action]
# action: set, get, init

CONFIG_DIR="$HOME/.config/takushi_notifier"
CONFIG_FILE="$CONFIG_DIR/volume.conf"
DEFAULT_VOLUME=50

# 設定ディレクトリの作成
init_config() {
    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "AFPLAY_VOLUME=0.5" > "$CONFIG_FILE"
        echo "VOLUME_PERCENT=$DEFAULT_VOLUME" >> "$CONFIG_FILE"
    fi
}

# 音量設定（0-100を0.0-1.0に変換）
set_volume() {
    local volume_percent="$1"
    
    # 引数チェック
    if ! [[ "$volume_percent" =~ ^[0-9]+$ ]]; then
        echo "エラー: 音量は0-100の整数で指定してください"
        exit 1
    fi
    
    if [ "$volume_percent" -lt 0 ] || [ "$volume_percent" -gt 100 ]; then
        echo "エラー: 音量は0-100の範囲で指定してください"
        exit 1
    fi
    
    # 0-100を0.0-1.0に変換
    local volume_float=$(echo "scale=2; $volume_percent / 100" | bc -l)
    
    # 設定ファイルを更新
    init_config
    cat > "$CONFIG_FILE" << EOF
AFPLAY_VOLUME=$volume_float
VOLUME_PERCENT=$volume_percent
EOF
    
    echo "Takushi音量を${volume_percent}%に設定しました (afplay: ${volume_float})"
}

# 現在の音量取得
get_volume() {
    init_config
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo "現在のTakushi音量: ${VOLUME_PERCENT}% (afplay: ${AFPLAY_VOLUME})"
    else
        echo "設定ファイルが見つかりません。初期化します..."
        init_config
        echo "現在のTakushi音量: ${DEFAULT_VOLUME}% (afplay: 0.5)"
    fi
}

# メイン処理
case "${1:-get}" in
    "set")
        if [ -z "$2" ]; then
            echo "エラー: 音量を指定してください"
            echo "使用方法: $0 set [0-100]"
            exit 1
        fi
        set_volume "$2"
        ;;
    "get")
        get_volume
        ;;
    "init")
        init_config
        echo "設定ディレクトリを初期化しました: $CONFIG_DIR"
        ;;
    *)
        echo "使用方法: $0 [set|get|init] [volume]"
        echo "  set [0-100]  : 音量を設定"
        echo "  get          : 現在の音量を表示"
        echo "  init         : 設定ディレクトリを初期化"
        exit 1
        ;;
esac
