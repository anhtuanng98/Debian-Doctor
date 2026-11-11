# Lỗi kernel và đĩa/hệ thống tệp (dmesg).
run_check() {
    local out="$1"; local log="$out/06-kernel.log" n_fs n_err
    {
        echo "## dmesg mức err trở lên"
        dmesg -l err,crit,alert,emerg --color=never 2>&1 || true
        echo; echo "## Lỗi I/O và hệ thống tệp"
        dmesg --color=never 2>/dev/null | grep -iE 'I/O error|EXT4-fs error|BTRFS (error|warning)|XFS.*error|medium error|Buffer I/O' | tail -n 100 || true
    } > "$log" 2>&1
    n_fs="$(sed -n '/^## Lỗi I\/O/,$p' "$log" | grep -c -v '^##\|^$')"
    n_err="$(sed -n '/^## dmesg mức err/,/^## Lỗi I\/O/p' "$log" | grep -c -v '^##\|^$')"
    if (( n_fs > 0 )); then record kernel FAIL "$n_fs dòng lỗi đĩa/hệ thống tệp, kiểm tra ngay"
    elif (( n_err > 0 )); then record kernel WARN "$n_err dòng lỗi mức kernel, xem log"
    else record kernel OK "Không có lỗi kernel đáng chú ý"; fi
}
