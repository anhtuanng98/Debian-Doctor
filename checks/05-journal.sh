# Lỗi mức err trở lên trong nhật ký lần khởi động này.
run_check() {
    local out="$1"; local log="$out/05-journal.log" n
    journalctl -b -p err --no-pager > "$log" 2>&1 || true
    n="$(grep -cv -- '^-- \|^$' "$log" 2>/dev/null || echo 0)"
    if (( n == 0 )); then record journal OK "Không có lỗi trong journal lần khởi động này"
    elif (( n < 20 )); then record journal WARN "$n dòng lỗi trong journal"
    else record journal FAIL "$n dòng lỗi trong journal, xem log"; fi
}
