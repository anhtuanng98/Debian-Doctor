#!/usr/bin/env bash
# Hàm dùng chung cho các bước kiểm tra.

# Mỗi bước ghi kết quả vào $OUT/<tên>.log và trạng thái vào $OUT/status.tsv
record() { # record <tên> <OK|WARN|FAIL> <ghi chú>
    printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$OUT_DIR/status.tsv"
}

has() { command -v "$1" >/dev/null 2>&1; }

write_summary() {
    local out="$1" fails=0 warns=0 oks=0
    {
        echo "# Báo cáo debian-doctor"
        echo
        echo "- Thời điểm: $(date '+%F %T %Z')"
        echo "- Máy: $(hostname) — $(. /etc/os-release && echo "$PRETTY_NAME")"
        echo "- Kernel: $(uname -r)"
        echo
        echo "| Bước | Trạng thái | Ghi chú | Chi tiết |"
        echo "|---|---|---|---|"
        while IFS=$'\t' read -r name status note; do
            case "$status" in
                FAIL) fails=$((fails+1)) ;;
                WARN) warns=$((warns+1)) ;;
                OK)   oks=$((oks+1)) ;;
            esac
            echo "| $name | $status | $note | [$name.log]($name.log) |"
        done < "$out/status.tsv"
        echo
        echo "Tổng: $oks OK, $warns CẢNH BÁO, $fails LỖI."
    } > "$out/summary.md"
}
