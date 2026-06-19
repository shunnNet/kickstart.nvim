#!/usr/bin/env bash
#
# bench-startup.sh — 可靠量測 nvim 啟動時間
#
# 為什麼需要這支腳本：
#   單次 `nvim --startuptime` 的讀數雜訊極大（同一份設定可能測出
#   130ms 也可能測出 240ms，取決於當下系統負載）。拿單次讀數比較
#   設定改動，很容易把「雜訊」誤判成「變快/變慢」。
#   這支腳本用「多次量測 + 丟棄暖機 + 取中位數 + 顯示分布」來降噪，
#   讓你改設定後能做出可信的比較。
#
# 用法：
#   scripts/bench-startup.sh              # 量目前設定（預設 20 次）
#   scripts/bench-startup.sh 30           # 量目前設定 30 次
#   scripts/bench-startup.sh ab 12        # 交錯 A/B：比較「目前工作區」 vs
#                                         #   「git HEAD 的設定」，各 12 次交錯
#                                         #   （交錯可抵銷系統負載隨時間的漂移）
#
# 判讀原則：
#   - 看「median（中位數）」，不要看單次或 min/max
#   - A/B 兩組的差距若小於各自的 (max - min) 抖動幅度，就視為「沒差」
#
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 跑一次 nvim 並回傳啟動毫秒數
run_once() {
    local log
    log="$(mktemp)"
    nvim --startuptime "$log" +qa >/dev/null 2>&1
    grep -E '^[0-9]' "$log" | tail -1 | awk '{print $1}'
    rm -f "$log"
}

# 吃一串數字（stdin，每行一個），印出統計值
stats() {
    sort -n | awk '
    { a[NR] = $1; sum += $1 }
    END {
        n = NR
        if (n == 0) { print "  (無資料)"; exit }
        med = (n % 2) ? a[int(n/2)+1] : (a[n/2] + a[n/2+1]) / 2
        p90 = a[int(n*0.9 + 0.5)]; if (p90 == "") p90 = a[n]
        printf "  median=%.1f ms   min=%.1f   p90=%.1f   max=%.1f   mean=%.1f   (n=%d)\n", \
               med, a[1], p90, a[n], sum/n, n
    }'
}

# 量目前設定 N 次（含暖機）
bench_current() {
    local n="${1:-20}"
    echo "→ 暖機 3 次（不計入）..."
    run_once >/dev/null; run_once >/dev/null; run_once >/dev/null
    echo "→ 正式量測 $n 次..."
    local vals=()
    for _ in $(seq "$n"); do vals+=("$(run_once)"); done
    echo ""
    echo "=== 目前設定 ==="
    printf '%s\n' "${vals[@]}" | stats
}

# 交錯 A/B：工作區設定 vs git HEAD 設定
bench_ab() {
    local n="${1:-12}"
    if ! git -C "$CONFIG_DIR" rev-parse HEAD >/dev/null 2>&1; then
        echo "錯誤：$CONFIG_DIR 不是 git repo，無法做 HEAD 對照" >&2
        exit 1
    fi
    # 用獨立的 NVIM_APPNAME，避免汙染你正在用的設定 / 套件狀態
    local tmp_cfg
    tmp_cfg="$(mktemp -d)/nvim-head"
    echo "→ 取出 git HEAD 的設定到暫存區做對照..."
    git -C "$CONFIG_DIR" archive HEAD | (mkdir -p "$tmp_cfg" && tar -x -C "$tmp_cfg")

    run_head() {
        local log; log="$(mktemp)"
        XDG_CONFIG_HOME="$(dirname "$tmp_cfg")" NVIM_APPNAME="nvim-head" \
            nvim --startuptime "$log" +qa >/dev/null 2>&1 || true
        grep -E '^[0-9]' "$log" | tail -1 | awk '{print $1}'
        rm -f "$log"
    }

    echo "→ 暖機..."
    run_once >/dev/null; run_head >/dev/null 2>&1 || true
    echo "→ 交錯量測各 $n 次（工作區 ↔ HEAD）..."
    local work=() head=()
    for _ in $(seq "$n"); do
        work+=("$(run_once)")
        head+=("$(run_head 2>/dev/null || echo)")
    done
    echo ""
    echo "=== A) 工作區（含未 commit 的改動） ==="
    printf '%s\n' "${work[@]}" | stats
    echo "=== B) git HEAD（已 commit 的狀態） ==="
    printf '%s\n' "${head[@]}" | grep -E '^[0-9]' | stats
    echo ""
    echo "判讀：A 的 median 明顯低於 B（差距 > 抖動幅度）才算「工作區真的比較快」"
    rm -rf "$(dirname "$tmp_cfg")"
}

case "${1:-}" in
    ab) bench_ab "${2:-12}" ;;
    ''|[0-9]*) bench_current "${1:-20}" ;;
    *) echo "用法：$0 [次數] | ab [次數]"; exit 1 ;;
esac
